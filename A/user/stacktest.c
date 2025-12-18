#include "kernel/types.h"
#include "user/user.h"

int f(int n) {
  char buf[4096];   // allocate 1 page on stack
  buf[0] = n;       // touch new page
  return buf[0];
}

int main() {
  printf("Stack result: %d\n", f(99));
  exit(0);
}
