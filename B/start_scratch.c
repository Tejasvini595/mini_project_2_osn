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
#define MAX_PACKETS 10000


/* Globals */
static pcap_t *global_handle = NULL;
static pthread_mutex_t global_handle_lock = PTHREAD_MUTEX_INITIALIZER;
static volatile sig_atomic_t capture_running = 0;
static volatile sig_atomic_t exit_requested = 0;
static uint64_t packet_counter = 0;

typedef struct 
{
    char *device;
    char *filter_exp;
} capture_args_t;

typedef struct 
{
    struct pcap_pkthdr header;
    u_char *data;
} stored_packet_t;

static stored_packet_t *packet_aquarium[MAX_PACKETS];
static int aquarium_count = 0;


static void clear_aquarium() 
{
    for (int i = 0; i < aquarium_count; i++) 
    {
        free(packet_aquarium[i]->data);
        free(packet_aquarium[i]);
        packet_aquarium[i] = NULL;
    }
    aquarium_count = 0;
}




static void sigint_handler(int signum) 
{
    (void)signum;
    if (capture_running) 
    {
        capture_running = 0;
        printf("\n\n[!] Capture stop requested - press Enter to return to menu...\n");
        // Break out of pcap loop immediately
        pthread_mutex_lock(&global_handle_lock);
        if (global_handle) {
            pcap_breakloop(global_handle);
        }
        pthread_mutex_unlock(&global_handle_lock);
    } 
    else 
    {
        // In main menu, Ctrl+C should do nothing (stay in menu)
        printf("\n[!] Use option 4 to exit C-Shark\n");
    }
}



// layer 7
// ===== Helper: Identify application protocol by port =====
const char* identify_app_protocol(uint16_t src_port, uint16_t dst_port) 
{
    // Check both directions
    if (src_port == 80 || dst_port == 80) return "HTTP";
    if (src_port == 443 || dst_port == 443) return "HTTPS/TLS";
    if (src_port == 53 || dst_port == 53) return "DNS";
    if (src_port == 25 || dst_port == 25) return "SMTP";
    if (src_port == 110 || dst_port == 110) return "POP3";
    if (src_port == 143 || dst_port == 143) return "IMAP";
    if (src_port == 22 || dst_port == 22) return "SSH";
    return "Unknown";
}

// ===== Helper: Hex + ASCII dump =====
void hex_ascii_dump(const u_char *payload, int len) 
{
    int i, j;
    for (i = 0; i < len; i += 16) 
    {
        // Hex
        printf("  ");
        for (j = 0; j < 16 && i + j < len; j++) 
        {
            printf("%02X ", payload[i + j]);
        }
        for (; j < 16; j++) printf("   "); // padding for alignment

        printf(" ");
        // ASCII
        for (j = 0; j < 16 && i + j < len; j++) 
        {
            unsigned char c = payload[i + j];
            printf("%c", (c >= 32 && c <= 126) ? c : '.');
        }
        printf("\n");
    }
}

// ===== L7 Decoder =====
void print_layer7_payload(const u_char *payload, int payload_len,
                          uint16_t src_port, uint16_t dst_port) 
{
    if (payload_len <= 0) return;

    const char *app_proto = identify_app_protocol(src_port, dst_port);

    printf("L7 (Payload): Identified as %s on port %u - %d bytes\n",
           app_proto, dst_port, payload_len);

    int dump_len = payload_len > 64 ? 64 : payload_len;
    printf("Data (first %d bytes):\n", dump_len);
    hex_ascii_dump(payload, dump_len);
}



static const char* port_to_service(uint16_t port) 
{
    switch (port) 
    {
        case 53:  return "DNS";
        case 80:  return "HTTP";
        case 443: return "HTTPS";
        case 25:  return "SMTP";
        case 110: return "POP3";
        case 143: return "IMAP";
        case 22:  return "SSH";
        default:  return NULL;
    }
}


// layer 4
static void decode_l4(uint8_t proto, const u_char *l4, int l4_len) 
{
    if (proto == IPPROTO_TCP && l4_len >= (int)sizeof(struct tcphdr)) 
    {
        const struct tcphdr *tcp = (const struct tcphdr *)l4;

        uint16_t sport = ntohs(tcp->th_sport);
        uint16_t dport = ntohs(tcp->th_dport);

        const char *s_service = port_to_service(sport);
        const char *d_service = port_to_service(dport);

        printf("L4 (TCP): Src Port: %u%s | Dst Port: %u%s\n",
               sport, s_service ? " (" : "",
               dport, d_service ? " (" : "");
        if (s_service) printf("%s)", s_service);
        if (d_service) printf("%s)", d_service);
        printf("\n");

        printf("Seq: %u | Ack: %u\n", ntohl(tcp->th_seq), ntohl(tcp->th_ack));

        // TCP Flags
        printf("Flags: [");
        if (tcp->th_flags & TH_SYN) printf("SYN");
        if (tcp->th_flags & TH_ACK) printf("ACK");
        if (tcp->th_flags & TH_FIN) printf("FIN");
        if (tcp->th_flags & TH_RST) printf("RST");
        if (tcp->th_flags & TH_PUSH) printf("PSH");
        if (tcp->th_flags & TH_URG) printf("URG");
        printf("]\n");

        printf("Window: %u | Checksum: 0x%04X | Header Length: %d bytes\n",
               ntohs(tcp->th_win), ntohs(tcp->th_sum), tcp->th_off * 4);

        int header_len = tcp->th_off * 4;
        int tcp_payload_len = l4_len - header_len;
        const u_char *tcp_payload = l4 + header_len;


        print_layer7_payload(tcp_payload, tcp_payload_len,
                            ntohs(tcp->th_sport), ntohs(tcp->th_dport));

    } 
    
    else if (proto == IPPROTO_UDP && l4_len >= (int)sizeof(struct udphdr)) 
    {
        const struct udphdr *udp = (const struct udphdr *)l4;

        uint16_t sport = ntohs(udp->uh_sport);
        uint16_t dport = ntohs(udp->uh_dport);

        const char *s_service = port_to_service(sport);
        const char *d_service = port_to_service(dport);

        printf("L4 (UDP): Src Port: %u%s | Dst Port: %u%s\n",
               sport, s_service ? " (" : "",
               dport, d_service ? " (" : "");
        if (s_service) printf("%s)", s_service);
        if (d_service) printf("%s)", d_service);
        printf("\n");

        printf("Length: %u | Checksum: 0x%04X\n",
               ntohs(udp->uh_ulen), ntohs(udp->uh_sum));

        int udp_payload_len = l4_len - sizeof(struct udphdr);
        const u_char *udp_payload = l4 + sizeof(struct udphdr);

        print_layer7_payload(udp_payload, udp_payload_len,
                            ntohs(udp->uh_sport), ntohs(udp->uh_dport));

    }
}



