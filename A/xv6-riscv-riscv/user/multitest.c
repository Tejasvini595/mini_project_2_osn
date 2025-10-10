#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    int pages = 80;   // Each process allocates 80 pages to force eviction
    int i;
    char *p;
    int pid;

    printf("multitest starting: forking two processes\n");

    pid = fork();
    if(pid == 0) {
        // Child process
        printf("Child process starting allocation\n");
        for(i = 0; i < pages; i++){
            p = sbrk(4096);
            if(p == (char*)-1){
                printf("Child: sbrk failed at page %d\n", i);
                exit(1);
            }
            p[0] = 0xAA;  // Mark child pages with 0xAA
            printf("Child allocated page %d\n", i);
        }
        printf("Child process completed\n");
        exit(0);
    } else {
        // Parent process
        printf("Parent process starting allocation\n");
        for(i = 0; i < pages; i++){
            p = sbrk(4096);
            if(p == (char*)-1){
                printf("Parent: sbrk failed at page %d\n", i);
                exit(1);
            }
            p[0] = 0xBB;  // Mark parent pages with 0xBB
            printf("Parent allocated page %d\n", i);
        }
        wait(0);  // Wait for child to complete
        printf("Parent process completed\n");
    }
    
    exit(0);
}
