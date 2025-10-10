//part3 - Test 4: Trigger swap-in
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70

int main() {
  printf("Swap-in test starting\n");
  int *a = (int*)sbrk(PAGES * 4096);
  
  // Write to all pages (make them dirty)
  for(int i = 0; i < PAGES; i++) {
    a[i * 1024] = i; // Store full integers, 1024 ints per page
  }
  
  // Force eviction by allocating more pages
  printf("Forcing more evictions...\n");
  for(int i = PAGES; i < 2 * PAGES; i++) {
    int *b = (int*)sbrk(4096);
    *b = i; // write to trigger dirty eviction
  }
  
  // Now re-access first half to trigger swap-in
  printf("Re-accessing swapped pages...\n");
  for(int i = 0; i < PAGES; i++) {
    printf("%d ", a[i * 1024]);
    if(i % 10 == 9) printf("\n"); // newline every 10 numbers
  }
  printf("\nSwap-in test done\n");
  exit(0);
}