static void decode_l3(uint16_t eth_type, const u_char *l3, int l3_len) 
{
    if (eth_type == ETHERTYPE_IP && l3_len >= (int)sizeof(struct ip)) 
    {
        // -------- IPv4 --------
        const struct ip *ip_hdr = (const struct ip *)l3;

        char src_ip[INET_ADDRSTRLEN], dst_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &ip_hdr->ip_src, src_ip, sizeof(src_ip));
        inet_ntop(AF_INET, &ip_hdr->ip_dst, dst_ip, sizeof(dst_ip));

        printf("L3 (IPv4): Src IP: %s | Dst IP: %s | Protocol: ", src_ip, dst_ip);
        switch (ip_hdr->ip_p) 
        {
            case IPPROTO_TCP: printf("TCP (6)"); break;
            case IPPROTO_UDP: printf("UDP (17)"); break;
            case IPPROTO_ICMP: printf("ICMP (1)"); break;
            default: printf("Unknown (%d)", ip_hdr->ip_p); break;
        }
        printf(" | TTL: %d\n", ip_hdr->ip_ttl);

        printf("ID: 0x%04X | Total Length: %d | Header Length: %d bytes | ",
               ntohs(ip_hdr->ip_id), ntohs(ip_hdr->ip_len), ip_hdr->ip_hl * 4);

        uint16_t frag_off = ntohs(*(uint16_t *)(&ip_hdr->ip_off));
        int df = (frag_off & IP_DF) ? 1 : 0;
        int mf = (frag_off & IP_MF) ? 1 : 0;
        printf("Flags: [DF=%d, MF=%d]\n", df, mf);

        const u_char *l4 = l3 + ip_hdr->ip_hl * 4;
        int l4_len = l3_len - ip_hdr->ip_hl * 4;
        decode_l4(ip_hdr->ip_p, l4, l4_len);

    }

    else if (eth_type == ETHERTYPE_IPV6 && l3_len >= (int)sizeof(struct ip6_hdr)) 
    {
        // -------- IPv6 --------
        const struct ip6_hdr *ip6_hdr = (const struct ip6_hdr *)l3;

        char src_ip[INET6_ADDRSTRLEN], dst_ip[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &ip6_hdr->ip6_src, src_ip, sizeof(src_ip));
        inet_ntop(AF_INET6, &ip6_hdr->ip6_dst, dst_ip, sizeof(dst_ip));

        printf("L3 (IPv6): Src IP: %s | Dst IP: %s\n", src_ip, dst_ip);
        printf("Next Header: ");
        switch (ip6_hdr->ip6_nxt) 
        {
            case IPPROTO_TCP: printf("TCP (6)"); break;
            case IPPROTO_UDP: printf("UDP (17)"); break;
            default: printf("Unknown (%d)", ip6_hdr->ip6_nxt); break;
        }
        printf(" | Hop Limit: %d\n", ip6_hdr->ip6_hlim);

        uint32_t flow = ntohl(ip6_hdr->ip6_flow);
        int tc = (flow >> 20) & 0xFF;
        int flabel = flow & 0xFFFFF;
        printf("Traffic Class: %d | Flow Label: 0x%05X | Payload Length: %d\n",
               tc, flabel, ntohs(ip6_hdr->ip6_plen));

        const u_char *l4 = l3 + sizeof(struct ip6_hdr);
        int l4_len = l3_len - sizeof(struct ip6_hdr);
        decode_l4(ip6_hdr->ip6_nxt, l4, l4_len);


    } 
    
    
    else if (eth_type == ETHERTYPE_ARP && l3_len >= (int)sizeof(struct arphdr)) 
    {
        // -------- ARP --------
        const struct arphdr *arp_hdr = (const struct arphdr *)l3;

        uint16_t op = ntohs(arp_hdr->ar_op);
        const char *op_str = (op == ARPOP_REQUEST) ? "Request" :
                             (op == ARPOP_REPLY)   ? "Reply" : "Unknown";

        const u_char *ptr = l3 + sizeof(struct arphdr);
        char sender_mac[18], target_mac[18];
        snprintf(sender_mac, sizeof(sender_mac),
                 "%02X:%02X:%02X:%02X:%02X:%02X",
                 ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]);
        struct in_addr sender_ip;
        memcpy(&sender_ip, ptr + 6, 4);

        snprintf(target_mac, sizeof(target_mac),
                 "%02X:%02X:%02X:%02X:%02X:%02X",
                 ptr[10], ptr[11], ptr[12], ptr[13], ptr[14], ptr[15]);
        struct in_addr target_ip;
        memcpy(&target_ip, ptr + 16, 4);

        char sender_ip_str[INET_ADDRSTRLEN], target_ip_str[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &sender_ip, sender_ip_str, sizeof(sender_ip_str));
        inet_ntop(AF_INET, &target_ip, target_ip_str, sizeof(target_ip_str));

        printf("L3 (ARP): Operation: %s (%u) | Sender IP: %s | Target IP: %s\n",
               op_str, op, sender_ip_str, target_ip_str);
        printf("Sender MAC: %s | Target MAC: %s\n", sender_mac, target_mac);
        printf("HW Type: %u | Proto Type: 0x%04X | HW Len: %u | Proto Len: %u\n",
               ntohs(arp_hdr->ar_hrd), ntohs(arp_hdr->ar_pro),
               arp_hdr->ar_hln, arp_hdr->ar_pln);
    }
}




