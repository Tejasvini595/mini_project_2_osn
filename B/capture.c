#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include <arpa/inet.h>
#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <net/ethernet.h>
#include <net/if_arp.h>
#include <netinet/ip.h>
#include <netinet/ip6.h>
#include <netinet/ip_icmp.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <pcap.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define MAX_PACKETS 10000 // **NEW**: Max packets to store in a session

/* Globals */
static pcap_t *global_handle = NULL;
static pthread_mutex_t global_handle_lock = PTHREAD_MUTEX_INITIALIZER;
static volatile sig_atomic_t capture_running = 0;
static volatile sig_atomic_t exit_requested = 0;
static uint64_t packet_counter = 0;

typedef struct {
  char *device;
  char *filter_exp;
} capture_args_t;

// **NEW**: Struct to store a captured packet
typedef struct {
  struct pcap_pkthdr header;
  u_char *data;
} stored_packet_t;

// **NEW**: Global array for the "Packet Aquarium"
static stored_packet_t *packet_aquarium[MAX_PACKETS];
static int aquarium_count = 0;

/* ================================================================= */
/* =================== PACKET DISSECTION HELPERS =================== */
/* ================================================================= */

void handle_ipv4(const u_char *packet, int size);
void handle_ipv6(const u_char *packet, int size);
void handle_arp(const u_char *packet, int size);

const char *get_service_name(uint16_t port) {
  switch (port) {
  case 80:
    return "HTTP";
  case 443:
    return "HTTPS";
  case 53:
    return "DNS";
  case 21:
    return "FTP";
  case 22:
    return "SSH";
  default:
    return NULL;
  }
}

void print_payload(const u_char *payload, int len) {
  if (len <= 0)
    return;
  const int bytes_per_line = 16;
  int max_bytes = (len < 64) ? len : 64;
  printf("    Data (first %d bytes):\n", max_bytes);
  for (int i = 0; i < max_bytes; i += bytes_per_line) {
    printf("    ");
    for (int j = 0; j < bytes_per_line; j++)
      if (i + j < max_bytes)
        printf("%02x ", payload[i + j]);
      else
        printf("   ");
    printf(" ");
    for (int j = 0; j < bytes_per_line; j++)
      if (i + j < max_bytes)
        printf("%c", isprint(payload[i + j]) ? payload[i + j] : '.');
    printf("\n");
  }
}

void handle_tcp(const u_char *packet, int size, int total_ip_len) {
  if (size < sizeof(struct tcphdr)) {
    printf("L4 (TCP): Malformed Packet\n");
    return;
  }
  const struct tcphdr *tcp_header = (const struct tcphdr *)packet;
  uint16_t src_port = ntohs(tcp_header->th_sport),
           dst_port = ntohs(tcp_header->th_dport);
  const char *src_svc = get_service_name(src_port),
             *dst_svc = get_service_name(dst_port);
  int hdr_len = tcp_header->th_off * 4;
  printf("L4 (TCP): Src Port: %u%s%s | Dst Port: %u%s%s | Seq: %u | Ack: %u\n",
         src_port, src_svc ? " (" : "", src_svc ? src_svc : "", dst_port,
         dst_svc ? ")" : "", dst_svc ? dst_svc : "", ntohl(tcp_header->th_seq),
         ntohl(tcp_header->th_ack));
  printf("    Flags: [");
  if (tcp_header->th_flags & TH_SYN)
    printf("SYN ");
  if (tcp_header->th_flags & TH_ACK)
    printf("ACK ");
  if (tcp_header->th_flags & TH_FIN)
    printf("FIN ");
  if (tcp_header->th_flags & TH_RST)
    printf("RST ");
  if (tcp_header->th_flags & TH_PUSH)
    printf("PSH ");
  if (tcp_header->th_flags & TH_URG)
    printf("URG ");
  printf("] | Window: %u | Checksum: 0x%04x | Header Length: %d bytes\n",
         ntohs(tcp_header->th_win), ntohs(tcp_header->th_sum), hdr_len);
  const u_char *payload = packet + hdr_len;
  int payload_len = total_ip_len - hdr_len;
  const char *app_proto = dst_svc ? dst_svc : (src_svc ? src_svc : "Unknown");
  printf("L7 (Payload): Identified as %s on port %u - %d bytes\n", app_proto,
         dst_svc ? dst_port : src_port, payload_len);
  print_payload(payload, payload_len);
}

