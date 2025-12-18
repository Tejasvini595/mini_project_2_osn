//part1 - Define demand paging structures for page tracking
// This header contains structures needed for demand paging implementation
// including page tracking and FIFO replacement policy support

#include "types.h"

// Maximum pages that can be swapped per process (1024 pages = 4MB)
#define MAX_SWAP_PAGES 1024

// Maximum resident pages to track per process  
#define MAX_RESIDENT_PAGES 64

//part3 - Swap management constants
#define MAX_SWAP_SLOTS 1024    // 1024 pages = 4MB as per specification
#define SWAP_BITMAP_SIZE 16     // 16 uint64s for 1024 bits (16*64=1024)

// Page access types for logging
#define ACCESS_READ  0
#define ACCESS_WRITE 1  
#define ACCESS_EXEC  2

// Page fault causes for logging
#define CAUSE_HEAP  0
#define CAUSE_STACK 1
#define CAUSE_EXEC  2
#define CAUSE_SWAP  3

// Structure to track individual pages in a process
// Used for maintaining resident and swapped page lists
struct page_info {
  uint64 va;                    // Virtual address (page-aligned)
  int seq;                      // FIFO sequence number for replacement
  int is_dirty;                 // Dirty flag (1 if written since loaded)
  int swap_slot;                // Swap slot number (-1 if not swapped)
  int in_use;                   // 1 if this slot is in use, 0 if free
  
  // BONUS: LFU-Recent algorithm tracking fields
  int access_frequency;         // Number of times this page has been accessed
  uint64 last_access_time;      // Last time this page was accessed (for recency)
};

// Executable segment information stored during exec
// Used for demand loading of text/data pages
struct segment_info {
  uint64 va_start;              // Virtual address start
  uint64 va_end;                // Virtual address end  
  uint64 file_offset;           // Offset in executable file
  uint64 file_size;             // Size in file
  int perm;                     // Page permissions (PTE_R, PTE_W, PTE_X)
};