// this part prints the available devices like wlan0, etc
static char **list_devices_and_get_array(int *out_count) 
{
    pcap_if_t *alldevs = NULL, *d;
    char errbuf[PCAP_ERRBUF_SIZE];
    
    if (pcap_findalldevs(&alldevs, errbuf) == -1) 
    {
        fprintf(stderr, "Error finding devices: %s\n", errbuf);
        *out_count = 0;
        return NULL;
    }
    
    int count = 0;
    for (d = alldevs; d; d = d->next) count++;
    
    if (count == 0) 
    {
        pcap_freealldevs(alldevs);
        *out_count = 0;
        return NULL;
    }
    
    char **names = calloc(count, sizeof(char *));
    int idx = 0;
    
    printf("\n[C-Shark] Searching for available interfaces... Found!\n\n");
    for (d = alldevs; d; d = d->next) 
    {
        names[idx++] = strdup(d->name);
        printf("%2d. %s%s%s\n", idx, d->name,
               d->description ? " (" : "",
               d->description ? d->description : "");
        if (d->description) printf("%s", ")");
    }
    
    pcap_freealldevs(alldevs);
    *out_count = count;
    return names;
}


// phase 1.2
//phase 2.1- data link layer
static void packet_handler(u_char *user, const struct pcap_pkthdr *h, const u_char *bytes) 
{
    (void)user;
    packet_counter++;


     // --- Store packet in aquarium ---
    if (aquarium_count < MAX_PACKETS) 
    {
        stored_packet_t *pkt = malloc(sizeof(stored_packet_t));
        if (pkt) 
        {
            pkt->header = *h; // copy header
            pkt->data = malloc(h->caplen);
            if (pkt->data) 
            {
                memcpy(pkt->data, bytes, h->caplen);
                packet_aquarium[aquarium_count++] = pkt;
            } 
            else 
            {
                free(pkt);
            }
        }
    }

    // timestamp
    char timestr[64];
    struct tm *ltime;
    time_t local_tv_sec = h->ts.tv_sec;
    ltime = localtime(&local_tv_sec);
    strftime(timestr, sizeof(timestr), "%H:%M:%S", ltime);

    printf("\nPacket #%lu | Timestamp: %s.%06ld | Length: %d bytes\n",
           packet_counter, timestr, h->ts.tv_usec, h->caplen);

    // print first 16 bytes in hex raw hex dump
    // printf("Data (first 16 bytes): ");
    // int max_bytes = h->caplen < 16 ? h->caplen : 16;
    // for (int i = 0; i < max_bytes; i++) {
    //     printf("%02x ", bytes[i]);
    // }
    // printf("\n-----------------------------------------\n");

    if (h->caplen < sizeof(struct ether_header)) 
    {
        printf("[!] Truncated packet, no Ethernet header.\n");
        printf("-----------------------------------------\n");
        return;
    }

    const struct ether_header *eth = (const struct ether_header *)bytes;

    // format MAC addresses
    char src_mac[18], dst_mac[18];
    snprintf(dst_mac, sizeof(dst_mac), "%02X:%02X:%02X:%02X:%02X:%02X",
             eth->ether_dhost[0], eth->ether_dhost[1], eth->ether_dhost[2],
             eth->ether_dhost[3], eth->ether_dhost[4], eth->ether_dhost[5]);
    snprintf(src_mac, sizeof(src_mac), "%02X:%02X:%02X:%02X:%02X:%02X",
             eth->ether_shost[0], eth->ether_shost[1], eth->ether_shost[2],
             eth->ether_shost[3], eth->ether_shost[4], eth->ether_shost[5]);

    // EtherType
    uint16_t eth_type = ntohs(eth->ether_type);
    const char *etype_str = "Unknown";
    switch (eth_type) 
    {
        case ETHERTYPE_IP:   etype_str = "IPv4"; break;
        case ETHERTYPE_IPV6: etype_str = "IPv6"; break;
        case ETHERTYPE_ARP:  etype_str = "ARP";  break;
    }

    printf("L2 (Ethernet): Dst MAC: %s | Src MAC: %s | EtherType: %s (0x%04X)\n",
           dst_mac, src_mac, etype_str, eth_type);


    const u_char *l3 = bytes + sizeof(struct ether_header);
    int l3_len = h->caplen - sizeof(struct ether_header);

    // Call modular L3 decoder
    decode_l3(eth_type, l3, l3_len);

    printf("-----------------------------------------\n");

}