void handle_udp(const u_char *packet, int size) {
  if (size < sizeof(struct udphdr)) {
    printf("L4 (UDP): Malformed Packet\n");
    return;
  }
  const struct udphdr *udp_header = (const struct udphdr *)packet;
  uint16_t src_port = ntohs(udp_header->uh_sport),
           dst_port = ntohs(udp_header->uh_dport);
  const char *src_svc = get_service_name(src_port),
             *dst_svc = get_service_name(dst_port);
  printf("L4 (UDP): Src Port: %u%s%s | Dst Port: %u%s%s\n", src_port,
         src_svc ? " (" : "", src_svc ? src_svc : "", dst_port,
         dst_svc ? ")" : "", dst_svc ? dst_svc : "");
  printf("    Length: %u | Checksum: 0x%04x\n", ntohs(udp_header->uh_ulen),
         ntohs(udp_header->uh_sum));
  const u_char *payload = packet + sizeof(struct udphdr);
  int payload_len = ntohs(udp_header->uh_ulen) - sizeof(struct udphdr);
  const char *app_proto = dst_svc ? dst_svc : (src_svc ? src_svc : "Unknown");
  printf("L7 (Payload): Identified as %s on port %u - %d bytes\n", app_proto,
         dst_svc ? dst_port : src_port, payload_len);
  print_payload(payload, payload_len);
}

void handle_ipv4(const u_char *packet, int size) {
  if (size < sizeof(struct ip)) {
    printf("L3 (IPv4): Malformed Packet\n");
    return;
  }
  const struct ip *ip_hdr = (const struct ip *)packet;
  char src_ip[INET_ADDRSTRLEN], dst_ip[INET_ADDRSTRLEN];
  inet_ntop(AF_INET, &(ip_hdr->ip_src), src_ip, INET_ADDRSTRLEN);
  inet_ntop(AF_INET, &(ip_hdr->ip_dst), dst_ip, INET_ADDRSTRLEN);
  int hdr_len = ip_hdr->ip_hl * 4;
  printf("L3 (IPv4): Src IP: %s | Dst IP: %s\n", src_ip, dst_ip);
  const char *proto = "Unknown";
  switch (ip_hdr->ip_p) {
  case IPPROTO_TCP:
    proto = "TCP";
    break;
  case IPPROTO_UDP:
    proto = "UDP";
    break;
  case IPPROTO_ICMP:
    proto = "ICMP";
    break;
  }
  uint16_t flags_offset = ntohs(ip_hdr->ip_off);
  printf("    Protocol: %s (%d) | TTL: %d | ID: 0x%04x | Header Length: %d "
         "bytes\n",
         proto, ip_hdr->ip_p, ip_hdr->ip_ttl, ntohs(ip_hdr->ip_id), hdr_len);
  printf("    Total Length: %u | Flags: [%s%s]\n", ntohs(ip_hdr->ip_len),
         (flags_offset & IP_DF) ? "DF" : "",
         (flags_offset & IP_MF) ? "MF" : "");
  const u_char *transport_packet = packet + hdr_len;
  int transport_size = size - hdr_len;
  int total_ip_len = ntohs(ip_hdr->ip_len) - hdr_len;
  if (ip_hdr->ip_p == IPPROTO_TCP)
    handle_tcp(transport_packet, transport_size, total_ip_len);
  else if (ip_hdr->ip_p == IPPROTO_UDP)
    handle_udp(transport_packet, transport_size);
}

void handle_ipv6(const u_char *packet, int size) {
  // Basic IPv6 handler, can be expanded
  if (size < sizeof(struct ip6_hdr)) {
    printf("L3 (IPv6): Malformed Packet\n");
    return;
  }
  const struct ip6_hdr *ip6_header = (const struct ip6_hdr *)packet;
  char src_ip_str[INET6_ADDRSTRLEN];
  char dst_ip_str[INET6_ADDRSTRLEN];
  inet_ntop(AF_INET6, &(ip6_header->ip6_src), src_ip_str, INET6_ADDRSTRLEN);
  inet_ntop(AF_INET6, &(ip6_header->ip6_dst), dst_ip_str, INET6_ADDRSTRLEN);

  printf("L3 (IPv6): Src IP: %s | Dst IP: %s\n", src_ip_str, dst_ip_str);
  // Further IPv6 dissection can be added here
}

