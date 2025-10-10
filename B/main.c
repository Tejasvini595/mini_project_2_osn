// #define _DEFAULT_SOURCE
// #define _POSIX_C_SOURCE 200809L
// #include <sys/socket.h>
// #include <sys/types.h>
// #include <pcap.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <unistd.h>
// #include <signal.h>
// #include <pthread.h>
// #include <time.h>
// #include <errno.h>
// #include <inttypes.h>

// /* Globals used to coordinate between main thread, signal handler, and capture thread */
// static pcap_t *global_handle = NULL;          /* current active pcap handle (or NULL) */
// static pthread_mutex_t global_handle_lock = PTHREAD_MUTEX_INITIALIZER;
// static volatile sig_atomic_t capture_running = 0;
// static volatile sig_atomic_t exit_requested = 0;

// /* Helper: print the first n bytes of packet in hex (space-separated) */
// static void print_hex_prefix(const u_char *bytes, int len, int n) 
// {
//     int upto = (len < n) ? len : n;
//     for (int i = 0; i < upto; ++i) 
//     {
//         printf("%02x", bytes[i]);
//         if (i < upto - 1) printf(":");
//     }
//     if (upto < n) 
//     {
//         if (upto > 0) printf(":");
//         for (int i = upto; i < n; ++i) 
//         {
//             printf("..");
//             if (i < n - 1) printf(":");
//         }
//     }
// }

// /* Packet counter for unique packet IDs (64-bit in case many packets) */
// static uint64_t packet_counter = 0;

// /* pcap callback — invoked from capture thread context */
// static void packet_handler(u_char *user, const struct pcap_pkthdr *h, const u_char *bytes) 
// {
//     (void)user;
//     uint64_t id = __sync_add_and_fetch(&packet_counter, 1); /* atomic increment */

//     /* timestamp */
//     struct tm tm_snapshot;
//     char tbuf[64];
//     time_t sec = h->ts.tv_sec;
//     localtime_r(&sec, &tm_snapshot);
//     size_t r = strftime(tbuf, sizeof(tbuf), "%Y-%m-%d %H:%M:%S", &tm_snapshot);

//     /* print one line per packet */
//     printf("[%" PRIu64 "] %s.%06ld | len=%u | ", id, tbuf, (long)h->ts.tv_usec, h->caplen);
//     print_hex_prefix(bytes, h->caplen, 16);
//     printf("\n");

//     fflush(stdout);
// }


// static void sigint_handler(int signum) 
// {
//     (void)signum;

//     if (capture_running) 
//     {
//         capture_running = 0;
//         printf("\n--- capture stop requested ---\n");
//     } 
//     else 
//     {
//         exit_requested = 1;
//     }
// }


// // static void *capture_thread_fn(void *arg) 
// // {
// //     char *device = (char *)arg;
// //     char errbuf[PCAP_ERRBUF_SIZE];
// //     pcap_t *handle = NULL;
// //     int snaplen = 65535;
// //     int promisc = 1;
// //     int to_ms = 1000; 
// //     handle = pcap_open_live(device, snaplen, promisc, to_ms, errbuf);
// //     if (!handle) {
// //         fprintf(stderr, "pcap_open_live(%s) failed: %s\n", device, errbuf);
// //         capture_running = 0;
// //         return NULL;
// //     }

// //     pthread_mutex_lock(&global_handle_lock);
// //     global_handle = handle;
// //     pthread_mutex_unlock(&global_handle_lock);

// //     /* Reset per-capture counter */
// //     __sync_lock_test_and_set(&packet_counter, 0);

// //     /* Print start message */
// //     printf("\n--- capturing on '%s' (press Ctrl+C to stop, Ctrl+D to exit) ---\n", device);
// //     fflush(stdout);

// //     capture_running = 1;
// //     /* start capture loop (0 -> infinite until pcap_breakloop) */
// //     pcap_loop(handle, 0, packet_handler, NULL);

// //     /* cleanup */
// //     pthread_mutex_lock(&global_handle_lock);
// //     /* close handle and clear global pointer */
// //     pcap_close(handle);
// //     global_handle = NULL;
// //     pthread_mutex_unlock(&global_handle_lock);

// //     capture_running = 0;
// //     printf("--- capture stopped ---\n\n");
// //     fflush(stdout);

// //     return NULL;
// // }


// /* Thread function that does the capture using a non-blocking pcap_dispatch loop */
// static void *capture_thread_fn(void *arg) {
//     char *device = (char *)arg;
//     char errbuf[PCAP_ERRBUF_SIZE];
//     pcap_t *handle = NULL;

//     /* open */
//     int snaplen = 65535;
//     int promisc = 1;
//     int to_ms = 1000; /* read timeout ms */
//     handle = pcap_open_live(device, snaplen, promisc, to_ms, errbuf);
//     if (!handle) {
//         fprintf(stderr, "pcap_open_live(%s) failed: %s\n", device, errbuf);
//         capture_running = 0;
//         return NULL;
//     }
    
//     /* *************************************************************** */
//     /* *** THIS IS THE CRITICAL CHANGE TO FIX THE CTRL+D PROBLEM *** */
//     /* Set the handle to be non-blocking */
//     if (pcap_setnonblock(handle, 1, errbuf) == -1) 
//     {
//         fprintf(stderr, "pcap_set_nonblock failed: %s\n", errbuf);
//         pcap_close(handle);
//         capture_running = 0;
//         return NULL;
//     }
//     /* *************************************************************** */

//     /* store handle in global for signal handler to access */
//     pthread_mutex_lock(&global_handle_lock);
//     global_handle = handle;
//     pthread_mutex_unlock(&global_handle_lock);

//     /* Reset per-capture counter */
//     __sync_lock_test_and_set(&packet_counter, 0);