// phase 1.2
void start_capture_session(char *device, char *filter_exp) 
{
    if (capture_running) 
    {
        printf("Capture already in progress.\n");
        return;
    }

    clear_aquarium();

    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *handle = pcap_open_live(device, BUFSIZ, 1, 1000, errbuf);
    if (!handle) 
    {
        fprintf(stderr, "Couldn't open device %s: %s\n", device, errbuf);
        return;
    }

    printf("\n[C-Shark] Starting capture on %s (all packets)...\n", device);
    capture_running = 1;
    packet_counter = 0;

    int fd_stdin = fileno(stdin);

    // run capture loop until Ctrl+C sets capture_running = 0
    while (capture_running && !exit_requested) 
    {
        fd_set readfds;
        FD_ZERO(&readfds);
        FD_SET(fd_stdin, &readfds);

        struct timeval tv = {0, 500000}; // 0.5 sec timeout
        int r = select(fd_stdin + 1, &readfds, NULL, NULL, &tv);

        if (r > 0 && FD_ISSET(fd_stdin, &readfds)) 
        {
            char buf[8];
            if (!fgets(buf, sizeof(buf), stdin)) 
            {
                // EOF (Ctrl+D)
                printf("\n[!] Ctrl+D detected - exiting...\n");
                exit_requested = 1;
                break;
            }
        }
        int ret = pcap_dispatch(handle, 1, packet_handler, NULL);
        if (ret < 0) 
        {
            fprintf(stderr, "pcap_dispatch error: %s\n", pcap_geterr(handle));
            break;
        }
    }

    pcap_close(handle);

    if (!exit_requested) 
    {
        printf("\n===========================================\n");
        printf("[C-Shark] Capture stopped\n");
        printf("Total packets captured: %lu\n", packet_counter);
        printf("===========================================\n");
    }
}

//phase 3
void show_filter_menu_and_capture(char *device) 
{
    printf("\nSelect protocol to filter:\n");
    printf("  1. HTTP\n");
    printf("  2. HTTPS\n");
    printf("  3. DNS\n");
    printf("  4. ARP\n");
    printf("  5. TCP\n");
    printf("  6. UDP\n");
    printf("Enter choice: ");

    char *line = NULL;
    size_t len = 0;
    if (getline(&line, &len, stdin) == -1) {
        printf("\nEOF detected. Returning to menu.\n");
        free(line);
        return;
    }

    const char *bpf_filter = NULL;
    switch (atoi(line)) 
    {
        case 1: bpf_filter = "tcp port 80"; break;
        case 2: bpf_filter = "tcp port 443"; break;
        case 3: bpf_filter = "udp port 53"; break;
        case 4: bpf_filter = "arp"; break;
        case 5: bpf_filter = "tcp"; break;
        case 6: bpf_filter = "udp"; break;
        default:
            printf("Invalid choice. Returning to menu.\n");
            free(line);
            return;
    }

    free(line);

    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *handle = pcap_open_live(device, BUFSIZ, 1, 1000, errbuf);
    if (!handle) 
    {
        fprintf(stderr, "Couldn't open device %s: %s\n", device, errbuf);
        return;
    }

    // Compile & set filter
    struct bpf_program fp;
    if (pcap_compile(handle, &fp, bpf_filter, 0, PCAP_NETMASK_UNKNOWN) == -1) 
    {
        fprintf(stderr, "Couldn't parse filter %s: %s\n", bpf_filter, pcap_geterr(handle));
        pcap_close(handle);
        return;
    }
    if (pcap_setfilter(handle, &fp) == -1) 
    {
        fprintf(stderr, "Couldn't set filter %s: %s\n", bpf_filter, pcap_geterr(handle));
        pcap_freecode(&fp);
        pcap_close(handle);
        return;
    }
    pcap_freecode(&fp);

    printf("\n[C-Shark] Starting capture on %s with filter: %s\n", device, bpf_filter);

    // Reuse your capture loop
    capture_running = 1;
    packet_counter = 0;

    int fd_stdin = fileno(stdin);
    while (capture_running && !exit_requested) 
    {
        fd_set readfds;
        FD_ZERO(&readfds);
        FD_SET(fd_stdin, &readfds);

        struct timeval tv = {0, 500000};
        int r = select(fd_stdin + 1, &readfds, NULL, NULL, &tv);

        if (r > 0 && FD_ISSET(fd_stdin, &readfds)) 
        {
            char buf[8];
            if (!fgets(buf, sizeof(buf), stdin)) 
            {
                exit_requested = 1;
                break;
            }
        }
        int ret = pcap_dispatch(handle, 1, packet_handler, NULL);
        if (ret < 0) 
        {
            fprintf(stderr, "pcap_dispatch error: %s\n", pcap_geterr(handle));
            break;
        }
    }

    pcap_close(handle);
    printf("\n[C-Shark] Filtered capture stopped. Total packets: %lu\n", packet_counter);
}




static void print_bytes_range_hex(const u_char *data, int start, int len) {
    // print len bytes starting at data[start] as hex separated by space
    for (int i = 0; i < len; ++i) {
        printf("%02X ", (unsigned char)data[start + i]);
    }
    printf("\n");
}

static void print_full_hex_dump(const u_char *data, int len) {
    // header
    printf("\n  COMPLETE FRAME HEX DUMP\n\n");
    printf("    ");
    for (int col = 0; col < 16; ++col) printf(" %X ", col);
    printf("   ASCII\n");

    for (int off = 0; off < len; off += 16) {
        int line_len = (len - off) >= 16 ? 16 : (len - off);
        printf("%04X ", off);                // offset
        for (int i = 0; i < 16; ++i) {
            if (i < line_len) printf(" %02X", (unsigned char)data[off + i]);
            else printf("   ");
        }
        printf("  ");
        // ASCII panel
        for (int i = 0; i < line_len; ++i) {
            unsigned char c = data[off + i];
            putchar((c >= 32 && c <= 126) ? c : '.');
        }
        printf("\n");
    }
    printf("\n");
}

