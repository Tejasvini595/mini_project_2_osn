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

/* ================================================================= */
/* =================== HELPER FUNCTIONS ============================ */
/* ================================================================= */

void print_hex_ascii_line(const u_char *payload, int len, int offset) {
    int i, gap;
    const u_char *ch;
    printf("  ");
    for(i = 0; i < len; i++) {
        printf("%02x ", payload[i]);
        if (i == 7) printf(" ");
    }
    if (len < 8) printf(" ");
    if (len < 16) {
        gap = 16 - len;
        for (i = 0; i < gap; i++) printf("   ");
    }
    printf("   ");
    ch = payload;
    for(i = 0; i < len; i++) {
        if (isprint(*ch)) printf("%c", *ch);
        else printf(".");
        ch++;
    }
    printf("\n");
}

void print_payload(const u_char *payload, int len) {
    int len_rem = len;
    int line_width = 16;
    int line_len;
    int offset = 0;
    const u_char *ch = payload;

    if (len <= 0) return;
    if (len > 64) len_rem = 64;
    else len_rem = len;

    printf("Data (first %d bytes):\n", len_rem);
    while(len_rem > 0) {
        line_len = (len_rem < line_width) ? len_rem : line_width; 
        print_hex_ascii_line(ch, line_len, offset);
        len_rem = len_rem - line_len;
        ch = ch + line_len;
        offset = offset + line_width;
    }
}

void full_hex_dump(const char* title, const u_char *data, int len) {
    printf("\n--- %s (%d bytes) ---\n", title, len);
    for (int i = 0; i < len; i += 16) {
        printf("  0x%04x: ", i);
        for (int j = 0; j < 16; j++)
            if (i + j < len) printf("%02x ", data[i + j]); 
            else printf("   ");
        printf(" ");
        for (int j = 0; j < 16; j++)
            if (i + j < len) printf("%c", isprint(data[i + j]) ? data[i + j] : '.');
        printf("\n");
    }
}

void print_header_hex(const char* title, const u_char* data, int len) {
    printf("    %s Raw Hex (%d bytes): ", title, len);
    for(int i = 0; i < len && i < 64; ++i) printf("%02x ", data[i]);
    if (len > 64) printf("...");
    printf("\n");
}

const char* get_port_service(uint16_t port) {
    switch(port) {
        case 80: return "HTTP";
        case 443: return "HTTPS";
        case 53: return "DNS";
        case 22: return "SSH";
        case 21: return "FTP";
        case 25: return "SMTP";
        case 110: return "POP3";
        case 143: return "IMAP";
        case 3306: return "MySQL";
        case 5432: return "PostgreSQL";
        default: return NULL;
    }
}

/* ================================================================= */
/* =================== LIVE DISPLAY FUNCTIONS ====================== */
/* ================================================================= */

void display_tcp_live(const struct tcphdr *tcp_hdr, int hdr_len, const u_char *payload, int payload_len, uint16_t src_port, uint16_t dst_port) {
    const char *src_service = get_port_service(src_port);
    const char *dst_service = get_port_service(dst_port);
    
    printf("L4 (TCP): Src Port: %u%s%s%s | Dst Port: %u%s%s%s | Seq: %u | Ack: %u | Flags: [",
           src_port, src_service ? " (" : "", src_service ? src_service : "", src_service ? ")" : "",
           dst_port, dst_service ? " (" : "", dst_service ? dst_service : "", dst_service ? ")" : "",
           ntohl(tcp_hdr->th_seq), ntohl(tcp_hdr->th_ack));
    
    if (tcp_hdr->th_flags & TH_SYN) printf("SYN");
    if (tcp_hdr->th_flags & TH_ACK) printf("%sACK", (tcp_hdr->th_flags & TH_SYN) ? "," : "");
    if (tcp_hdr->th_flags & TH_FIN) printf(",FIN");
    if (tcp_hdr->th_flags & TH_RST) printf(",RST");
    if (tcp_hdr->th_flags & TH_PUSH) printf(",PSH");
    if (tcp_hdr->th_flags & TH_URG) printf(",URG");
    printf("]\nWindow: %u | Checksum: 0x%04X | Header Length: %d bytes\n",
           ntohs(tcp_hdr->th_win), ntohs(tcp_hdr->th_sum), hdr_len);
    
    if (payload_len > 0) {
        const char *protocol = "Unknown";
        if (src_port == 80 || dst_port == 80) protocol = "HTTP";
        else if (src_port == 443 || dst_port == 443) protocol = "HTTPS/TLS";
        
        printf("L7 (Payload): Identified as %s on port %u - %d bytes\n", protocol, 
               (dst_port == 80 || dst_port == 443) ? dst_port : src_port, payload_len);
        print_payload(payload, payload_len);
    }
}

