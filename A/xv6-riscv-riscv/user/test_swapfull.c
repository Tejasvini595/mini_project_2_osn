//part3 - Test 5: Swap-full termination
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  printf("Swap-full test starting\n");
  
  // Allocate more than 1024 pages (your swap cap)
  char *a = sbrk(1200 * 4096);
  for(int i = 0; i < 1200; i++) {
    a[i * 4096] = i;   // force dirty evictions
    if(i % 100 == 99) {
      printf("Allocated %d pages so far\n", i + 1);
    }
  }
  printf("Should not reach here - swap should be full\n");
  exit(0);
}
