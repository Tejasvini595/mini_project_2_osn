//part3 - Test 3: Trigger dirty eviction and swap-out
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70

int main() {
  printf("Dirty eviction test starting\n");
  char *a = sbrk(PAGES * 4096);
  for(int i = 0; i < PAGES; i++) {      // write to all pages
    a[i * 4096] = i;
  }
  printf("Dirty eviction test done\n");
  exit(0);
}