static void print_ethernet_details(const u_char *frame, int frame_len) {
    if (frame_len < (int)sizeof(struct ether_header)) {
        printf("[!] Frame too short for Ethernet header\n");
        return;
    }
    const struct ether_header *eth = (const struct ether_header *)frame;

    printf("🔗 ETHERNET II FRAME (Layer 2)\n\n");
    printf("Destination MAC: %02X:%02X:%02X:%02X:%02X:%02X (Bytes 0-5)\n",
           eth->ether_dhost[0], eth->ether_dhost[1], eth->ether_dhost[2],
           eth->ether_dhost[3], eth->ether_dhost[4], eth->ether_dhost[5]);
    printf("  └ Hex: ");
    print_bytes_range_hex(frame, 0, 6);

    printf("Source MAC:      %02X:%02X:%02X:%02X:%02X:%02X (Bytes 6-11)\n",
           eth->ether_shost[0], eth->ether_shost[1], eth->ether_shost[2],
           eth->ether_shost[3], eth->ether_shost[4], eth->ether_shost[5]);
    printf("  └ Hex: ");
    print_bytes_range_hex(frame, 6, 6);

    uint16_t eth_type = ntohs(eth->ether_type);
    printf("EtherType:       0x%04X (%s)\n\n",
           eth_type,
           eth_type == ETHERTYPE_IP ? "IPv4" :
           eth_type == ETHERTYPE_IPV6 ? "IPv6" :
           eth_type == ETHERTYPE_ARP ? "ARP" : "Unknown");
    printf("  └ Hex: ");
    print_bytes_range_hex(frame, 12, 2);
}

static void print_ipv4_details(const u_char *l3, int l3_len) {
    if (l3_len < (int)sizeof(struct ip)) {
        printf("[!] Too short for IPv4 header\n");
        return;
    }
    const struct ip *ip_hdr = (const struct ip *)l3;

    unsigned ver = ip_hdr->ip_v;
    unsigned ihl = ip_hdr->ip_hl * 4;
    printf("🌐 IPv4 HEADER (Layer 3)\n\n");
    printf("Version: %u | Header Length: %u bytes\n", ver, ihl);
    printf("  └ Hex (first byte): ");
    print_bytes_range_hex(l3, 0, 1);

    printf("Type of Service / DSCP: 0x%02X (Byte 1)\n", (unsigned char)ip_hdr->ip_tos);
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 1, 1);

    printf("Total Length: %u (Bytes 2-3)\n", ntohs(ip_hdr->ip_len));
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 2, 2);

    printf("Identification: 0x%04X (Bytes 4-5)\n", ntohs(ip_hdr->ip_id));
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 4, 2);

    uint16_t fragoff = ntohs(*(uint16_t *)(&ip_hdr->ip_off));
    printf("Flags/FragOff: 0x%04X (Bytes 6-7)  Flags: [DF=%d, MF=%d]  FragOffset: %u\n",
           fragoff, (fragoff & IP_DF) ? 1 : 0, (fragoff & IP_MF) ? 1 : 0, (fragoff & IP_OFFMASK));
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 6, 2);

    printf("TTL: %u | Protocol: %u | Header Checksum: 0x%04X (Bytes 8-11)\n",
           ip_hdr->ip_ttl, ip_hdr->ip_p, ntohs(ip_hdr->ip_sum));
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 8, 4);

    char src[INET_ADDRSTRLEN], dst[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &ip_hdr->ip_src, src, sizeof(src));
    inet_ntop(AF_INET, &ip_hdr->ip_dst, dst, sizeof(dst));
    printf("Source IP: %s (Bytes %d-%d)\n", src, 12, 15);
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 12, 4);
    printf("Destination IP: %s (Bytes %d-%d)\n", dst, 16, 19);
    printf("  └ Hex: ");
    print_bytes_range_hex(l3, 16, 4);

    printf("\n");
}

static void print_ipv6_details(const u_char *l3, int l3_len) {
    if (l3_len < (int)sizeof(struct ip6_hdr)) {
        printf("[!] Too short for IPv6 header\n");
        return;
    }
    const struct ip6_hdr *ip6 = (const struct ip6_hdr *)l3;
    printf("🌐 IPv6 HEADER (Layer 3)\n\n");

    uint32_t flow = ntohl(ip6->ip6_flow);
    int tc = (flow >> 20) & 0xFF;
    int fl = flow & 0xFFFFF;
    printf("Traffic Class: %d | Flow Label: 0x%05X | Payload Length: %u | Next Header: %u | Hop Limit: %u\n",
           tc, fl, ntohs(ip6->ip6_plen), ip6->ip6_nxt, ip6->ip6_hlim);
    printf("  └ Hex (first 8 bytes): ");
    print_bytes_range_hex(l3, 0, 8);

    char src[INET6_ADDRSTRLEN], dst[INET6_ADDRSTRLEN];
    inet_ntop(AF_INET6, &ip6->ip6_src, src, sizeof(src));
    inet_ntop(AF_INET6, &ip6->ip6_dst, dst, sizeof(dst));
    printf("Source IP: %s\n  └ Hex: ", src);
    print_bytes_range_hex(l3, 8, 16);
    printf("Destination IP: %s\n  └ Hex: ", dst);
    print_bytes_range_hex(l3, 24, 16);

    printf("\n");
}

