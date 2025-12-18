#include "kernel/types.h"
#include "user/user.h"

int global = 12345;  // should live in .data

int main() {
  printf("Global var: %d\n", global);  // read from data segment
  exit(0);
}
