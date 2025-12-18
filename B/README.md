# Part B — C-Shark: The Terminal Packet Sniffer

## Overview

C-Shark is a terminal-based packet sniffer that captures and analyzes network traffic in real-time. Built using the libpcap library, it provides detailed layer-by-layer packet analysis from Layer 2 (Ethernet) up to Layer 7 (Application Data). Think of it as a command-line version of Wireshark with focused functionality for network traffic inspection.

## Problem Requirements

The task was to build a comprehensive packet sniffer with the following phases:

1. **Phase 1**: Interface discovery and basic packet capture
2. **Phase 2**: Layer-by-layer packet dissection (L2-L7)
3. **Phase 3**: Protocol filtering capabilities
4. **Phase 4**: Packet storage ("aquarium") functionality
5. **Phase 5**: Detailed forensic inspection of captured packets

## Implementation Architecture & Solution Approach

### Core Design Decisions

1. **Modular Layer Decoding**: Implemented separate functions for each layer (`decode_l3()`, `decode_l4()`, `print_layer7_payload()`) to maintain clean separation of concerns and enable easy maintenance. did not keep different .c and .h, as it just seemed straightforward keeping everything in one

2. **Packet Storage System**: Used a "packet aquarium" approach with dynamically allocated storage for up to 10,000 packets per session, with automatic memory management between sessions.

3. **Signal Handling**: Implemented custom signal handlers to distinguish between Ctrl+C (stop capture, return to menu) and Ctrl+D (exit program).

4. **Non-blocking I/O**: Used `select()` with timeout to enable responsive user input during packet capture without blocking the capture loop.

### Key Data Structures

```c
typedef struct {
    struct pcap_pkthdr header;  // Packet metadata
    u_char *data;              // Raw packet data
} stored_packet_t;

static stored_packet_t *packet_aquarium[MAX_PACKETS];
```

### How I Solved Each Phase

#### Phase 1: Interface Discovery & Basic Capture

**Solution**: Used `pcap_findalldevs()` to enumerate network interfaces and present them in a user-friendly menu.

```c
static char **list_devices_and_get_array(int *out_count)
```

- Dynamically allocates array for device names
- Displays interfaces with descriptions when available
- Returns clean array for user selection

**Capture Loop**: Implemented using `pcap_dispatch()` with a responsive control mechanism:
- Non-blocking I/O using `select()` for user input detection
- Signal-safe packet counter and capture state management
- Graceful handling of capture termination

#### Phase 2: Layer-by-Layer Dissection

**Layer 2 (Ethernet)**: Direct parsing of Ethernet header structure
```c
const struct ether_header *eth = (const struct ether_header *)bytes;
```

**Layer 3 (Network)**: Protocol-specific decoding based on EtherType
- **IPv4**: Complete header analysis including fragmentation flags, TTL, protocol identification
- **IPv6**: Traffic class, flow label, hop limit, and next header parsing
- **ARP**: Operation type identification, sender/target MAC and IP extraction

**Layer 4 (Transport)**: Protocol-specific parsing
- **TCP**: Full header decode including flags, sequence numbers, window size
- **UDP**: Source/destination ports, length, checksum

**Layer 7 (Application)**: Port-based protocol identification
```c
const char* identify_app_protocol(uint16_t src_port, uint16_t dst_port)
```
- Bidirectional port checking for common protocols (HTTP, HTTPS, DNS, SSH, etc.)
- Hex+ASCII payload dump for first 64 bytes

#### Phase 3: Protocol Filtering

**Solution**: Integrated Berkeley Packet Filter (BPF) with libpcap
```c
struct bpf_program fp;
pcap_compile(handle, &fp, bpf_filter, 0, PCAP_NETMASK_UNKNOWN);
pcap_setfilter(handle, &fp);
```

Supported filters:
- HTTP (tcp port 80)
- HTTPS (tcp port 443)  
- DNS (udp port 53)
- ARP (arp)
- TCP (tcp)
- UDP (udp)

#### Phase 4: Packet Storage (Aquarium)

**Memory Management Strategy**:
- Dynamic allocation for each stored packet
- Deep copy of packet data to prevent corruption
- Automatic cleanup between sessions via `clear_aquarium()`
- Graceful handling of storage limits (MAX_PACKETS = 10000)

```c
static void clear_aquarium() {
    for (int i = 0; i < aquarium_count; i++) {
        free(packet_aquarium[i]->data);
        free(packet_aquarium[i]);
    }
    aquarium_count = 0;
}
```