void handle_arp(const u_char *packet, int size) {
  if (size < sizeof(struct arphdr)) {
    printf("L3 (ARP): Malformed Packet\n");
    return;
  }
  const struct arphdr *arp_header = (const struct arphdr *)packet;
  uint16_t op = ntohs(arp_header->ar_op);
  printf("L3 (ARP): Operation: %s (%u)\n",
         (op == ARPOP_REQUEST) ? "Request" : "Reply", op);
}

// **MODIFIED**: Now also stores the packet
void packet_handler(u_char *user, const struct pcap_pkthdr *h,
                    const u_char *bytes) {
  (void)user;
  uint64_t id = __sync_add_and_fetch(&packet_counter, 1);

  // **NEW**: Store the packet if there is space
  if (aquarium_count < MAX_PACKETS) {
    stored_packet_t *sp = malloc(sizeof(stored_packet_t));
    if (sp) {
      sp->header = *h;
      sp->data = malloc(h->caplen);
      if (sp->data) {
        memcpy(sp->data, bytes, h->caplen);
        packet_aquarium[aquarium_count++] = sp;
      } else {
        free(sp); // Malloc for data failed
      }
    }
  }

  printf("-----------------------------------------\n");
  printf("Packet #%" PRIu64 " | Timestamp: %ld.%06ld | Length: %u bytes\n", id,
         (long)h->ts.tv_sec, (long)h->ts.tv_usec, h->caplen);
  if (h->caplen < sizeof(struct ether_header)) {
    printf("L2 (Ethernet): Malformed Packet\n");
    return;
  }
  const struct ether_header *eth = (const struct ether_header *)bytes;
  printf(
      "L2 (Ethernet): Dst MAC: %02x:%02x:%02x:%02x:%02x:%02x | Src MAC: "
      "%02x:%02x:%02x:%02x:%02x:%02x\n",
      eth->ether_dhost[0], eth->ether_dhost[1], eth->ether_dhost[2],
      eth->ether_dhost[3], eth->ether_dhost[4], eth->ether_dhost[5],
      eth->ether_shost[0], eth->ether_shost[1], eth->ether_shost[2],
      eth->ether_shost[3], eth->ether_shost[4], eth->ether_shost[5]);
  uint16_t type = ntohs(eth->ether_type);
  const u_char *next = bytes + sizeof(struct ether_header);
  int remaining = h->caplen - sizeof(struct ether_header);
  const char *etype_str;
  switch (type) {
  case ETHERTYPE_IP:
    etype_str = "IPv4";
    break;
  case ETHERTYPE_IPV6:
    etype_str = "IPv6";
    break;
  case ETHERTYPE_ARP:
    etype_str = "ARP";
    break;
  default:
    etype_str = "Unknown";
    break;
  }
  printf("    EtherType: %s (0x%04x)\n", etype_str, type);
  switch (type) {
  case ETHERTYPE_IP:
    handle_ipv4(next, remaining);
    break;
  case ETHERTYPE_IPV6:
    handle_ipv6(next, remaining);
    break;
  case ETHERTYPE_ARP:
    handle_arp(next, remaining);
    break;
  }
  fflush(stdout);
}

/* ================================================================= */
/* =================== CORE APPLICATION LOGIC ====================== */
/* ================================================================= */

static void sigint_handler(int signum) {
  (void)signum;
  if (capture_running) {
    capture_running = 0;
    printf("\n--- capture stop requested ---\n");
  } else
    exit_requested = 1;
}