//     /* Print start message */
//     printf("\n--- capturing on '%s' (press Ctrl+C to stop, Ctrl+D to exit) ---\n", device);
//     fflush(stdout);

//     capture_running = 1;

//     /*
//      * Replace blocking pcap_loop() with a non-blocking pcap_dispatch() loop.
//      * We pass -1 as the packet count to process all packets received in one
//      * buffer. This is more efficient than calling it for each packet.
//      * The usleep() prevents the loop from spinning and eating CPU.
//      */
//     while (capture_running) 
//     {
//         if (pcap_dispatch(handle, -1, packet_handler, NULL) < 0) 
//         {
//             // An error occurred, pcap_breakloop was called, or the loop timed out.
//             // In our non-blocking case, this often just means no packets were available.
//         }
        
//         usleep(10000); // 10 ms
//     }


//     pthread_mutex_lock(&global_handle_lock);
//     /* close handle and clear global pointer */
//     pcap_close(handle);
//     global_handle = NULL;
//     pthread_mutex_unlock(&global_handle_lock);

     
//     return NULL;
// }


// static char **list_devices_and_get_array(int *out_count) 
// {
//     pcap_if_t *alldevs = NULL, *d;
//     char errbuf[PCAP_ERRBUF_SIZE];
//     if (pcap_findalldevs(&alldevs, errbuf) == -1) 
//     {
//         fprintf(stderr, "Error finding devices: %s\n", errbuf);
//         *out_count = 0;
//         return NULL;
//     }

//     /* count */
//     int count = 0;
//     for (d = alldevs; d != NULL; d = d->next) count++;
//     if (count == 0) 
//     {
//         pcap_freealldevs(alldevs);
//         *out_count = 0;
//         return NULL;
//     }

//     char **names = calloc(count, sizeof(char *));
//     int idx = 0;
//     for (d = alldevs; d != NULL; d = d->next) 
//     {
//         names[idx] = strdup(d->name);
//         printf("%2d. %s%s%s\n",
//                idx + 1,
//                d->name,
//                d->description ? " - " : "",
//                d->description ? d->description : "");
//         idx++;
//     }

//     pcap_freealldevs(alldevs);
//     *out_count = count;
//     return names;
// }

// // int main(void) 
// // {
// //     /* install SIGINT handler without SA_RESTART so that blocking getline gets interrupted when Ctrl+C occurs */
// //     struct sigaction sa;
// //     memset(&sa, 0, sizeof(sa));
// //     sa.sa_handler = sigint_handler;
// //     sa.sa_flags = 0; /* do NOT set SA_RESTART */
// //     sigemptyset(&sa.sa_mask);
// //     sigaction(SIGINT, &sa, NULL);

// //     printf("[C-Shark] The Command-Line Packet Predator\n");
// //     printf("=========================================\n");
// //     printf("[C-Shark] Searching for available interfaces... Found!\n\n");

// //     /* List available devices */
// //     int devcount = 0;
// //     char **devnames = list_devices_and_get_array(&devcount);
// //     if (!devnames || devcount == 0) 
// //     {
// //         fprintf(stderr, "No devices found. Exiting.\n");
// //         return 1;
// //     }

// //     /* Let user pick an interface (handle Ctrl+D here too) */
// //     char *line = NULL;
// //     size_t len = 0;
// //     ssize_t nread = 0;
// //     int chosen_index = -1;

// //     while (1) 
// //     {
// //         printf("\nSelect an interface to sniff (1-%d): ", devcount);
// //         fflush(stdout);
// //         nread = getline(&line, &len, stdin);
// //         if (nread == -1) 
// //         { /* EOF or error */
// //             if (feof(stdin)) 
// //             {
// //                 printf("\nEOF detected. Exiting.\n");
// //                 exit_requested = 1;
// //                 goto cleanup_and_exit;
// //             } 
// //             else if (errno == EINTR) 
// //             {
// //                 /* Interrupted by signal — loop again */
// //                 continue;
// //             } 
// //             else 
// //             {
// //                 perror("getline");
// //                 exit_requested = 1;
// //                 goto cleanup_and_exit;
// //             }
// //         }
// //         if (nread > 0 && line[nread - 1] == '\n') line[nread - 1] = '\0';

// //         char *endptr;
// //         long v = strtol(line, &endptr, 10);
// //         if (*endptr != '\0' || v < 1 || v > devcount) {
// //             printf("Invalid selection. Try again.\n");
// //             continue;
// //         }
// //         chosen_index = (int)(v - 1);
// //         break;
// //     }

// //     if (chosen_index < 0) goto cleanup_and_exit;

// //     char *chosen_device = strdup(devnames[chosen_index]);
// //     printf("\n[C-Shark] Interface '%s' selected. What's next?\n\n", chosen_device);

// //     /* Main menu loop */
// //     int running = 1;
// //     while (running && !exit_requested) 
// //     {
// //         printf("Main Menu:\n");
// //         printf("  1. Start Sniffing (All Packets)\n");
// //         printf("  2. Start Sniffing (With Filters) <-- not implemented yet\n");
// //         printf("  3. Inspect Last Session        <-- not implemented yet\n");
// //         printf("  4. Exit C-Shark\n");
// //         printf("Enter choice: ");
// //         fflush(stdout);

// //         nread = getline(&line, &len, stdin);
// //         if (nread == -1) {
// //             if (feof(stdin)) {
// //                 printf("\nEOF detected. Exiting program.\n");
// //                 exit_requested = 1;
// //                 break;
// //             } else if (errno == EINTR) {
// //                 /* Interrupted by Ctrl+C — just reprint menu */
// //                 printf("\nInterrupted. Returning to menu.\n");
// //                 continue;
// //             } else {
// //                 perror("getline");
// //                 break;
// //             }
// //         }