void display_udp_live(const struct udphdr *udp_hdr, const u_char *payload, int payload_len, uint16_t src_port, uint16_t dst_port) {
    const char *src_service = get_port_service(src_port);
    const char *dst_service = get_port_service(dst_port);
    
    printf("L4 (UDP): Src Port: %u%s%s%s | Dst Port: %u%s%s%s | Length: %u | Checksum: 0x%04X\n",
           src_port, src_service ? " (" : "", src_service ? src_service : "", src_service ? ")" : "",
           dst_port, dst_service ? " (" : "", dst_service ? dst_service : "", dst_service ? ")" : "",
           ntohs(udp_hdr->uh_ulen), ntohs(udp_hdr->uh_sum));
    
    if (payload_len > 0) {
        const char *protocol = "Unknown";
        if (src_port == 53 || dst_port == 53) protocol = "DNS";
        
        printf("L7 (Payload): Identified as %s on port %u - %d bytes\n", protocol,
               (dst_port == 53) ? dst_port : src_port, payload_len);
        print_payload(payload, payload_len);
    }
}

void display_ipv4_live(const u_char *packet, int size) {
    if (size < sizeof(struct ip)) return;
    const struct ip *ip_hdr = (const struct ip *)packet;
    int hdr_len = ip_hdr->ip_hl * 4;
    
    char src_ip[INET_ADDRSTRLEN], dst_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &(ip_hdr->ip_src), src_ip, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &(ip_hdr->ip_dst), dst_ip, INET_ADDRSTRLEN);
    
    const char *proto_name = "Unknown";
    if (ip_hdr->ip_p == IPPROTO_TCP) proto_name = "TCP";
    else if (ip_hdr->ip_p == IPPROTO_UDP) proto_name = "UDP";
    else if (ip_hdr->ip_p == IPPROTO_ICMP) proto_name = "ICMP";
    
    printf("L3 (IPv4): Src IP: %s | Dst IP: %s | Protocol: %s (%u) | TTL: %u\n",
           src_ip, dst_ip, proto_name, ip_hdr->ip_p, ip_hdr->ip_ttl);
    printf("ID: 0x%04X | Total Length: %u | Header Length: %d bytes\n",
           ntohs(ip_hdr->ip_id), ntohs(ip_hdr->ip_len), hdr_len);
    
    const u_char *next_packet = packet + hdr_len;
    int next_size = size - hdr_len;
    int payload_len = ntohs(ip_hdr->ip_len) - hdr_len;
    
    if (ip_hdr->ip_p == IPPROTO_TCP && next_size >= sizeof(struct tcphdr)) {
        const struct tcphdr *tcp_hdr = (const struct tcphdr *)next_packet;
        int tcp_hdr_len = tcp_hdr->th_off * 4;
        int tcp_payload_len = payload_len - tcp_hdr_len;
        const u_char *tcp_payload = next_packet + tcp_hdr_len;
        display_tcp_live(tcp_hdr, tcp_hdr_len, tcp_payload, tcp_payload_len, 
                        ntohs(tcp_hdr->th_sport), ntohs(tcp_hdr->th_dport));
    } else if (ip_hdr->ip_p == IPPROTO_UDP && next_size >= sizeof(struct udphdr)) {
        const struct udphdr *udp_hdr = (const struct udphdr *)next_packet;
        int udp_payload_len = ntohs(udp_hdr->uh_ulen) - sizeof(struct udphdr);
        const u_char *udp_payload = next_packet + sizeof(struct udphdr);
        display_udp_live(udp_hdr, udp_payload, udp_payload_len,
                        ntohs(udp_hdr->uh_sport), ntohs(udp_hdr->uh_dport));
    }
}