static void *capture_thread_fn(void *arg) {
  capture_args_t *args = (capture_args_t *)arg;
  char errbuf[PCAP_ERRBUF_SIZE];
  pcap_t *handle = pcap_open_live(args->device, BUFSIZ, 1, 1000, errbuf);
  if (!handle) {
    fprintf(stderr, "pcap_open_live failed: %s\n", errbuf);
    capture_running = 0;
    return NULL;
  }

  if (args->filter_exp) {
    struct bpf_program fp;
    bpf_u_int32 netmask;
    bpf_u_int32 ip;
    if (pcap_lookupnet(args->device, &ip, &netmask, errbuf) == -1) {
      fprintf(stderr, "Warning: couldn't get netmask for device %s: %s\n",
              args->device, errbuf);
      netmask = 0;
    }
    if (pcap_compile(handle, &fp, args->filter_exp, 0, netmask) == -1) {
      fprintf(stderr, "Error compiling filter '%s': %s\n", args->filter_exp,
              pcap_geterr(handle));
      pcap_close(handle);
      capture_running = 0;
      return NULL;
    }
    if (pcap_setfilter(handle, &fp) == -1) {
      fprintf(stderr, "Error setting filter '%s': %s\n", args->filter_exp,
              pcap_geterr(handle));
      pcap_freecode(&fp);
      pcap_close(handle);
      capture_running = 0;
      return NULL;
    }
    pcap_freecode(&fp);
  }

  if (pcap_setnonblock(handle, 1, errbuf) == -1) {
    fprintf(stderr, "pcap_setnonblock failed: %s\n", errbuf);
    pcap_close(handle);
    capture_running = 0;
    return NULL;
  }

  pthread_mutex_lock(&global_handle_lock);
  global_handle = handle;
  pthread_mutex_unlock(&global_handle_lock);

  __sync_lock_test_and_set(&packet_counter, 0);
  printf("\n--- capturing on '%s' with filter '%s' (press Ctrl+C to stop) "
         "---\n",
         args->device, args->filter_exp ? args->filter_exp : "none");
  fflush(stdout);
  capture_running = 1;

  while (capture_running) {
    pcap_dispatch(handle, -1, packet_handler, NULL);
    usleep(10000);
  }

  pthread_mutex_lock(&global_handle_lock);
  pcap_close(handle);
  global_handle = NULL;
  pthread_mutex_unlock(&global_handle_lock);
  return NULL;
}

// **NEW**: Frees all memory used by the packet aquarium
void clear_aquarium() {
  for (int i = 0; i < aquarium_count; i++) {
    free(packet_aquarium[i]->data);
    free(packet_aquarium[i]);
  }
  aquarium_count = 0;
}

void start_capture_session(char *device, char *filter_exp) {
  if (capture_running) {
    printf("Capture already in progress.\n");
    return;
  }

  // **NEW**: Clear previous session's packets
  clear_aquarium();

  capture_args_t *args = malloc(sizeof(capture_args_t));
  if (!args) {
    perror("malloc");
    return;
  }
  args->device = strdup(device);
  args->filter_exp = filter_exp ? strdup(filter_exp) : NULL;

  pthread_t cap_thread;
  if (pthread_create(&cap_thread, NULL, capture_thread_fn, args) != 0) {
    perror("pthread_create");
    free(args->device);
    free(args->filter_exp);
    free(args);
    return;
  }

  char *line = NULL;
  size_t len = 0;
  while (capture_running && !exit_requested) {
    if (getline(&line, &len, stdin) == -1) {
      if (feof(stdin)) { // Ctrl+D
        printf("\nEOF detected. Exiting program.\n");
        exit_requested = 1;
      } else if (errno == EINTR) { /* Ctrl+C */
      } else {
        perror("getline");
        exit_requested = 1;
      }
      capture_running = 0;
    }
  }
  free(line);

  pthread_join(cap_thread, NULL);
  free(args->device);
  free(args->filter_exp);
  free(args);

  if (!exit_requested) {
    printf("--- capture stopped ---\nReturned to main menu.\n\n");
  }
}

void show_filter_menu_and_capture(char *device) {
  printf("\n--- Select a Filter ---\n");
  printf("  1. HTTP (port 80)\n");
  printf("  2. HTTPS (port 443)\n");
  printf("  3. DNS (port 53)\n");
  printf("  4. ARP\n");
  printf("  5. TCP\n");
  printf("  6. UDP\n");
  printf("  0. Back to Main Menu\n");
  printf("Enter filter choice: ");
  fflush(stdout);

  char *line = NULL;
  size_t len = 0;
  if (getline(&line, &len, stdin) == -1) {
    free(line);
    return;
  }

  char *filter_str = NULL;
  int choice = atoi(line);
  switch (choice) {
  case 1:
    filter_str = "tcp port 80";
    break;
  case 2:
    filter_str = "tcp port 443";
    break;
  case 3:
    filter_str = "udp port 53";
    break;
  case 4:
    filter_str = "arp";
    break;
  case 5:
    filter_str = "tcp";
    break;
  case 6:
    filter_str = "udp";
    break;
  case 0:
    free(line);
    return;
  default:
    printf("Invalid choice.\n");
    free(line);
    return;
  }
  free(line);
  start_capture_session(device, filter_str);
}