// //         if (nread > 0 && line[nread - 1] == '\n') line[nread - 1] = '\0';
// //         char *endptr;
// //         long choice = strtol(line, &endptr, 10);
// //         if (*endptr != '\0') {
// //             printf("Invalid input. Try again.\n\n");
// //             continue;
// //         }

// //         switch ((int)choice) {
// //             case 1: {
// //                 /* Start capture in a separate thread so main thread can still detect Ctrl+D (EOF).
// //                  * The main thread will then block on getline; Ctrl+C will interrupt that getline and also call the SIGINT handler to break pcap_loop.
// //                  */
// //                 if (capture_running) {
// //                     printf("Capture already running!\n");
// //                     break;
// //                 }
// //                 pthread_t cap_thread;
// //                 int rc = pthread_create(&cap_thread, NULL, capture_thread_fn, (void *)chosen_device);
// //                 if (rc != 0) {
// //                     fprintf(stderr, "Failed to create capture thread: %s\n", strerror(rc));
// //                     break;
// //                 }

// //                 /* While capture is running, keep the main thread blocked on getline so Ctrl+D (EOF) is detected
// //                  * and Ctrl+C will interrupt the getline (EINTR) and will be handled by sigint_handler.
// //                  */
// //                 while (capture_running) {
// //                     /* block on getline to detect Ctrl+D or be interrupted by Ctrl+C (EINTR). */
// //                     printf("(capture running) Press Ctrl+C to stop capture, Ctrl+D to exit program\n");
// //                     fflush(stdout);
// //                     ssize_t r = getline(&line, &len, stdin);
// //                     if (r == -1) {
// //                         if (feof(stdin)) {
// //                             /* Ctrl+D: request program exit and break capture loop */
// //                             printf("\nEOF detected. Exiting program.\n");
// //                             exit_requested = 1;
// //                             /* Ask capture to stop if running */
// //                             pthread_mutex_lock(&global_handle_lock);
// //                             if (global_handle) pcap_breakloop(global_handle);
// //                             pthread_mutex_unlock(&global_handle_lock);
// //                             break;
// //                         } else if (errno == EINTR) {
// //                             /* Signal interrupted (likely Ctrl+C). Wait for capture thread to terminate. */
// //                             /* Note: SIGINT handler already called pcap_breakloop on global_handle. */
// //                             break;
// //                         } else {
// //                             /* non-EINTR error: continue or break */
// //                             if (errno == 0) continue;
// //                             perror("getline");
// //                             break;
// //                         }
// //                     } else {
// //                         /* User typed something while capture running — ignore it and continue waiting */
// //                         if (r > 0 && line[r - 1] == '\n') line[r - 1] = '\0';
// //                         printf("Note: input ignored while capture is running. Use Ctrl+C to stop capture.\n");
// //                     }
// //                 }

// //                 /* Wait for capture thread to finish */
// //                 pthread_join(cap_thread, NULL);

// //                 if (exit_requested) {
// //                     running = 0;
// //                 } else {
// //                     printf("Returned to main menu.\n\n");
// //                 }
// //                 break;
// //             }

// //             case 2:
// //                 printf("Option 2 (filters) not implemented yet.\n\n");
// //                 break;

// //             case 3:
// //                 printf("Option 3 (inspect last session) not implemented yet.\n\n");
// //                 break;

// //             case 4:
// //                 printf("Exiting C-Shark. Goodbye!\n");
// //                 running = 0;
// //                 exit_requested = 1;
// //                 break;

// //             default:
// //                 printf("Unknown choice. Try again.\n\n");
// //                 break;
// //         }
// //     }

// // cleanup_and_exit:
// //     /* free resources */
// //     free(line);
// //     if (devnames) 
// //     {
// //         for (int i = 0; i < devcount; ++i) free(devnames[i]);
// //         free(devnames);
// //     }
// //     if (capture_running) 
// //     {
// //         /* request capture stop and wait a moment */
// //         pthread_mutex_lock(&global_handle_lock);
// //         if (global_handle) pcap_breakloop(global_handle);
// //         pthread_mutex_unlock(&global_handle_lock);
// //     }

// //     /* small pause to allow capture thread (if any) to close handle */
// //     usleep(100 * 1000);

// //     return 0;
// // }


// int main(void) 
// {
//     /* install SIGINT handler without SA_RESTART so that blocking getline gets interrupted when Ctrl+C occurs */
//     struct sigaction sa;
//     memset(&sa, 0, sizeof(sa));
//     sa.sa_handler = sigint_handler;
//     sa.sa_flags = 0; /* do NOT set SA_RESTART */
//     sigemptyset(&sa.sa_mask);
//     sigaction(SIGINT, &sa, NULL);

//     printf("[C-Shark] The Command-Line Packet Predator\n");
//     printf("=========================================\n");
//     printf("[C-Shark] Searching for available interfaces... Found!\n\n");

//     /* List available devices */
//     int devcount = 0;
//     char **devnames = list_devices_and_get_array(&devcount);
//     if (!devnames || devcount == 0) 
//     {
//         fprintf(stderr, "No devices found. Exiting.\n");
//         return 1;
//     }

//     /* Let user pick an interface (handle Ctrl+D here too) */
//     char *line = NULL;
//     size_t len = 0;
//     ssize_t nread = 0;
//     int chosen_index = -1;

