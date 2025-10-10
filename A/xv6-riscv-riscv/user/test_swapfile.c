//part3 - Test 1: Per-process swap file creation/cleanup
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  printf("PID = %d starting swapfile test\n", getpid());
  
  // Do some work to keep process alive briefly
  for(int i = 0; i < 1000000; i++) {
    // busy wait
  }
  
  printf("PID = %d swapfile test completed\n", getpid());
  exit(0);
}
