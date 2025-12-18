//part1 - Define memstat data structures for system state inspection
// This header defines the structures needed for the memstat system call
// which allows inspection of a process's virtual memory state

#include "types.h"

#define MAX_PAGES_INFO 128 // Max pages to report per syscall

// Page states - used to track whether a page is mapped, resident, or swapped
#define UNMAPPED 0  // Page is not allocated (lazy allocation)
#define RESIDENT 1  // Page is currently in physical memory
#define SWAPPED  2  // Page has been swapped out to disk

// Individual page statistics
struct page_stat {
  uint64 va;      // Virtual address (page-aligned)
  int state;      // UNMAPPED, RESIDENT, or SWAPPED
  int is_dirty;   // 1 if page has been written to, 0 otherwise
  int seq;        // FIFO sequence number for replacement policy
  int swap_slot;  // Swap slot number if swapped (-1 otherwise)
};

// Overall process memory statistics
struct proc_mem_stat {
  int pid;                    // Process ID
  int num_pages_total;        // Total virtual pages (resident + swapped + unmapped)
  int num_resident_pages;     // Pages currently in physical memory
  int num_swapped_pages;      // Pages currently swapped out
  int next_fifo_seq;          // Next FIFO sequence number to assign
  struct page_stat pages[MAX_PAGES_INFO]; // Individual page information
};
