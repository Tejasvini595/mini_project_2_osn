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

typedef struct {
    char *device;
    char *filter_exp;
} capture_args_t;

typedef struct {
    struct pcap_pkthdr header;
    u_char *data;
} stored_packet_t;

static stored_packet_t *packet_aquarium[MAX_PACKETS];
static int aquarium_count = 0;



static void sigint_handler(int signum) 
{
    (void)signum;
    if (capture_running) 
    {
        capture_running = 0;
        printf("\n\n[!] Capture stop requested - press Enter to return to menu...\n");
    } 
    else 
    {
        exit_requested = 1;
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
    
    if (count == 0) {
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

    if (h->caplen < sizeof(struct ether_header)) {
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
    switch (eth_type) {
        case ETHERTYPE_IP:   etype_str = "IPv4"; break;
        case ETHERTYPE_IPV6: etype_str = "IPv6"; break;
        case ETHERTYPE_ARP:  etype_str = "ARP";  break;
    }

    printf("L2 (Ethernet): Dst MAC: %s | Src MAC: %s | EtherType: %s (0x%04X)\n",
           dst_mac, src_mac, etype_str, eth_type);

    printf("-----------------------------------------\n");
}


// phase 1.2
void start_capture_session(char *device, char *filter_exp) 
{
    if (capture_running) {
        printf("Capture already in progress.\n");
        return;
    }

    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *handle = pcap_open_live(device, BUFSIZ, 1, 1000, errbuf);
    if (!handle) {
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

        if (r > 0 && FD_ISSET(fd_stdin, &readfds)) {
            char buf[8];
            if (!fgets(buf, sizeof(buf), stdin)) {
                // EOF (Ctrl+D)
                printf("\n[!] Ctrl+D detected - exiting...\n");
                exit_requested = 1;
                break;
            }
        }
        int ret = pcap_dispatch(handle, 1, packet_handler, NULL);
        if (ret < 0) {
            fprintf(stderr, "pcap_dispatch error: %s\n", pcap_geterr(handle));
            break;
        }
    }

    pcap_close(handle);

    if (!exit_requested) {
        printf("\n===========================================\n");
        printf("[C-Shark] Capture stopped\n");
        printf("Total packets captured: %lu\n", packet_counter);
        printf("===========================================\n");
    }
}



int main()
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigint_handler;
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
        if (getline(&line, &len, stdin) == -1) 
        goto cleanup_and_exit;
        
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
        if (getline(&line, &len, stdin) == -1) 
        {
            printf("\nEOF detected. Exiting.\n");
            break;
        }
        
        switch (atoi(line)) 
        {
            case 1:
                start_capture_session(chosen_device, NULL);
                break;
            case 2:
                // show_filter_menu_and_capture(chosen_device);
                break;
            case 3:
                // inspect_session();
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
   // clear_aquarium();
    
    printf("\n==============================================\n");
    printf("[C-Shark] Shutting down. Happy hunting!\n");
    printf("==============================================\n");

    return 0;
}