void display_ipv6_live(const u_char *packet, int size) {
    if (size < sizeof(struct ip6_hdr)) return;
    const struct ip6_hdr *ip6_hdr = (const struct ip6_hdr *)packet;
    
    char src_ip[INET6_ADDRSTRLEN], dst_ip[INET6_ADDRSTRLEN];
    inet_ntop(AF_INET6, &(ip6_hdr->ip6_src), src_ip, INET6_ADDRSTRLEN);
    inet_ntop(AF_INET6, &(ip6_hdr->ip6_dst), dst_ip, INET6_ADDRSTRLEN);
    
    uint8_t next_hdr = ip6_hdr->ip6_nxt;
    const char *proto_name = "Unknown";
    if (next_hdr == IPPROTO_TCP) proto_name = "TCP";
    else if (next_hdr == IPPROTO_UDP) proto_name = "UDP";
    else if (next_hdr == IPPROTO_ICMPV6) proto_name = "ICMPv6";
    
    uint32_t flow = ntohl(ip6_hdr->ip6_flow);
    uint8_t traffic_class = (flow >> 20) & 0xFF;
    uint32_t flow_label = flow & 0xFFFFF;
    
    printf("L3 (IPv6): Src IP: %s | Dst IP: %s\n", src_ip, dst_ip);
    printf("Next Header: %s (%u) | Hop Limit: %u | Traffic Class: %u | Flow Label: 0x%05X | Payload Length: %u\n",
           proto_name, next_hdr, ip6_hdr->ip6_hlim, traffic_class, flow_label, ntohs(ip6_hdr->ip6_plen));
    
    const u_char *next_packet = packet + sizeof(struct ip6_hdr);
    int next_size = size - sizeof(struct ip6_hdr);
    int payload_len = ntohs(ip6_hdr->ip6_plen);
    
    if (next_hdr == IPPROTO_TCP && next_size >= sizeof(struct tcphdr)) {
        const struct tcphdr *tcp_hdr = (const struct tcphdr *)next_packet;
        int tcp_hdr_len = tcp_hdr->th_off * 4;
        int tcp_payload_len = payload_len - tcp_hdr_len;
        const u_char *tcp_payload = next_packet + tcp_hdr_len;
        display_tcp_live(tcp_hdr, tcp_hdr_len, tcp_payload, tcp_payload_len,
                        ntohs(tcp_hdr->th_sport), ntohs(tcp_hdr->th_dport));
    } else if (next_hdr == IPPROTO_UDP && next_size >= sizeof(struct udphdr)) {
        const struct udphdr *udp_hdr = (const struct udphdr *)next_packet;
        int udp_payload_len = ntohs(udp_hdr->uh_ulen) - sizeof(struct udphdr);
        const u_char *udp_payload = next_packet + sizeof(struct udphdr);
        display_udp_live(udp_hdr, udp_payload, udp_payload_len,
                        ntohs(udp_hdr->uh_sport), ntohs(udp_hdr->uh_dport));
    }
}

void display_arp_live(const u_char *packet, int size) {
    if (size < sizeof(struct arphdr)) return;
    const struct arphdr *arp_hdr = (const struct arphdr *)packet;
    
    const char *op_str = "Unknown";
    uint16_t op = ntohs(arp_hdr->ar_op);
    if (op == ARPOP_REQUEST) op_str = "Request";
    else if (op == ARPOP_REPLY) op_str = "Reply";
    
    printf("L3 (ARP): Operation: %s (%u)\n", op_str, op);
    printf("HW Type: %u | Proto Type: 0x%04X | HW Len: %u | Proto Len: %u\n",
           ntohs(arp_hdr->ar_hrd), ntohs(arp_hdr->ar_pro), 
           arp_hdr->ar_hln, arp_hdr->ar_pln);
    
    if (size >= sizeof(struct arphdr) + 2 * arp_hdr->ar_hln + 2 * arp_hdr->ar_pln) {
        const u_char *arp_data = packet + sizeof(struct arphdr);
        const u_char *sender_mac = arp_data;
        const u_char *sender_ip = arp_data + arp_hdr->ar_hln;
        const u_char *target_mac = arp_data + arp_hdr->ar_hln + arp_hdr->ar_pln;
        const u_char *target_ip = arp_data + 2 * arp_hdr->ar_hln + arp_hdr->ar_pln;
        
        char sender_ip_str[INET_ADDRSTRLEN], target_ip_str[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, sender_ip, sender_ip_str, INET_ADDRSTRLEN);
        inet_ntop(AF_INET, target_ip, target_ip_str, INET_ADDRSTRLEN);
        
        printf("Sender IP: %s | Target IP: %s\n", sender_ip_str, target_ip_str);
        printf("Sender MAC: %02x:%02x:%02x:%02x:%02x:%02x | Target MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
               sender_mac[0], sender_mac[1], sender_mac[2], sender_mac[3], sender_mac[4], sender_mac[5],
               target_mac[0], target_mac[1], target_mac[2], target_mac[3], target_mac[4], target_mac[5]);
    }
}

/* ================================================================= */
/* =================== INSPECTION FUNCTIONS ======================== */
/* ================================================================= */

