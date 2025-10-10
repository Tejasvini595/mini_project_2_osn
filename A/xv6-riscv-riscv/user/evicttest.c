#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    int pages = 100;   // Try to allocate 100 pages to force eviction
    int i;
    char *p;

    printf("evicttest starting: allocating %d pages\n", pages);

    for(i = 0; i < pages; i++){
        p = sbrk(4096);   // grow by 1 page
        if(p == (char*)-1){
            printf("sbrk failed at page %d\n", i);
            exit(1);
        }
        // Touch the page so it faults and gets allocated
        p[0] = i & 0xFF;  // Write some data to make it dirty
        printf("Allocated and touched page %d at va=0x%p\n", i, p);
        
        // Small delay to see logs clearly
        if(i > 0 && i % 10 == 0) {
            printf("--- Allocated %d pages so far ---\n", i);
        }
    }

    printf("evicttest completed allocations\n");
    exit(0);
}