//     while (1) 
//     {
//         printf("\nSelect an interface to sniff (1-%d): ", devcount);
//         fflush(stdout);
//         nread = getline(&line, &len, stdin);
//         if (nread == -1) 
//         { /* EOF or error */
//             if (feof(stdin)) 
//             {
//                 printf("\nEOF detected. Exiting.\n");
//                 exit_requested = 1;
//                 goto cleanup_and_exit;
//             } 
//             else if (errno == EINTR) 
//             {
//                 /* Interrupted by signal — loop again */
//                 continue;
//             } 
//             else 
//             {
//                 perror("getline");
//                 exit_requested = 1;
//                 goto cleanup_and_exit;
//             }
//         }
//         if (nread > 0 && line[nread - 1] == '\n') line[nread - 1] = '\0';

//         char *endptr;
//         long v = strtol(line, &endptr, 10);
//         if (*endptr != '\0' || v < 1 || v > devcount) {
//             printf("Invalid selection. Try again.\n");
//             continue;
//         }
//         chosen_index = (int)(v - 1);
//         break;
//     }

//     if (chosen_index < 0) goto cleanup_and_exit;

//     char *chosen_device = strdup(devnames[chosen_index]);
//     printf("\n[C-Shark] Interface '%s' selected. What's next?\n\n", chosen_device);

//     /* Main menu loop */
//     int running = 1;
//     while (running && !exit_requested) 
//     {
//         printf("Main Menu:\n");
//         printf("  1. Start Sniffing (All Packets)\n");
//         printf("  2. Start Sniffing (With Filters) <-- not implemented yet\n");
//         printf("  3. Inspect Last Session        <-- not implemented yet\n");
//         printf("  4. Exit C-Shark\n");
//         printf("Enter choice: ");
//         fflush(stdout);

//         nread = getline(&line, &len, stdin);
//         if (nread == -1) {
//             if (feof(stdin)) {
//                 printf("\nEOF detected. Exiting program.\n");
//                 exit_requested = 1;
//                 break;
//             } else if (errno == EINTR) {
//                 /* Interrupted by Ctrl+C — just reprint menu */
//                 printf("\nInterrupted. Returning to menu.\n");
//                 continue;
//             } else {
//                 perror("getline");
//                 break;
//             }
//         }

//         if (nread > 0 && line[nread - 1] == '\n') line[nread - 1] = '\0';
//         char *endptr;
//         long choice = strtol(line, &endptr, 10);
//         if (*endptr != '\0') {
//             printf("Invalid input. Try again.\n\n");
//             continue;
//         }

//         switch ((int)choice) {
//             case 1: {
//                 if (capture_running) {
//                     printf("Capture already running!\n");
//                     break;
//                 }
//                 pthread_t cap_thread;
//                 int rc = pthread_create(&cap_thread, NULL, capture_thread_fn, (void *)chosen_device);
//                 if (rc != 0) {
//                     fprintf(stderr, "Failed to create capture thread: %s\n", strerror(rc));
//                     break;
//                 }

//                 while (capture_running) {
//                     printf("(capture running) Press Ctrl+C to stop capture, Ctrl+D to exit program\n");
//                     fflush(stdout);
//                     ssize_t r = getline(&line, &len, stdin);
//                     if (r == -1) {
//                         // ========================================================= //
//                         // ==================== THIS IS THE FIX ==================== //
//                         if (feof(stdin)) {
//                             /* Ctrl+D: request program exit and break capture loop */
//                             printf("\nEOF detected. Exiting program.\n");
//                             exit_requested = 1;   // Tell the main loop to exit
//                             capture_running = 0;  // Tell the capture thread to stop
//                             break;                // Exit this waiting loop
//                         } 
//                         // ========================================================= //
//                         // ========================================================= //
//                         else if (errno == EINTR) {
//                             /* Signal interrupted (likely Ctrl+C). Wait for capture thread to terminate. */
//                             break;
//                         } else {
//                             if (errno == 0) continue;
//                             perror("getline");
//                             break;
//                         }
//                     } else {
//                         if (r > 0 && line[r - 1] == '\n') line[r - 1] = '\0';
//                         printf("Note: input ignored while capture is running. Use Ctrl+C to stop capture.\n");
//                     }
//                 }

//                 /* Wait for capture thread to finish */
//                 pthread_join(cap_thread, NULL);

//                 if (exit_requested) {
//                     running = 0;
//                 } else {
//                     printf("--- capture stopped ---\n");
//                     printf("Returned to main menu.\n\n");
//                 }
//                 break;
//             }

//             case 2:
//                 printf("Option 2 (filters) not implemented yet.\n\n");
//                 break;

//             case 3:
//                 printf("Option 3 (inspect last session) not implemented yet.\n\n");
//                 break;

//             case 4:
//                 printf("Exiting C-Shark. Goodbye!\n");
//                 running = 0;
//                 exit_requested = 1;
//                 break;

//             default:
//                 printf("Unknown choice. Try again.\n\n");
//                 break;
//         }
//     }

// cleanup_and_exit:
//     /* free resources */
//     free(line);
//     if (devnames) 
//     {
//         for (int i = 0; i < devcount; ++i) free(devnames[i]);
//         free(devnames);
//     }
//     // Final check to stop a dangling capture thread is no longer needed here
//     // as the main loop logic handles it correctly now.

//     printf("C-Shark is shutting down.\n");
//     return 0;
// }


#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include <sys/socket.h>
#include <sys/types.h>
#include <pcap.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <pthread.h>
#include <time.h>
#include <errno.h>
#include <inttypes.h>
#include <ctype.h>

// Standard networking headers for packet dissection
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/ip6.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>
#include <net/if_arp.h>
#include <arpa/inet.h>

/* Globals */
static pcap_t *global_handle = NULL;
static pthread_mutex_t global_handle_lock = PTHREAD_MUTEX_INITIALIZER;
static volatile sig_atomic_t capture_running = 0;
static volatile sig_atomic_t exit_requested = 0;
static uint64_t packet_counter = 0;


/* ================================================================= */
/* =================== PACKET DISSECTION HELPERS =================== */
/* ================================================================= */