void inspect_tcp(const u_char *packet, int size, int total_ip_len) {
    printf("\n--- Layer 4: TCP Header ---\n");
    if (size < sizeof(struct tcphdr)) { printf("    Malformed Packet\n"); return; }
    const struct tcphdr *tcp_hdr = (const struct tcphdr *)packet;
    int hdr_len = tcp_hdr->th_off * 4;
    print_header_hex("TCP", packet, hdr_len);

    uint16_t src_port = ntohs(tcp_hdr->th_sport);
    uint16_t dst_port = ntohs(tcp_hdr->th_dport);
    const char *src_service = get_port_service(src_port);
    const char *dst_service = get_port_service(dst_port);

    printf("    Source Port: %u%s%s%s | Destination Port: %u%s%s%s\n",
           src_port, src_service ? " (" : "", src_service ? src_service : "", src_service ? ")" : "",
           dst_port, dst_service ? " (" : "", dst_service ? dst_service : "", dst_service ? ")" : "");
    printf("    Sequence Number: %u\n", ntohl(tcp_hdr->th_seq));
    printf("    Acknowledgement Number: %u\n", ntohl(tcp_hdr->th_ack));
    printf("    Header Length: %d bytes | Flags: [", hdr_len);
    if (tcp_hdr->th_flags & TH_SYN) printf("SYN ");
    if (tcp_hdr->th_flags & TH_ACK) printf("ACK ");
    if (tcp_hdr->th_flags & TH_FIN) printf("FIN ");
    if (tcp_hdr->th_flags & TH_RST) printf("RST ");
    if (tcp_hdr->th_flags & TH_PUSH) printf("PSH ");
    if (tcp_hdr->th_flags & TH_URG) printf("URG ");
    printf("]\n");
    printf("    Window Size: %u | Checksum: 0x%04X | Urgent Pointer: %u\n",
           ntohs(tcp_hdr->th_win), ntohs(tcp_hdr->th_sum), ntohs(tcp_hdr->th_urp));

    int payload_len = total_ip_len - hdr_len;
    if (payload_len > 0) {
        full_hex_dump("L7 Payload", packet + hdr_len, payload_len);
    }
}

void inspect_udp(const u_char *packet, int size) {
    printf("\n--- Layer 4: UDP Header ---\n");
    if (size < sizeof(struct udphdr)) { printf("    Malformed Packet\n"); return; }
    const struct udphdr *udp_hdr = (const struct udphdr *)packet;
    print_header_hex("UDP", packet, sizeof(struct udphdr));
    
    uint16_t src_port = ntohs(udp_hdr->uh_sport);
    uint16_t dst_port = ntohs(udp_hdr->uh_dport);
    const char *src_service = get_port_service(src_port);
    const char *dst_service = get_port_service(dst_port);
    
    printf("    Source Port: %u%s%s%s | Destination Port: %u%s%s%s\n",
           src_port, src_service ? " (" : "", src_service ? src_service : "", src_service ? ")" : "",
           dst_port, dst_service ? " (" : "", dst_service ? dst_service : "", dst_service ? ")" : "");
    printf("    Length: %u | Checksum: 0x%04X\n", ntohs(udp_hdr->uh_ulen), ntohs(udp_hdr->uh_sum));

    int payload_len = ntohs(udp_hdr->uh_ulen) - sizeof(struct udphdr);
    if (payload_len > 0) {
        full_hex_dump("L7 Payload", packet + sizeof(struct udphdr), payload_len);
    }
}

void inspect_ipv4(const u_char *packet, int size) {
    printf("\n--- Layer 3: IPv4 Header ---\n");
    if (size < sizeof(struct ip)) { printf("    Malformed Packet\n"); return; }
    const struct ip *ip_hdr = (const struct ip *)packet;
    int hdr_len = ip_hdr->ip_hl * 4;
    print_header_hex("IPv4", packet, hdr_len);

    char src_ip[INET_ADDRSTRLEN], dst_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &(ip_hdr->ip_src), src_ip, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &(ip_hdr->ip_dst), dst_ip, INET_ADDRSTRLEN);
    uint16_t flags_offset = ntohs(ip_hdr->ip_off);

    printf("    Version: %u | Header Length: %d bytes | Differentiated Services: 0x%02x\n",
           ip_hdr->ip_v, hdr_len, ip_hdr->ip_tos);
    printf("    Total Length: %u | Identification: 0x%04X\n",
           ntohs(ip_hdr->ip_len), ntohs(ip_hdr->ip_id));
    printf("    Flags: [ %s%s] | Fragment Offset: %d\n",
           (flags_offset & IP_DF) ? "DF " : "", (flags_offset & IP_MF) ? "MF " : "",
           flags_offset & IP_OFFMASK);
    printf("    Time to Live: %u | Protocol: %u | Header Checksum: 0x%04X\n",
           ip_hdr->ip_ttl, ip_hdr->ip_p, ntohs(ip_hdr->ip_sum));
    printf("    Source IP: %s\n", src_ip);
    printf("    Destination IP: %s\n", dst_ip);

    const u_char *next_packet = packet + hdr_len;
    int next_size = size - hdr_len;
    int next_total_len = ntohs(ip_hdr->ip_len) - hdr_len;

    if (ip_hdr->ip_p == IPPROTO_TCP) inspect_tcp(next_packet, next_size, next_total_len);
    else if (ip_hdr->ip_p == IPPROTO_UDP) inspect_udp(next_packet, next_size);
}

