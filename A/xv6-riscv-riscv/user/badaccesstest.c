#include "kernel/types.h"
#include "user/user.h"

int main() {
  char *p = (char*)0xFFFFFFFF;  // definitely invalid
  printf("Accessing invalid...\n");
  *p = 1;   // should page fault
  printf("This line should never print!\n");
  exit(0);
}