#### Phase 5: Forensic Inspection

**Two-Level Analysis**:
1. **Summary View**: Tabular display of all captured packets with basic L3/L4 info
2. **Detailed Analysis**: Complete packet dissection with:
   - Full hex dump of entire frame
   - Layer-by-layer breakdown with byte-level explanations
   - Raw hex values alongside human-readable interpretations

**Advanced Features**:
- Byte offset indicators for each field
- Complete flag decoding (TCP flags, IP fragmentation flags)
- Service identification for common ports
- ASCII representation alongside hex dumps

## Key Features Implemented

### Core Functionality
-  Network interface discovery and selection
- Real-time packet capture with live display
- Complete Layer 2-7 packet analysis
- Protocol-based filtering (HTTP, HTTPS, DNS, ARP, TCP, UDP)
- Packet storage and session management
- Detailed forensic packet inspection

### Advanced Features
- Signal handling (Ctrl+C vs Ctrl+D differentiation)
- Non-blocking user input during capture
- Memory-safe packet storage with automatic cleanup
- Comprehensive error handling
- Port-based service identification
- Bidirectional protocol detection
- Full hex+ASCII payload dumps

### User Experience Enhancements
- Color-coded output sections (using emoji markers)
- Detailed byte-level field explanations
- User-friendly menus and navigation
- Graceful error messages and recovery

## Technical Implementation Details

### Libraries Used
```c
#include <pcap.h>           // Core packet capture
#include <net/ethernet.h>   // Ethernet header structures
#include <netinet/ip.h>     // IPv4 header structures
#include <netinet/ip6.h>    // IPv6 header structures
#include <netinet/tcp.h>    // TCP header structures
#include <netinet/udp.h>    // UDP header structures
#include <net/if_arp.h>     // ARP header structures
#include <arpa/inet.h>      // Network address conversion
```

### Signal Safety
- Used `volatile sig_atomic_t` for capture state variables
- Proper signal handler that doesn't interfere with system calls
- Clean separation between capture termination and program exit

### Memory Management
- Dynamic allocation for device list and packet storage
- Proper cleanup on program exit and session changes
- Protection against memory leaks with systematic `free()` calls

## Assumptions Made

1. **Root Privileges**: Program assumes it will be run with `sudo` for packet capture access
2. **Network Interface Types**: Focuses on Ethernet-based interfaces, handles others gracefully
3. **Packet Size**: Assumes standard MTU sizes, but handles varying packet lengths
4. **Protocol Coverage**: Implements most common protocols (IPv4/IPv6, TCP/UDP, ARP) with graceful fallback for unknown protocols
5. **Storage Limits**: 10,000 packet limit per session assumed sufficient for most use cases
6. **Endianness**: Assumes network byte order conversion is needed (standard assumption)
7. **Terminal Capabilities**: Assumes standard terminal that supports basic control characters
8.  **Signal Handling**:
- Ctrl+C behavior differs between capture mode and menu mode
- Program uses select() with 500ms timeout for responsive input handling
9. **Error Handling**:
- Graceful degradation for truncated/malformed packets
- Non-fatal error handling - continue execution when possible
10. **Memory Management**:  
- Deep copying of all packet data for persistent storage
- Immediate cleanup of previous session data when starting new capture
11. **have only 1 c file, not too many headers so did not create a h file**

## Compilation and Usage

### Prerequisites
- libpcap development libraries (`libpcap-dev` on Ubuntu/Debian)
- GCC compiler with standard libraries
- Root/sudo access for packet capture

### Build Instructions
```bash
make
```

### Running the Program
```bash
sudo ./cshark
```

### Sample Usage Flow
1. Program displays available network interfaces
2. User selects interface (e.g., wlan0, eth0)
3. Main menu offers capture options:
   - Start Sniffing (All Packets)
   - Start Sniffing (With Filters)
   - Inspect Last Session
   - Exit C-Shark
4. During capture: Ctrl+C stops capture, Ctrl+D exits program
5. Inspection mode allows detailed analysis of individual packets

## Testing Recommendations

1. **Local Testing**: Use localhost (lo) interface for predictable traffic
2. **Personal Hotspot**: Use personal mobile hotspot for cleaner traffic analysis
3. **Comparison**: Use Wireshark alongside C-Shark to verify accuracy
4. **Protocol Testing**: Generate specific traffic types (ping, curl, nslookup) to test different protocols

## File Structure
- `start_scratch.c`: Main implementation file
- `Makefile`: Build configuration
- `README.md`: This documentation