static void print_arp_details(const u_char *l3, int l3_len) {
    if (l3_len < (int)sizeof(struct arphdr) + 8) { // arphdr is generic - we read rest carefully
        printf("[!] Too short for ARP\n");
        return;
    }

    const struct arphdr *arp = (const struct arphdr *)l3;
    uint16_t op = ntohs(arp->ar_op);
    printf("📬 ARP (Layer 3)\n\n");
    printf("Operation: %s (%u)\n", (op == ARPOP_REQUEST) ? "Request" : (op == ARPOP_REPLY) ? "Reply" : "Unknown", op);
    printf("HW Type: %u | Proto Type: 0x%04X | HW Len: %u | Proto Len: %u\n",
           ntohs(arp->ar_hrd), ntohs(arp->ar_pro), arp->ar_hln, arp->ar_pln);

    // print the rest bytes (sender/target mac & ip) using offsets
    const u_char *ptr = l3 + sizeof(struct arphdr);
    printf("Sender MAC: %02X:%02X:%02X:%02X:%02X:%02X\n",
           ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]);
    printf("  └ Hex (bytes %d-%d): ", (int)(sizeof(struct arphdr)), (int)(sizeof(struct arphdr) + 5));
    print_bytes_range_hex(l3,  sizeof(struct arphdr), 6);

    struct in_addr sip;
    memcpy(&sip, ptr + 6, 4);
    char sstr[INET_ADDRSTRLEN]; inet_ntop(AF_INET, &sip, sstr, sizeof(sstr));
    printf("Sender IP: %s (Hex: ", sstr); print_bytes_range_hex(l3, sizeof(struct arphdr) + 6, 4);

    printf("Target MAC: %02X:%02X:%02X:%02X:%02X:%02X\n",
           ptr[10], ptr[11], ptr[12], ptr[13], ptr[14], ptr[15]);
    printf("  └ Hex (bytes %d-%d): ", (int)(sizeof(struct arphdr) + 10), (int)(sizeof(struct arphdr) + 15));
    print_bytes_range_hex(l3, sizeof(struct arphdr) + 10, 6);

    struct in_addr tip;
    memcpy(&tip, ptr + 16, 4);
    char tstr[INET_ADDRSTRLEN]; inet_ntop(AF_INET, &tip, tstr, sizeof(tstr));
    printf("Target IP: %s (Hex: ", tstr); print_bytes_range_hex(l3, sizeof(struct arphdr) + 16, 4);
    printf("\n");
}

static void print_tcp_details(const u_char *l4, int l4_len) {
    if (l4_len < (int)sizeof(struct tcphdr)) {
        printf("[!] Too short for TCP header\n");
        return;
    }
    const struct tcphdr *tcp = (const struct tcphdr *)l4;
    uint16_t sport = ntohs(tcp->th_sport), dport = ntohs(tcp->th_dport);
    printf("🔐 TCP HEADER (Layer 4)\n\n");
    printf("Source Port: %u (Bytes 0-1)\n  └ Hex: ", sport); print_bytes_range_hex(l4, 0, 2);
    printf("Destination Port: %u (Bytes 2-3)\n  └ Hex: ", dport); print_bytes_range_hex(l4, 2, 2);

    uint32_t seq = ntohl(tcp->th_seq), ack = ntohl(tcp->th_ack);
    printf("Sequence Number: %u (Bytes 4-7)\n  └ Hex: ", seq); print_bytes_range_hex(l4, 4, 4);
    printf("Acknowledgement: %u (Bytes 8-11)\n  └ Hex: ", ack); print_bytes_range_hex(l4, 8, 4);

    unsigned hdrlen = tcp->th_off * 4;
    printf("Header Length: %u bytes (upper 4 bits of byte 12)\n  └ Hex: ", hdrlen); print_bytes_range_hex(l4, 12, 1);

    unsigned flags = tcp->th_flags;
    printf("Flags: [");
    printf("%s", (flags & TH_URG) ? "URG," : "");
    printf("%s", (flags & TH_ACK) ? "ACK," : "");
    printf("%s", (flags & TH_PUSH) ? "PSH," : "");
    printf("%s", (flags & TH_RST) ? "RST," : "");
    printf("%s", (flags & TH_SYN) ? "SYN," : "");
    printf("%s", (flags & TH_FIN) ? "FIN," : "");
    printf("] (Byte 13)\n");
    printf("  └ Hex (flags byte): "); print_bytes_range_hex(l4, 13, 1);

    printf("Window: %u (Bytes 14-15)\n  └ Hex: ", ntohs(tcp->th_win)); print_bytes_range_hex(l4, 14, 2);
    printf("Checksum: 0x%04X (Bytes 16-17)\n  └ Hex: ", ntohs(tcp->th_sum)); print_bytes_range_hex(l4, 16, 2);
    printf("Urgent Pointer: %u (Bytes 18-19)\n  └ Hex: ", ntohs(tcp->th_urp)); print_bytes_range_hex(l4, 18, 2);

    if (hdrlen > 20 && l4_len >= (int)hdrlen) {
        int opt_len = hdrlen - 20;
        printf("TCP Options (%d bytes):\n  └ Hex: ", opt_len);
        print_bytes_range_hex(l4, 20, opt_len);
    }
    printf("\n");
}

static void print_udp_details(const u_char *l4, int l4_len) {
    if (l4_len < (int)sizeof(struct udphdr)) {
        printf("[!] Too short for UDP header\n");
        return;
    }
    const struct udphdr *udp = (const struct udphdr *)l4;
    printf("📦 UDP HEADER (Layer 4)\n\n");
    printf("Source Port: %u (Bytes 0-1)\n  └ Hex: ", ntohs(udp->uh_sport)); print_bytes_range_hex(l4, 0, 2);
    printf("Destination Port: %u (Bytes 2-3)\n  └ Hex: ", ntohs(udp->uh_dport)); print_bytes_range_hex(l4, 2, 2);
    printf("Length: %u (Bytes 4-5)\n  └ Hex: ", ntohs(udp->uh_ulen)); print_bytes_range_hex(l4, 4, 2);
    printf("Checksum: 0x%04X (Bytes 6-7)\n  └ Hex: ", ntohs(udp->uh_sum)); print_bytes_range_hex(l4, 6, 2);
    printf("\n");
}