void inspect_ipv6(const u_char *packet, int size) {
    printf("\n--- Layer 3: IPv6 Header ---\n");
    if (size < sizeof(struct ip6_hdr)) { printf("    Malformed Packet\n"); return; }
    const struct ip6_hdr *ip6_hdr = (const struct ip6_hdr *)packet;
    print_header_hex("IPv6", packet, sizeof(struct ip6_hdr));

    char src_ip[INET6_ADDRSTRLEN], dst_ip[INET6_ADDRSTRLEN];
    inet_ntop(AF_INET6, &(ip6_hdr->ip6_src), src_ip, INET6_ADDRSTRLEN);
    inet_ntop(AF_INET6, &(ip6_hdr->ip6_dst), dst_ip, INET6_ADDRSTRLEN);

    uint32_t flow = ntohl(ip6_hdr->ip6_flow);
    uint8_t version = (flow >> 28) & 0xF;
    uint8_t traffic_class = (flow >> 20) & 0xFF;
    uint32_t flow_label = flow & 0xFFFFF;

    printf("    Version: %u | Traffic Class: %u | Flow Label: 0x%05X\n",
           version, traffic_class, flow_label);
    printf("    Payload Length: %u | Next Header: %u | Hop Limit: %u\n",
           ntohs(ip6_hdr->ip6_plen), ip6_hdr->ip6_nxt, ip6_hdr->ip6_hlim);
    printf("    Source IP: %s\n", src_ip);
    printf("    Destination IP: %s\n", dst_ip);

    const u_char *next_packet = packet + sizeof(struct ip6_hdr);
    int next_size = size - sizeof(struct ip6_hdr);
    int next_total_len = ntohs(ip6_hdr->ip6_plen);

    if (ip6_hdr->ip6_nxt == IPPROTO_TCP) inspect_tcp(next_packet, next_size, next_total_len);
    else if (ip6_hdr->ip6_nxt == IPPROTO_UDP) inspect_udp(next_packet, next_size);
}

void inspect_arp(const u_char *packet, int size) {
    printf("\n--- Layer 3: ARP Header ---\n");
    if (size < sizeof(struct arphdr)) { printf("    Malformed Packet\n"); return; }
    const struct arphdr *arp_hdr = (const struct arphdr *)packet;
    print_header_hex("ARP", packet, sizeof(struct arphdr));

    const char *op_str = "Unknown";
    uint16_t op = ntohs(arp_hdr->ar_op);
    if (op == ARPOP_REQUEST) op_str = "Request";
    else if (op == ARPOP_REPLY) op_str = "Reply";

    printf("    Hardware Type: %u | Protocol Type: 0x%04X\n",
           ntohs(arp_hdr->ar_hrd), ntohs(arp_hdr->ar_pro));
    printf("    Hardware Length: %u | Protocol Length: %u\n",
           arp_hdr->ar_hln, arp_hdr->ar_pln);
    printf("    Operation: %s (%u)\n", op_str, op);

    if (size >= sizeof(struct arphdr) + 2 * arp_hdr->ar_hln + 2 * arp_hdr->ar_pln) {
        const u_char *arp_data = packet + sizeof(struct arphdr);
        const u_char *sender_mac = arp_data;
        const u_char *sender_ip = arp_data + arp_hdr->ar_hln;
        const u_char *target_mac = arp_data + arp_hdr->ar_hln + arp_hdr->ar_pln;
        const u_char *target_ip = arp_data + 2 * arp_hdr->ar_hln + arp_hdr->ar_pln;

        char sender_ip_str[INET_ADDRSTRLEN], target_ip_str[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, sender_ip, sender_ip_str, INET_ADDRSTRLEN);
        inet_ntop(AF_INET, target_ip, target_ip_str, INET_ADDRSTRLEN);

        printf("    Sender MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
               sender_mac[0], sender_mac[1], sender_mac[2], sender_mac[3], sender_mac[4], sender_mac[5]);
        printf("    Sender IP: %s\n", sender_ip_str);
        printf("    Target MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
               target_mac[0], target_mac[1], target_mac[2], target_mac[3], target_mac[4], target_mac[5]);
        printf("    Target IP: %s\n", target_ip_str);
    }
}

