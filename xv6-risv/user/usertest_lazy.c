#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  printf("Demand Paging Test: touching memory lazily...\n");

  // Allocate 10 pages lazily
  sbrk(10 * 4096);

  char *p = (char*)0x4000;  // start touching at 16KB
  for (int i = 0; i < 10; i++) {
    p[i*4096] = 42;   // touch one byte per page
    printf("Touched page %d at %p\n", i, &p[i*4096]);
  }

  exit(0);
}
