#include "user/user.h"

int main(void) 
{
    struct proc_mem_stat stat;
    
    // Test the memstat system call
    if (memstat(&stat) < 0) 
    {
        printf("memstat() failed\n");
        exit(1);
    }
    
    printf("Memory statistics for process %d:\n", stat.pid);
    printf("  Total pages: %d\n", stat.num_pages_total);
    printf("  Resident pages: %d\n", stat.num_resident_pages);
    printf("  Swapped pages: %d\n", stat.num_swapped_pages);
    printf("  Next FIFO seq: %d\n", stat.next_fifo_seq);
    
    printf("\nDetailed page information:\n");
    for(int i = 0; i < stat.num_resident_pages + stat.num_swapped_pages && i < 10; i++) {
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
               i, stat.pages[i].va,
               (stat.pages[i].state == RESIDENT) ? "RESIDENT" :
               (stat.pages[i].state == SWAPPED) ? "SWAPPED" : "UNMAPPED",
               stat.pages[i].is_dirty,
               stat.pages[i].seq);
    }
    
    exit(0);
}