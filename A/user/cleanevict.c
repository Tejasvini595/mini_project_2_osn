//part3 - Test 2: Trigger clean eviction
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70   // choose > resident limit to force eviction

int main() {
  printf("Clean eviction test starting\n");
  char *a = sbrk(PAGES * 4096);
  for(int i = 0; i < PAGES; i += 2) {   // touch alternate pages read-only
    volatile char x = a[i * 4096];
    (void)x; // suppress unused variable warning
  }
  printf("Clean eviction test done\n");
  exit(0);
}