void inspect_last_session() 
{
    if (aquarium_count == 0) 
    {
        printf("\n[!] No packets captured in last session.\n");
        return;
    }

    // Summary header
    printf("\n=== LAST SESSION: %d packets stored ===\n\n", aquarium_count);
    printf("ID  TIME       LEN  L3_SRC -> L3_DST                      L4_SRC->DST   PROTO\n");
    printf("-------------------------------------------------------------------------------\n");

    for (int i = 0; i < aquarium_count; ++i) 
    {
        char timestr[32];
        time_t sec = packet_aquarium[i]->header.ts.tv_sec;
        struct tm *tm = localtime(&sec);
        strftime(timestr, sizeof(timestr), "%H:%M:%S", tm);

        const u_char *bytes = packet_aquarium[i]->data;
        int caplen = packet_aquarium[i]->header.caplen;

        // Default placeholders
        char l3src[64] = "-", l3dst[64] = "-";
        char l4src[16] = "-", l4dst[16] = "-";
        char proto_str[8] = "-";

        if (caplen >= (int)sizeof(struct ether_header)) {
            const struct ether_header *eth = (const struct ether_header *)bytes;
            uint16_t eth_type = ntohs(eth->ether_type);

            if (eth_type == ETHERTYPE_IP && caplen >= (int)(sizeof(struct ether_header) + sizeof(struct ip))) {
                const struct ip *ip_hdr = (const struct ip *)(bytes + sizeof(struct ether_header));
                inet_ntop(AF_INET, &ip_hdr->ip_src, l3src, sizeof(l3src));
                inet_ntop(AF_INET, &ip_hdr->ip_dst, l3dst, sizeof(l3dst));
                snprintf(proto_str, sizeof(proto_str), "IPv4");
                int l4_off = sizeof(struct ether_header) + ip_hdr->ip_hl * 4;
                int l4_len = caplen - l4_off;
                if (ip_hdr->ip_p == IPPROTO_TCP && l4_len >= (int)sizeof(struct tcphdr)) {
                    const struct tcphdr *tcp = (const struct tcphdr *)(bytes + l4_off);
                    snprintf(l4src, sizeof(l4src), "%u", ntohs(tcp->th_sport));
                    snprintf(l4dst, sizeof(l4dst), "%u", ntohs(tcp->th_dport));
                    snprintf(proto_str, sizeof(proto_str), "TCP");
                } else if (ip_hdr->ip_p == IPPROTO_UDP && l4_len >= (int)sizeof(struct udphdr)) {
                    const struct udphdr *udp = (const struct udphdr *)(bytes + l4_off);
                    snprintf(l4src, sizeof(l4src), "%u", ntohs(udp->uh_sport));
                    snprintf(l4dst, sizeof(l4dst), "%u", ntohs(udp->uh_dport));
                    snprintf(proto_str, sizeof(proto_str), "UDP");
                } else {
                    snprintf(proto_str, sizeof(proto_str), "%u", ip_hdr->ip_p);
                }
            } else if (eth_type == ETHERTYPE_IPV6 && caplen >= (int)(sizeof(struct ether_header) + sizeof(struct ip6_hdr))) {
                const struct ip6_hdr *ip6 = (const struct ip6_hdr *)(bytes + sizeof(struct ether_header));
                inet_ntop(AF_INET6, &ip6->ip6_src, l3src, sizeof(l3src));
                inet_ntop(AF_INET6, &ip6->ip6_dst, l3dst, sizeof(l3dst));
                snprintf(proto_str, sizeof(proto_str), "IPv6");
            } else if (eth_type == ETHERTYPE_ARP && caplen >= (int)(sizeof(struct ether_header) + sizeof(struct arphdr))) {
                snprintf(proto_str, sizeof(proto_str), "ARP");
            }
        }

        printf("%-3d %-8s %-4d %-22s -> %-22s %6s->%-6s %s\n",
               i, timestr, packet_aquarium[i]->header.caplen,
               l3src, l3dst, l4src, l4dst, proto_str);
    }

    printf("\nEnter packet ID to inspect (or 0 to return): ");
    char buf[32];
    if (!fgets(buf, sizeof(buf), stdin)) return;
    int id = atoi(buf);
    if (id <= 0) return;    // treat 0 as return
    if (id < 0 || id >= aquarium_count) 
    {
        printf("[!] Invalid packet ID\n");
        return;
    }

    stored_packet_t *pkt = packet_aquarium[id];
    const u_char *frame = pkt->data;
    int frame_len = pkt->header.caplen;

    // Header box
    printf("\n┌──────────────────────────────────────────────────────── C-SHARK DETAILED PACKET ANALYSIS ────────────────────────────────────────────────────────┐\n");
    printf(" Packet ID: #%d\n", id);
    char timestr[32];
    struct tm *tm = localtime(&pkt->header.ts.tv_sec);
    strftime(timestr, sizeof(timestr), "%H:%M:%S", tm);
    printf(" Timestamp: %s.%06ld\n", timestr, pkt->header.ts.tv_usec);
    printf(" Frame Length: %d bytes\n", frame_len);
    printf(" Captured: %d bytes\n", frame_len);
    printf("└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘\n");

    // Full hex dump
    print_full_hex_dump(frame, frame_len);

    // Layer-by-layer
    // L2
    print_ethernet_details(frame, frame_len);

    // L3
    if (frame_len >= (int)sizeof(struct ether_header)) {
        const struct ether_header *eth = (const struct ether_header *)frame;
        uint16_t eth_type = ntohs(eth->ether_type);
        const u_char *l3 = frame + sizeof(struct ether_header);
        int l3_len = frame_len - sizeof(struct ether_header);

        if (eth_type == ETHERTYPE_IP) {
            print_ipv4_details(l3, l3_len);
            // L4
            if (l3_len >= (int)sizeof(struct ip)) {
                const struct ip *ip4 = (const struct ip *)l3;
                const u_char *l4 = l3 + ip4->ip_hl * 4;
                int l4_len = l3_len - ip4->ip_hl * 4;
                if (ip4->ip_p == IPPROTO_TCP) {
                    print_tcp_details(l4, l4_len);
                    // payload:
                    int hdrlen = ((const struct tcphdr *)l4)->th_off * 4;
                    const u_char *payload = l4 + hdrlen;
                    int payload_len = l4_len - hdrlen;
                    if (payload_len > 0) {
                        printf("📡 APPLICATION DATA (Layer 5-7)\n\n");
                        printf("Payload Length: %d bytes\n", payload_len);
                        printf("Protocol: %s (Port %u)\n", identify_app_protocol(ntohs(((const struct tcphdr *)l4)->th_sport), ntohs(((const struct tcphdr *)l4)->th_dport)),
                               ntohs(((const struct tcphdr *)l4)->th_dport));
                        int dump_len = payload_len > 64 ? 64 : payload_len;
                        printf("First %d bytes of payload:\n", dump_len);
                        print_full_hex_dump(payload, dump_len);
                        if (payload_len > dump_len) {
                            printf("... and %d more bytes\n\n", payload_len - dump_len);
                        }
                    }
                } else if (ip4->ip_p == IPPROTO_UDP) {
                    print_udp_details(l4, l4_len);
                    const u_char *payload = l4 + sizeof(struct udphdr);
                    int payload_len = l4_len - sizeof(struct udphdr);
                    if (payload_len > 0) {
                        printf("📡 APPLICATION DATA (Layer 5-7)\n\n");
                        printf("Payload Length: %d bytes\n", payload_len);
                        printf("Protocol: %s (Port %u)\n", identify_app_protocol(ntohs(((const struct udphdr *)l4)->uh_sport),
                                                                              ntohs(((const struct udphdr *)l4)->uh_dport)),
                               ntohs(((const struct udphdr *)l4)->uh_dport));
                        int dump_len = payload_len > 64 ? 64 : payload_len;
                        print_full_hex_dump(payload, dump_len);
                        if (payload_len > dump_len) {
                            printf("... and %d more bytes\n\n", payload_len - dump_len);
                        }
                    }
                }
            }
        } else if (eth_type == ETHERTYPE_IPV6) {
            print_ipv6_details(l3, l3_len);
            // similar L4 handling for IPv6 could be added (not shown to keep concise)
        } else if (eth_type == ETHERTYPE_ARP) {
            print_arp_details(l3, l3_len);
        } else {
            printf("[!] Unsupported L3 type for detailed decode.\n\n");
        }
    }

    printf("┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐\n");
    printf(" END OF PACKET ANALYSIS\n");
    printf("└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘\n\n");

    printf("Press Enter to continue...");
    fgets(buf, sizeof(buf), stdin); // pause
}