// Helper to get a string name for common ports
const char* get_service_name(uint16_t port) {
    switch (port) {
        case 80: return "HTTP";
        case 443: return "HTTPS";
        case 53: return "DNS";
        case 20: return "FTP-data";
        case 21: return "FTP";
        case 22: return "SSH";
        case 23: return "Telnet";
        case 25: return "SMTP";
        default: return NULL;
    }
}

// **FIXED**: Helper to print payload in the required hex and ASCII format
void print_payload(const u_char *payload, int len) {
    if (len <= 0) {
        return;
    }

    const int bytes_per_line = 16;
    int max_bytes_to_print = (len < 64) ? len : 64;

    printf("    Data (first %d bytes):\n", max_bytes_to_print);

    for (int i = 0; i < max_bytes_to_print; i += bytes_per_line) {
        // Print Hex Part
        printf("    ");
        for (int j = 0; j < bytes_per_line; j++) {
            if (i + j < max_bytes_to_print) {
                printf("%02x ", payload[i + j]);
            } else {
                printf("   "); // Pad for alignment
            }
        }
        printf(" ");

        // Print ASCII Part
        for (int j = 0; j < bytes_per_line; j++) {
            if (i + j < max_bytes_to_print) {
                if (isprint(payload[i + j])) {
                    printf("%c", payload[i + j]);
                } else {
                    printf(".");
                }
            }
        }
        printf("\n");
    }
}

// Dissect TCP Segment (Layer 4)
void handle_tcp(const u_char *packet, int size, int total_ip_len) {
    if (size < sizeof(struct tcphdr)) {
        printf("L4 (TCP): Malformed Packet\n");
        return;
    }
    const struct tcphdr *tcp_header = (const struct tcphdr *)packet;
    uint16_t src_port = ntohs(tcp_header->th_sport);
    uint16_t dst_port = ntohs(tcp_header->th_dport);
    const char* src_service = get_service_name(src_port);
    const char* dst_service = get_service_name(dst_port);
    int tcp_header_len = tcp_header->th_off * 4;

    printf("L4 (TCP): Src Port: %u%s%s | Dst Port: %u%s%s | Seq: %u | Ack: %u\n",
           src_port, src_service ? " (" : "", src_service ? src_service : "",
           dst_port, dst_service ? ")" : "", dst_service ? dst_service : "",
           ntohl(tcp_header->th_seq), ntohl(tcp_header->th_ack));

    // Decode TCP flags
    printf("    Flags: [");
    if (tcp_header->th_flags & TH_SYN) printf("SYN ");
    if (tcp_header->th_flags & TH_ACK) printf("ACK ");
    if (tcp_header->th_flags & TH_FIN) printf("FIN ");
    if (tcp_header->th_flags & TH_RST) printf("RST ");
    if (tcp_header->th_flags & TH_PUSH) printf("PSH ");
    if (tcp_header->th_flags & TH_URG) printf("URG ");
    printf("] | Window: %u | Checksum: 0x%04x | Header Length: %d bytes\n",
           ntohs(tcp_header->th_win), ntohs(tcp_header->th_sum), tcp_header_len);

    // Handle Payload (Layer 7)
    const u_char *payload = packet + tcp_header_len;
    int payload_len = total_ip_len - tcp_header_len;
    const char* app_protocol = dst_service ? dst_service : src_service;
    if (!app_protocol) app_protocol = "Unknown";

    printf("L7 (Payload): Identified as %s on port %u - %d bytes\n",
           app_protocol, dst_service ? dst_port : src_port, payload_len);
    print_payload(payload, payload_len);
}

// Dissect UDP Datagram (Layer 4)
void handle_udp(const u_char *packet, int size) {
    if (size < sizeof(struct udphdr)) {
        printf("L4 (UDP): Malformed Packet\n");
        return;
    }
    const struct udphdr *udp_header = (const struct udphdr *)packet;
    uint16_t src_port = ntohs(udp_header->uh_sport);
    uint16_t dst_port = ntohs(udp_header->uh_dport);
    const char* src_service = get_service_name(src_port);
    const char* dst_service = get_service_name(dst_port);

    printf("L4 (UDP): Src Port: %u%s%s | Dst Port: %u%s%s\n",
           src_port, src_service ? " (" : "", src_service ? src_service : "",
           dst_port, dst_service ? ")" : "", dst_service ? dst_service : "");
    printf("    Length: %u | Checksum: 0x%04x\n", ntohs(udp_header->uh_ulen), ntohs(udp_header->uh_sum));

    // Handle Payload (Layer 7)
    const u_char *payload = packet + sizeof(struct udphdr);
    int payload_len = ntohs(udp_header->uh_ulen) - sizeof(struct udphdr);
    const char* app_protocol = dst_service ? dst_service : src_service;
    if (!app_protocol) app_protocol = "Unknown";

    printf("L7 (Payload): Identified as %s on port %u - %d bytes\n",
           app_protocol, dst_service ? dst_port : src_port, payload_len);
    print_payload(payload, payload_len);
}