void get_packet_summary(const stored_packet_t *sp, char *buf, size_t buf_len) {

    if (sp->header.caplen < sizeof(struct ether_header)) {  // ADD THIS CHECK
        snprintf(buf, buf_len, "Malformed packet");
        return;
    }
    const struct ether_header *eth = (const struct ether_header *)sp->data;
    uint16_t type = ntohs(eth->ether_type);
    const u_char *next = sp->data + sizeof(struct ether_header);

       if (type == ETHERTYPE_IP && sp->header.caplen >= sizeof(struct ether_header) + sizeof(struct ip)) {  // ADD SIZE CHECKS
        const struct ip *ip_hdr = (const struct ip *)next;
        char src_ip[INET_ADDRSTRLEN], dst_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(ip_hdr->ip_src), src_ip, sizeof(src_ip));
        inet_ntop(AF_INET, &(ip_hdr->ip_dst), dst_ip, sizeof(dst_ip));
        if (ip_hdr->ip_p == IPPROTO_TCP && sp->header.caplen >= sizeof(struct ether_header) + ip_hdr->ip_hl * 4 + sizeof(struct tcphdr)) {  // ADD SIZE CHECK
            const struct tcphdr *tcp = (const struct tcphdr *)(next + ip_hdr->ip_hl * 4);
            snprintf(buf, buf_len, "IPv4 TCP %s:%u -> %s:%u", src_ip, ntohs(tcp->th_sport), dst_ip, ntohs(tcp->th_dport));
        } else if (ip_hdr->ip_p == IPPROTO_UDP && sp->header.caplen >= sizeof(struct ether_header) + ip_hdr->ip_hl * 4 + sizeof(struct udphdr)) {
            const struct udphdr *udp = (const struct udphdr *)(next + ip_hdr->ip_hl * 4);
            snprintf(buf, buf_len, "IPv4 UDP %s:%u -> %s:%u", src_ip, ntohs(udp->uh_sport), dst_ip, ntohs(udp->uh_dport));
        } else {
            snprintf(buf, buf_len, "IPv4 Proto %d %s -> %s", ip_hdr->ip_p, src_ip, dst_ip);
        }
    } else if (type == ETHERTYPE_ARP) {
        snprintf(buf, buf_len, "ARP Packet");
    } else if (type == ETHERTYPE_IPV6) {
        const struct ip6_hdr *ip6_hdr = (const struct ip6_hdr *)next;
        char src_ip[INET6_ADDRSTRLEN], dst_ip[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &(ip6_hdr->ip6_src), src_ip, sizeof(src_ip));
        inet_ntop(AF_INET6, &(ip6_hdr->ip6_dst), dst_ip, sizeof(dst_ip));
        if (ip6_hdr->ip6_nxt == IPPROTO_TCP) {
            const struct tcphdr *tcp = (const struct tcphdr *)(next + sizeof(struct ip6_hdr));
            snprintf(buf, buf_len, "IPv6 TCP [%s]:%u -> [%s]:%u", src_ip, ntohs(tcp->th_sport), dst_ip, ntohs(tcp->th_dport));
        } else if (ip6_hdr->ip6_nxt == IPPROTO_UDP) {
            const struct udphdr *udp = (const struct udphdr *)(next + sizeof(struct ip6_hdr));
            snprintf(buf, buf_len, "IPv6 UDP [%s]:%u -> [%s]:%u", src_ip, ntohs(udp->uh_sport), dst_ip, ntohs(udp->uh_dport));
        } else {
            snprintf(buf, buf_len, "IPv6 Proto %d", ip6_hdr->ip6_nxt);
        }
    } else {
        snprintf(buf, buf_len, "Unknown EtherType 0x%04x", type);
    }
}

/* ================================================================= */
/* =================== PACKET HANDLER ============================== */
/* ================================================================= */

