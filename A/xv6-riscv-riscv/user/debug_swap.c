//Debug simple swap test
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  int pid = getpid();
  printf("Debug swap test (PID %d)\n", pid);
  
  // Allocate just a few pages to force swapping
  char *a = sbrk(40 * 4096);  // 40 pages to force some swapping
  
  // Write unique data to first byte of each page
  for(int i = 0; i < 40; i++) {
    a[i * 4096] = 200 + i;  // Write values 200, 201, 202, ...
    printf("Written: page %d = %d\n", i, 200 + i);
  }
  
  printf("All writes complete, now reading back...\n");
  
  // Read back and verify
  int errors = 0;
  for(int i = 0; i < 40; i++) {
    int expected = 200 + i;
    int actual = a[i * 4096];
    printf("Read: page %d = %d (expected %d)\n", i, actual, expected);
    if(actual != expected) {
      errors++;
    }
  }
  
  printf("Debug test done: %d errors out of 40 pages\n", errors);
  exit(0);
}