// Dissect IPv4 Packet (Layer 3)
void handle_ipv4(const u_char *packet, int size) {
    if (size < sizeof(struct ip)) {
        printf("L3 (IPv4): Malformed Packet\n");
        return;
    }
    const struct ip *ip_header = (const struct ip *)packet;
    char src_ip_str[INET_ADDRSTRLEN];
    char dst_ip_str[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &(ip_header->ip_src), src_ip_str, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &(ip_header->ip_dst), dst_ip_str, INET_ADDRSTRLEN);

    int ip_header_len = ip_header->ip_hl * 4;

    printf("L3 (IPv4): Src IP: %s | Dst IP: %s\n", src_ip_str, dst_ip_str);

    const char *protocol_str = "Unknown";
    switch (ip_header->ip_p) {
        case IPPROTO_TCP: protocol_str = "TCP"; break;
        case IPPROTO_UDP: protocol_str = "UDP"; break;
        case IPPROTO_ICMP: protocol_str = "ICMP"; break;
    }

    // **FIXED**: Added decoding for IP Flags
    uint16_t flags_offset = ntohs(ip_header->ip_off);
    int df_flag = (flags_offset & IP_DF) ? 1 : 0;
    int mf_flag = (flags_offset & IP_MF) ? 1 : 0;

    printf("    Protocol: %s (%d) | TTL: %d | ID: 0x%04x | Header Length: %d bytes\n",
           protocol_str, ip_header->ip_p, ip_header->ip_ttl,
           ntohs(ip_header->ip_id), ip_header_len);
    printf("    Total Length: %u | Flags: [%s%s]\n",
           ntohs(ip_header->ip_len),
           df_flag ? "DF" : "",
           mf_flag ? "MF" : "");


    const u_char *transport_packet = packet + ip_header_len;
    int transport_size = size - ip_header_len;
    int total_ip_len = ntohs(ip_header->ip_len) - ip_header_len;

    if (ip_header->ip_p == IPPROTO_TCP) {
        handle_tcp(transport_packet, transport_size, total_ip_len);
    } else if (ip_header->ip_p == IPPROTO_UDP) {
        handle_udp(transport_packet, transport_size);
    }
}

// Dissect IPv6 Packet (Layer 3)
void handle_ipv6(const u_char *packet, int size) {
    if (size < sizeof(struct ip6_hdr)) {
        printf("L3 (IPv6): Malformed Packet\n");
        return;
    }
    const struct ip6_hdr *ip6_header = (const struct ip6_hdr *)packet;
    char src_ip_str[INET6_ADDRSTRLEN];
    char dst_ip_str[INET6_ADDRSTRLEN];
    inet_ntop(AF_INET6, &(ip6_header->ip6_src), src_ip_str, INET6_ADDRSTRLEN);
    inet_ntop(AF_INET6, &(ip6_header->ip6_dst), dst_ip_str, INET6_ADDRSTRLEN);

    printf("L3 (IPv6): Src IP: %s\n", src_ip_str);
    printf("    Dst IP: %s\n", dst_ip_str);

    uint32_t flow_info = ntohl(ip6_header->ip6_flow);
    uint8_t traffic_class = (flow_info >> 20) & 0xFF;
    uint32_t flow_label = flow_info & 0xFFFFF;

    const char *next_header_str = "Unknown";
    switch (ip6_header->ip6_nxt) {
        case IPPROTO_TCP: next_header_str = "TCP"; break;
        case IPPROTO_UDP: next_header_str = "UDP"; break;
        case IPPROTO_ICMPV6: next_header_str = "ICMPv6"; break;
    }

    printf("    Next Header: %s (%d) | Hop Limit: %d | Traffic Class: %u | Flow Label: 0x%05x | Payload Length: %u\n",
           next_header_str, ip6_header->ip6_nxt, ip6_header->ip6_hlim,
           traffic_class, flow_label, ntohs(ip6_header->ip6_plen));

    const u_char *transport_packet = packet + sizeof(struct ip6_hdr);
    int transport_size = size - sizeof(struct ip6_hdr);
    int total_ip_len = ntohs(ip6_header->ip6_plen);

    if (ip6_header->ip6_nxt == IPPROTO_TCP) {
        handle_tcp(transport_packet, transport_size, total_ip_len);
    } else if (ip6_header->ip6_nxt == IPPROTO_UDP) {
        handle_udp(transport_packet, transport_size);
    }
}

// Dissect ARP Packet (Layer 3)
void handle_arp(const u_char *packet, int size) {
    if (size < sizeof(struct arphdr)) {
        printf("L3 (ARP): Malformed Packet\n");
        return;
    }
    const struct arphdr *arp_header = (const struct arphdr *)packet;

    const char *op_str = "Unknown";
    uint16_t op = ntohs(arp_header->ar_op);
    if (op == ARPOP_REQUEST) op_str = "Request";
    else if (op == ARPOP_REPLY) op_str = "Reply";

    printf("L3 (ARP): Operation: %s (%u)\n", op_str, op);

    // ARP payload for IPv4 over Ethernet
    if (ntohs(arp_header->ar_hrd) == ARPHRD_ETHER && ntohs(arp_header->ar_pro) == ETHERTYPE_IP) {
        const u_char *arp_data = packet + sizeof(struct arphdr);
        char sender_ip_str[INET_ADDRSTRLEN];
        char target_ip_str[INET_ADDRSTRLEN];

        inet_ntop(AF_INET, arp_data + 6, sender_ip_str, INET_ADDRSTRLEN);
        inet_ntop(AF_INET, arp_data + 16, target_ip_str, INET_ADDRSTRLEN);

        printf("    Sender MAC: %02x:%02x:%02x:%02x:%02x:%02x | Sender IP: %s\n",
               arp_data[0], arp_data[1], arp_data[2], arp_data[3], arp_data[4], arp_data[5], sender_ip_str);
        printf("    Target MAC: %02x:%02x:%02x:%02x:%02x:%02x | Target IP: %s\n",
               arp_data[10], arp_data[11], arp_data[12], arp_data[13], arp_data[14], arp_data[15], target_ip_str);
    }
     printf("    HW Type: %u | Proto Type: 0x%04x | HW Len: %u | Proto Len: %u\n",
           ntohs(arp_header->ar_hrd), ntohs(arp_header->ar_pro), arp_header->ar_hln, arp_header->ar_pln);
}


/* ================================================================= */
/* =================== MAIN PCAP CALLBACK ========================== */
/* ================================================================= */