void packet_handler(u_char *user, const struct pcap_pkthdr *h, const u_char *bytes) {
    (void)user;
    
    // Store packet in aquarium
    if (aquarium_count < MAX_PACKETS) {
        stored_packet_t *sp = malloc(sizeof(stored_packet_t));
        if (sp) {
            sp->header = *h;
            sp->data = malloc(h->caplen);
            if (sp->data) {
                memcpy(sp->data, bytes, h->caplen);
                packet_aquarium[aquarium_count++] = sp;
            } else {
                free(sp);
            }
        }
    }
    
    // Display packet live
    packet_counter++;
    printf("\n-----------------------------------------\n");
    printf("Packet #%lu | Timestamp: %ld.%06ld | Length: %u bytes\n",
           packet_counter, (long)h->ts.tv_sec, (long)h->ts.tv_usec, h->caplen);
    
    if (h->caplen < sizeof(struct ether_header)) {
        printf("Packet too small\n");
        return;
    }
    
    const struct ether_header *eth = (const struct ether_header *)bytes;
    printf("L2 (Ethernet): Dst MAC: %02X:%02X:%02X:%02X:%02X:%02X | Src MAC: %02X:%02X:%02X:%02X:%02X:%02X |\n",
           eth->ether_dhost[0], eth->ether_dhost[1], eth->ether_dhost[2],
           eth->ether_dhost[3], eth->ether_dhost[4], eth->ether_dhost[5],
           eth->ether_shost[0], eth->ether_shost[1], eth->ether_shost[2],
           eth->ether_shost[3], eth->ether_shost[4], eth->ether_shost[5]);
    
    uint16_t ether_type = ntohs(eth->ether_type);
    const u_char *payload = bytes + sizeof(struct ether_header);
    int payload_len = h->caplen - sizeof(struct ether_header);
    
    if (ether_type == ETHERTYPE_IP) {
        printf("EtherType: IPv4 (0x%04X)\n", ether_type);
        display_ipv4_live(payload, payload_len);
    } else if (ether_type == ETHERTYPE_IPV6) {
        printf("EtherType: IPv6 (0x%04X)\n", ether_type);
        display_ipv6_live(payload, payload_len);
    } else if (ether_type == ETHERTYPE_ARP) {
        printf("EtherType: ARP (0x%04X)\n", ether_type);
        display_arp_live(payload, payload_len);
    } else {
        printf("EtherType: Unknown (0x%04X)\n", ether_type);
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
        printf("\n\n[!] Capture stop requested - press Enter to return to menu...\n");
    } else {
        exit_requested = 1;
    }
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
        if (pcap_compile(handle, &fp, args->filter_exp, 0, PCAP_NETMASK_UNKNOWN) == -1) {
            fprintf(stderr, "Error compiling filter '%s': %s\n", args->filter_exp, pcap_geterr(handle));
            pcap_close(handle);
            capture_running = 0;
            return NULL;
        }
        if (pcap_setfilter(handle, &fp) == -1) {
            fprintf(stderr, "Error setting filter '%s': %s\n", args->filter_exp, pcap_geterr(handle));
            pcap_freecode(&fp);
            pcap_close(handle);
            capture_running = 0;
            return NULL;
        }
        pcap_freecode(&fp);
    }
    
    pthread_mutex_lock(&global_handle_lock);
    global_handle = handle;
    pthread_mutex_unlock(&global_handle_lock);
    
    printf("\n===========================================\n");
    printf("[C-Shark] Capturing on '%s'\n", args->device);
    printf("Filter: %s\n", args->filter_exp ? args->filter_exp : "none (all packets)");
    printf("Press Ctrl+C to stop capture\n");
    printf("===========================================\n");
     printf("Waiting for packets...\n");
    fflush(stdout);
    
    capture_running = 1;
    packet_counter = 0;

     int loop_count = 0;  
    
    while (capture_running) {
        int result = pcap_dispatch(handle, 10, packet_handler, NULL);
        if (result < 0) {
            fprintf(stderr, "pcap_dispatch error: %s\n", pcap_geterr(handle));
            break;
        }

        if (result == 0) 
        {
            loop_count++;
            if (loop_count % 100 == 0 && packet_counter == 0) 
            {
                printf(".");
                fflush(stdout);
            }
        } 
        else 
        {
            loop_count = 0;
        }
        usleep(10000);
    }
    
    pthread_mutex_lock(&global_handle_lock);
    pcap_close(handle);
    global_handle = NULL;
    pthread_mutex_unlock(&global_handle_lock);
    
    return NULL;
}

void clear_aquarium() {
    for (int i = 0; i < aquarium_count; i++) {
        free(packet_aquarium[i]->data);
        free(packet_aquarium[i]);
    }
    aquarium_count = 0;
}

void start_capture_session(char *device, char *filter_exp) 
{
    if (capture_running) 
    {
        printf("Capture already in progress.\n");
        return;
    }
    
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
    
    // Wait for user input to stop
    char *line = NULL;
    size_t len = 0;
    while (capture_running && !exit_requested) {
        if (getline(&line, &len, stdin) == -1) {
            if (feof(stdin)) {
                printf("\nEOF detected. Exiting program.\n");
                exit_requested = 1;
            } else if (errno != EINTR) {
                perror("getline");
                exit_requested = 1;
            }
            capture_running = 0;
        } else {
            // Any input will stop capture
            capture_running = 0;
        }
    }
    free(line);
    
    pthread_join(cap_thread, NULL);
    free(args->device);
    free(args->filter_exp);
    free(args);
    
    if (!exit_requested) {
        printf("\n===========================================\n");
        printf("[C-Shark] Capture stopped\n");
        printf("Total packets captured: %lu\n", packet_counter);
        printf("Packets stored in aquarium: %d\n", aquarium_count);
        printf("===========================================\n");
    }
}

