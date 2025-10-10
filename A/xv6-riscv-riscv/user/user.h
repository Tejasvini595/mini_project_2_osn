#define SBRK_ERROR ((char *)-1)

typedef unsigned int uint;

struct stat;

// Memory statistics structures - must match kernel/memstat.h
#define MAX_PAGES_INFO 128 // Max pages to report per syscall

// Page states - used to track whether a page is mapped, resident, or swapped
#define UNMAPPED 0  // Page is not allocated (lazy allocation)
#define RESIDENT 1  // Page is currently in physical memory
#define SWAPPED  2  // Page has been swapped out to disk

// Individual page statistics
struct page_stat {
  unsigned long va;      // Virtual address (page-aligned)
  int state;             // UNMAPPED, RESIDENT, or SWAPPED
  int is_dirty;          // 1 if page has been written to, 0 otherwise
  int seq;               // FIFO sequence number for replacement policy
  int swap_slot;         // Swap slot number if swapped (-1 otherwise)
};

// Overall process memory statistics
struct proc_mem_stat {
  int pid;                    // Process ID
  int num_pages_total;        // Total virtual pages (resident + swapped + unmapped)
  int num_resident_pages;     // Pages currently in physical memory
  int num_swapped_pages;      // Pages currently swapped out
  int next_fifo_seq;          // Next FIFO sequence number to assign
  struct page_stat pages[MAX_PAGES_INFO]; // Individual page information
};

// system calls
int fork(void);
int exit(int) __attribute__((noreturn));
int wait(int*);
int pipe(int*);
int write(int, const void*, int);
int read(int, void*, int);
int close(int);
int kill(int);
int exec(const char*, char**);
int open(const char*, int);
int mknod(const char*, short, short);
int unlink(const char*);
int fstat(int fd, struct stat*);
int link(const char*, const char*);
int mkdir(const char*);
int chdir(const char*);
int dup(int);
int getpid(void);
char* sys_sbrk(int,int);
int pause(int);
int uptime(void);
int memstat(struct proc_mem_stat*);
int enable_bonus(void);

// ulib.c
int stat(const char*, struct stat*);
char* strcpy(char*, const char*);
void *memmove(void*, const void*, int);
char* strchr(const char*, char c);
int strcmp(const char*, const char*);
char* gets(char*, int max);
uint strlen(const char*);
void* memset(void*, int, uint);
int atoi(const char*);
int memcmp(const void *, const void *, uint);
void *memcpy(void *, const void *, uint);
char* sbrk(int);
char* sbrklazy(int);

// printf.c
void fprintf(int, const char*, ...) __attribute__ ((format (printf, 2, 3)));
void printf(const char*, ...) __attribute__ ((format (printf, 1, 2)));

// umalloc.c
void* malloc(uint);
void free(void*);