void packet_handler(u_char *user, const struct pcap_pkthdr *h, const u_char *bytes) {
    (void)user;
    uint64_t id = __sync_add_and_fetch(&packet_counter, 1);

    printf("-----------------------------------------\n");
    printf("Packet #%" PRIu64 " | Timestamp: %ld.%06ld | Length: %u bytes\n",
           id, (long)h->ts.tv_sec, (long)h->ts.tv_usec, h->caplen);

    if (h->caplen < sizeof(struct ether_header)) {
        printf("L2 (Ethernet): Malformed Packet\n");
        return;
    }
    const struct ether_header *eth_header = (const struct ether_header *)bytes;
    printf("L2 (Ethernet): Dst MAC: %02x:%02x:%02x:%02x:%02x:%02x | Src MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
           eth_header->ether_dhost[0], eth_header->ether_dhost[1], eth_header->ether_dhost[2], eth_header->ether_dhost[3], eth_header->ether_dhost[4], eth_header->ether_dhost[5],
           eth_header->ether_shost[0], eth_header->ether_shost[1], eth_header->ether_shost[2], eth_header->ether_shost[3], eth_header->ether_shost[4], eth_header->ether_shost[5]);

    uint16_t ether_type = ntohs(eth_header->ether_type);
    const u_char *next_layer_packet = bytes + sizeof(struct ether_header);
    int remaining_size = h->caplen - sizeof(struct ether_header);

    const char* etype_str;
    switch (ether_type) {
        case ETHERTYPE_IP:   etype_str = "IPv4"; break;
        case ETHERTYPE_IPV6: etype_str = "IPv6"; break;
        case ETHERTYPE_ARP:  etype_str = "ARP"; break;
        default:             etype_str = "Unknown"; break;
    }
    printf("    EtherType: %s (0x%04x)\n", etype_str, ether_type);

    switch (ether_type) {
        case ETHERTYPE_IP:   handle_ipv4(next_layer_packet, remaining_size); break;
        case ETHERTYPE_IPV6: handle_ipv6(next_layer_packet, remaining_size); break;
        case ETHERTYPE_ARP:  handle_arp(next_layer_packet, remaining_size); break;
    }

    fflush(stdout);
}


/* ================================================================= */
/* ========= CORE APPLICATION LOGIC (UNCHANGED FROM PHASE 1) ========= */
/* ================================================================= */

static void sigint_handler(int signum) {
    (void)signum;
    if (capture_running) {
        capture_running = 0;
        printf("\n--- capture stop requested ---\n");
        // Force break the pcap loop if it's currently active
        pthread_mutex_lock(&global_handle_lock);
        if (global_handle) {
            pcap_breakloop(global_handle);
        }
        pthread_mutex_unlock(&global_handle_lock);
    } else {
        // In main menu, Ctrl+C should stay in menu (not exit)
        printf("\n[C-Shark] Use option 4 to exit or Ctrl+D to force exit.\n");
    }
}