void show_filter_menu_and_capture(char *device) {
    printf("\n--- Select a Filter ---\n");
    printf("  1. HTTP\n");
    printf("  2. HTTPS\n");
    printf("  3. DNS\n");
    printf("  4. ARP\n");
    printf("  5. TCP\n");
    printf("  6. UDP\n");
    printf("  0. Back\n");
    printf("Enter choice: ");
    
    char *line = NULL;
    size_t len = 0;
    if (getline(&line, &len, stdin) == -1) {
        free(line);
        return;
    }
    
    char *filter_str = NULL;
    switch (atoi(line)) {
        case 1: filter_str = "tcp port 80"; break;
        case 2: filter_str = "tcp port 443"; break;
        case 3: filter_str = "udp port 53"; break;
        case 4: filter_str = "arp"; break;
        case 5: filter_str = "tcp"; break;
        case 6: filter_str = "udp"; break;
        case 0: free(line); return;
        default: printf("Invalid choice.\n"); free(line); return;
    }
    free(line);
    
    start_capture_session(device, filter_str);
}

void inspect_session() {
    if (aquarium_count == 0) {
        printf("\n[!] No session captured yet. Use options 1 or 2 first.\n");
        return;
    }
    
    printf("\n========================================\n");
    printf("       Stored Packets Summary\n");
    printf("========================================\n");
    printf("%-6s | %-26s | %-6s | %s\n", "ID", "Timestamp", "Length", "Summary");
    printf("-------+----------------------------+--------+------------------------------------------\n");
    
    char summary_buf[128];
    for (int i = 0; i < aquarium_count; i++) {
        get_packet_summary(packet_aquarium[i], summary_buf, sizeof(summary_buf));
        char time_buf[20];
        time_t sec = packet_aquarium[i]->header.ts.tv_sec;
        strftime(time_buf, sizeof(time_buf), "%Y-%m-%d %H:%M:%S", localtime(&sec));
        printf("#%-5d | %s.%06ld | %-6u | %s\n",
               i + 1, time_buf, (long)packet_aquarium[i]->header.ts.tv_usec,
               packet_aquarium[i]->header.caplen, summary_buf);
    }
    
    char *line = NULL;
    size_t len = 0;
    while (1) {
        printf("\nEnter Packet ID to inspect (1-%d), or 0 to return: ", aquarium_count);
        if (getline(&line, &len, stdin) == -1) break;
        
        int id = atoi(line);
        if (id == 0) break;
        
        if (id > 0 && id <= aquarium_count) {
            stored_packet_t *sp = packet_aquarium[id - 1];
            
            printf("\n========================================\n");
            printf("   DETAILED PACKET INSPECTION #%d\n", id);
            printf("========================================\n");
            
            full_hex_dump("Full Packet Frame", sp->data, sp->header.caplen);
            
            const struct ether_header *eth = (const struct ether_header *)sp->data;
            uint16_t type = ntohs(eth->ether_type);
            const u_char *next = sp->data + sizeof(struct ether_header);
            
            printf("\n--- Layer 2: Ethernet Header ---\n");
            print_header_hex("Ethernet", sp->data, sizeof(struct ether_header));
            printf("    Destination MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
                   eth->ether_dhost[0], eth->ether_dhost[1], eth->ether_dhost[2],
                   eth->ether_dhost[3], eth->ether_dhost[4], eth->ether_dhost[5]);
            printf("    Source MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
                   eth->ether_shost[0], eth->ether_shost[1], eth->ether_shost[2],
                   eth->ether_shost[3], eth->ether_shost[4], eth->ether_shost[5]);
            printf("    EtherType: 0x%04x\n", type);
            
            if (type == ETHERTYPE_IP) {
                inspect_ipv4(next, sp->header.caplen - sizeof(struct ether_header));
            } else if (type == ETHERTYPE_IPV6) {
                inspect_ipv6(next, sp->header.caplen - sizeof(struct ether_header));
            } else if (type == ETHERTYPE_ARP) {
                inspect_arp(next, sp->header.caplen - sizeof(struct ether_header));
            } else {
                printf("\nUnknown or unsupported EtherType\n");
            }
            
            printf("\n========================================\n");
        } else {
            printf("Invalid ID.\n");
        }
    }
    free(line);
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


int main(void) 
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