// **NEW**: Logic to inspect packets from the last session
void inspect_session() {
  if (aquarium_count == 0) {
    printf("\nNo session has been captured yet. Use options 1 or 2 first.\n");
    return;
  }

  char *line = NULL;
  size_t len = 0;
  while (1) {
    printf("\n--- Inspecting Session (%d packets stored) ---\n",
           aquarium_count);
    printf("Enter Packet ID (1-%d) to inspect, or 0 to return to main menu: ",
           aquarium_count);
    fflush(stdout);

    if (getline(&line, &len, stdin) == -1)
      break; // EOF or error

    int id_choice = atoi(line);
    if (id_choice == 0)
      break;

    if (id_choice > 0 && id_choice <= aquarium_count) {
      stored_packet_t *sp = packet_aquarium[id_choice - 1];
      // Use the original packet_handler to re-dissect and print the stored
      // packet. The first arg (user) is NULL.
      packet_handler(NULL, &sp->header, sp->data);
    } else {
      printf("Invalid Packet ID. Please try again.\n");
    }
  }
  free(line);
}

static char **list_devices_and_get_array(int *out_count) {
  pcap_if_t *alldevs = NULL, *d;
  char errbuf[PCAP_ERRBUF_SIZE];
  if (pcap_findalldevs(&alldevs, errbuf) == -1) {
    fprintf(stderr, "Error finding devices: %s\n", errbuf);
    *out_count = 0;
    return NULL;
  }
  int count = 0;
  for (d = alldevs; d; d = d->next)
    count++;
  if (count == 0) {
    pcap_freealldevs(alldevs);
    *out_count = 0;
    return NULL;
  }

  char **names = calloc(count, sizeof(char *));
  int idx = 0;
  for (d = alldevs; d; d = d->next) {
    names[idx++] = strdup(d->name);
    printf("%2d. %s%s%s\n", idx, d->name, d->description ? " - " : "",
           d->description ? d->description : "");
  }
  pcap_freealldevs(alldevs);
  *out_count = count;
  return names;
}

int main(void) {
  struct sigaction sa;
  memset(&sa, 0, sizeof(sa));
  sa.sa_handler = sigint_handler;
  sigaction(SIGINT, &sa, NULL);

  printf("[C-Shark] The Command-Line Packet Predator\n");
  printf("=========================================\n");

  int devcount = 0;
  char **devnames = list_devices_and_get_array(&devcount);
  if (!devnames || devcount == 0) {
    fprintf(stderr, "No devices found. Exiting.\n");
    return 1;
  }

  char *line = NULL;
  size_t len = 0;
  int chosen_index = -1;
  while (1) {
    printf("\nSelect an interface to sniff (1-%d): ", devcount);
    if (getline(&line, &len, stdin) == -1)
      goto cleanup_and_exit;
    long v = strtol(line, NULL, 10);
    if (v > 0 && v <= devcount) {
      chosen_index = v - 1;
      break;
    }
    printf("Invalid selection.\n");
  }

  char *chosen_device = strdup(devnames[chosen_index]);

  int running = 1;
  while (running && !exit_requested) {
    printf("\n[C-Shark] Sniffing on '%s'. What's next?\n", chosen_device);
    printf("Main Menu:\n");
    printf("  1. Start Sniffing (All Packets)\n");
    printf("  2. Start Sniffing (With Filters)\n");
    printf("  3. Inspect Last Session\n");
    printf("  4. Exit C-Shark\n");
    printf("Enter choice: ");
    fflush(stdout);

    if (getline(&line, &len, stdin) == -1) {
      printf("\nEOF detected. Exiting.\n");
      break;
    }

    switch (atoi(line)) {
    case 1:
      start_capture_session(chosen_device, NULL);
      break;
    case 2:
      show_filter_menu_and_capture(chosen_device);
      break;
    case 3:
      inspect_session();
      break; // **MODIFIED**: Call the new inspect function
    case 4:
      running = 0;
      break;
    default:
      printf("Unknown choice. Try again.\n");
      break;
    }
  }

cleanup_and_exit:
  free(line);
  free(chosen_device);
  for (int i = 0; i < devcount; ++i)
    free(devnames[i]);
  free(devnames);

  // **NEW**: Final cleanup of any stored packets on exit
  clear_aquarium();

  printf("C-Shark is shutting down.\n");
  return 0;
}