int main()
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigint_handler;
    sa.sa_flags = 0; // No SA_RESTART - let getline be interrupted
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    printf("==============================================\n");
    printf("[C-Shark] The Command-Line Packet Predator\n");
    printf("==============================================\n");
    
    int devcount = 0;
    char **devnames = list_devices_and_get_array(&devcount);
    
    if (!devnames || devcount == 0) 
    {
        fprintf(stderr, "\n[!] No devices found. Make sure you run with sudo.\n");
        return 1;
    }
    
    char *line = NULL;
    size_t len = 0;
    int chosen_index = -1;
    
    while (1) 
    {
        printf("\nSelect an interface to sniff (1-%d): ", devcount);
        ssize_t read_result = getline(&line, &len, stdin);
        if (read_result == -1) 
        {
            if (feof(stdin)) {
                // True EOF (Ctrl+D)
                goto cleanup_and_exit;
            } else {
                // Signal interruption (Ctrl+C) - continue loop
                clearerr(stdin);
                printf("\n");
                continue;
            }
        }
        
        // converts string to a long int
        long v = strtol(line, NULL, 10);
        if (v > 0 && v <= devcount) 
        {
            chosen_index = v - 1;
            break;
        }
        printf("Invalid selection. Please try again.\n");
    }
    
    char *chosen_device = strdup(devnames[chosen_index]);
    printf("\n[C-Shark] Interface '%s' selected.\n", chosen_device);
    
    int running = 1;
    while (running && !exit_requested) 
    {
        printf("\n========================================\n");
        printf("[C-Shark] Main Menu - Interface: %s\n", chosen_device);
        printf("========================================\n");
        printf("  1. Start Sniffing (All Packets)\n");
        printf("  2. Start Sniffing (With Filters)\n");
        printf("  3. Inspect Last Session\n");
        printf("  4. Exit C-Shark\n");
        printf("Enter choice: ");
        
        //ctrl d
        ssize_t read_result = getline(&line, &len, stdin);
        if (read_result == -1) 
        {
            if (feof(stdin)) {
                // True EOF (Ctrl+D)
                printf("\nEOF detected. Exiting.\n");
                break;
            } else {
                // Signal interruption (Ctrl+C) - continue loop
                clearerr(stdin);
                printf("\n");
                continue;
            }
        }
        
        switch (atoi(line)) 
        {
            case 1:
                start_capture_session(chosen_device, NULL);
                break;
            case 2:
                // show_filter_menu_and_capture(chosen_device);
                show_filter_menu_and_capture(chosen_device);
                break;
            case 3:
                // inspect_session();
                inspect_last_session();  // <-- Add this
                break;
            case 4:
                running = 0;
                break;
            default:
                printf("Unknown choice. Please try again.\n");
                break;
        }
    }

cleanup_and_exit:
    free(line);
    free(chosen_device);
    for (int i = 0; i < devcount; ++i) free(devnames[i]);
    free(devnames);
   clear_aquarium();
    
    printf("\n==============================================\n");
    printf("[C-Shark] Shutting down. Happy hunting!\n");
    printf("==============================================\n");

    return 0;
}