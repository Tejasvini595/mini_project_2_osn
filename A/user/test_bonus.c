#include "user/user.h"

int main(void) {
    struct proc_mem_stat stat;
    
    printf("=== BONUS: LFU-Recent Algorithm Test ===\n");
    
    // Test with FIFO first
    printf("\n1. Testing with FIFO algorithm (default):\n");
    if (memstat(&stat) < 0) {
        printf("memstat() failed\n");
        exit(1);
    }
    printf("  FIFO - Total pages: %d, Resident: %d, Swapped: %d\n", 
           stat.num_pages_total, stat.num_resident_pages, stat.num_swapped_pages);
    
    // Enable bonus algorithm
    printf("\n2. Enabling LFU-Recent algorithm...\n");
    enable_bonus();
    
    // Allocate some memory to trigger page usage
    char *ptr1 = sbrk(4096);  // Allocate 1 page
    char *ptr2 = sbrk(4096);  // Allocate another page
    
    // Write to the pages to make them dirty and trigger access tracking
    *ptr1 = 'A';
    *ptr2 = 'B';
    
    // Access ptr1 multiple times to increase its frequency
    for(int i = 0; i < 5; i++) {
        *ptr1 = 'A' + i;
    }
    
    printf("\n3. Testing with LFU-Recent algorithm:\n");
    if (memstat(&stat) < 0) {
        printf("memstat() failed\n");
        exit(1);
    }
    printf("  LFU-Recent - Total pages: %d, Resident: %d, Swapped: %d\n", 
           stat.num_pages_total, stat.num_resident_pages, stat.num_swapped_pages);
    
    printf("\n4. Page details:\n");
    for(int i = 0; i < stat.num_pages_total && i < 10; i++) {
        if(stat.pages[i].va != 0) {
            printf("  Page %d: va=0x%lx state=%s dirty=%d\n", 
                   i, stat.pages[i].va, 
                   (stat.pages[i].state == RESIDENT) ? "RESIDENT" : 
                   (stat.pages[i].state == SWAPPED) ? "SWAPPED" : "UNMAPPED",
                   stat.pages[i].is_dirty);
        }
    }
    
    printf("\nBONUS: LFU-Recent algorithm test completed!\n");
    exit(0);
}