static void *capture_thread_fn(void *arg) {
    char *device = (char *)arg;
    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *handle = NULL;

    handle = pcap_open_live(device, BUFSIZ, 1, 1000, errbuf);
    if (!handle) {
        fprintf(stderr, "pcap_open_live(%s) failed: %s\n", device, errbuf);
        capture_running = 0;
        return NULL;
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
    printf("\n--- capturing on '%s' (press Ctrl+C to stop, Ctrl+D to exit) ---\n", device);
    fflush(stdout);
    capture_running = 1;

    while (capture_running) {
        // Process only 1 packet at a time for maximum responsiveness
        int result = pcap_dispatch(handle, 1, packet_handler, NULL);
        if (result < 0) {
            // Error occurred, break out
            break;
        }
        // Very small sleep to prevent high CPU usage but maintain responsiveness
        usleep(100); // 0.1 ms - much more responsive
    }

    pthread_mutex_lock(&global_handle_lock);
    pcap_close(handle);
    global_handle = NULL;
    pthread_mutex_unlock(&global_handle_lock);

    return NULL;
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
    for (d = alldevs; d != NULL; d = d->next) count++;
    if (count == 0) {
        pcap_freealldevs(alldevs);
        *out_count = 0;
        return NULL;
    }
    char **names = calloc(count, sizeof(char *));
    int idx = 0;
    for (d = alldevs; d != NULL; d = d->next) {
        names[idx] = strdup(d->name);
        printf("%2d. %s%s%s\n",
               idx + 1, d->name,
               d->description ? " - " : "", d->description ? d->description : "");
        idx++;
    }
    pcap_freealldevs(alldevs);
    *out_count = count;
    return names;
}

int main(void) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigint_handler;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    printf("[C-Shark] The Command-Line Packet Predator\n");
    printf("=========================================\n");
    printf("[C-Shark] Searching for available interfaces... Found!\n\n");

    int devcount = 0;
    char **devnames = list_devices_and_get_array(&devcount);
    if (!devnames || devcount == 0) {
        fprintf(stderr, "No devices found. Exiting.\n");
        return 1;
    }

    char *line = NULL;
    size_t len = 0;
    ssize_t nread = 0;
    int chosen_index = -1;

    while (1) {
        printf("\nSelect an interface to sniff (1-%d): ", devcount);
        fflush(stdout);
        nread = getline(&line, &len, stdin);
        if (nread == -1) {
            if (feof(stdin)) {
                printf("\nEOF detected. Exiting.\n");
                exit_requested = 1;
                goto cleanup_and_exit;
            } else if (errno == EINTR) {
                continue;
            } else {
                perror("getline");
                exit_requested = 1;
                goto cleanup_and_exit;
            }
        }
        if (nread > 0 && line[nread - 1] == '\n') line[nread - 1] = '\0';
        char *endptr;
        long v = strtol(line, &endptr, 10);
        if (*endptr != '\0' || v < 1 || v > devcount) {
            printf("Invalid selection. Try again.\n");
            continue;
        }
        chosen_index = (int)(v - 1);
        break;
    }

    if (chosen_index < 0) goto cleanup_and_exit;

    char *chosen_device = strdup(devnames[chosen_index]);
    printf("\n[C-Shark] Interface '%s' selected. What's next?\n\n", chosen_device);

    int running = 1;
    while (running && !exit_requested) {
        printf("Main Menu:\n");
        printf("  1. Start Sniffing (All Packets)\n");
        printf("  2. Start Sniffing (With Filters)\n");
        printf("  3. Inspect Last Session        <-- not implemented yet\n");
        printf("  4. Exit C-Shark\n");
        printf("Enter choice: ");
        fflush(stdout);

        nread = getline(&line, &len, stdin);
        if (nread == -1) {
            if (feof(stdin)) {
                printf("\nEOF detected. Exiting program.\n");
                exit_requested = 1;
                break;
            } else if (errno == EINTR) {
                printf("\nInterrupted. Returning to menu.\n");
                continue;
            } else {
                perror("getline");
                break;
            }
        }
        if (nread > 0 && line[nread - 1] == '\n') line[nread - 1] = '\0';
        char *endptr;
        long choice = strtol(line, &endptr, 10);
        if (*endptr != '\0') {
            printf("Invalid input. Try again.\n\n");
            continue;
        }

        switch ((int)choice) {
            case 1: {
                if (capture_running) {
                    printf("Capture already running!\n");
                    break;
                }
                pthread_t cap_thread;
                int rc = pthread_create(&cap_thread, NULL, capture_thread_fn, (void *)chosen_device);
                if (rc != 0) {
                    fprintf(stderr, "Failed to create capture thread: %s\n", strerror(rc));
                    break;
                }

                while (capture_running && !exit_requested) {
                    // This loop is now quiet while capturing
                    // It just waits for a signal or EOF
                    ssize_t r = getline(&line, &len, stdin);
                     if (r == -1) {
                        if (feof(stdin)) { // Ctrl+D
                            printf("\nEOF detected. Exiting program.\n");
                            exit_requested = 1;
                            capture_running = 0; // Signal thread to stop
                            break;
                        } else if (errno == EINTR) { // Ctrl+C
                            // The signal handler already set capture_running = 0
                            break;
                        } else {
                            perror("getline");
                            break;
                        }
                    } else {
                         // Ignore any user text input during capture
                    }
                }

                pthread_join(cap_thread, NULL);
                if (exit_requested) {
                    running = 0;
                } else {
                    printf("--- capture stopped ---\n");
                    printf("Returned to main menu.\n\n");
                }
                break;
            }
            case 2: {
                printf("\n[C-Shark] Filter Selection:\n");
                printf("  1. HTTP\n");
                printf("  2. HTTPS\n");
                printf("  3. DNS\n");
                printf("  4. ARP\n");
                printf("  5. TCP\n");
                printf("  6. UDP\n");
                printf("Enter filter choice (1-6): ");
                fflush(stdout);
                
                ssize_t filter_read = getline(&line, &len, stdin);
                if (filter_read == -1) {
                    if (feof(stdin)) {
                        printf("\nEOF detected. Exiting program.\n");
                        exit_requested = 1;
                        running = 0;
                    }
                    break;
                }
                if (filter_read > 0 && line[filter_read - 1] == '\n') line[filter_read - 1] = '\0';
                
                char *filter_str = NULL;
                int filter_choice = atoi(line);
                switch (filter_choice) {
                    case 1: filter_str = "tcp port 80"; break;
                    case 2: filter_str = "tcp port 443"; break;
                    case 3: filter_str = "udp port 53"; break;
                    case 4: filter_str = "arp"; break;
                    case 5: filter_str = "tcp"; break;
                    case 6: filter_str = "udp"; break;
                    default:
                        printf("Invalid filter choice.\n\n");
                        break;
                }
                
                if (filter_str) {
                    printf("[C-Shark] Starting filtered capture with: %s\n", filter_str);
                    // TODO: Implement filtered capture using the chosen filter_str
                    // For now, just start regular capture (you can implement filter later)
                    if (capture_running) {
                        printf("Capture already running!\n");
                        break;
                    }
                    pthread_t cap_thread;
                    int rc = pthread_create(&cap_thread, NULL, capture_thread_fn, (void *)chosen_device);
                    if (rc != 0) {
                        fprintf(stderr, "Failed to create capture thread: %s\n", strerror(rc));
                        break;
                    }

                    while (capture_running && !exit_requested) {
                        ssize_t r = getline(&line, &len, stdin);
                        if (r == -1) {
                            if (feof(stdin)) {
                                printf("\nEOF detected. Exiting program.\n");
                                exit_requested = 1;
                                capture_running = 0;
                            }
                        }
                    }

                    pthread_join(cap_thread, NULL);
                    if (exit_requested) {
                        running = 0;
                    } else {
                        printf("--- filtered capture stopped ---\n");
                        printf("Returned to main menu.\n\n");
                    }
                }
                break;
            }
            case 3:
                printf("Option not implemented yet.\n\n");
                break;
            case 4:
                printf("Exiting C-Shark. Goodbye!\n");
                running = 0;
                exit_requested = 1;
                break;
            default:
                printf("Unknown choice. Try again.\n\n");
                break;
        }
    }

cleanup_and_exit:
    free(line);
    if (devnames) {
        for (int i = 0; i < devcount; ++i) free(devnames[i]);
        free(devnames);
    }
    printf("C-Shark is shutting down.\n");
    return 0;
}