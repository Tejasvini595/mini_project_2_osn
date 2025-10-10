//part3 - Test 6: Multiple processes (isolation test)
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70

int main() {
  int pid = getpid();
  printf("Multi-process test starting (PID %d)\n", pid);
  
  char *a = sbrk(PAGES * 4096);
  for(int i = 0; i < PAGES; i++) {
    a[i * 4096] = pid * 1000 + i;  // unique values per process
  }
  
  printf("PID %d allocated %d pages\n", pid, PAGES);
  
  // Do some work to let other processes run
  for(int j = 0; j < 100000; j++) {
    // busy wait
  }
  
  // Verify our data is still correct
  int errors = 0;
  for(int i = 0; i < PAGES; i++) {
    if(a[i * 4096] != pid * 1000 + i) {
      errors++;
    }
  }
  
  if(errors == 0) {
    printf("PID %d: All data correct after swap isolation test\n", pid);
  } else {
    printf("PID %d: ERROR - %d pages corrupted!\n", pid, errors);
  }
  
  exit(0);
}
