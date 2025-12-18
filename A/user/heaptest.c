#include "kernel/types.h"
#include "user/user.h"

int main() {
  char *p = sbrk(4096);   // request 1 page
  // do not touch it yet
  printf("Allocated, but not touched.\n");

  *p = 42;   // first write → should trigger PAGEFAULT → ALLOC
  printf("Heap write successful.\n");
  exit(0);
}
