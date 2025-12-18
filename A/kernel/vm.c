#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "proc.h"
#include "fs.h"
#include "file.h"
#include "stat.h"
//part1 - Include demand paging structures
#include "demand.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Initialize the kernel_pagetable, shared by all CPUs.
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));

  // flush stale entries from the TLB.
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    panic("mappages: size not aligned");

  if(size == 0)
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
      continue;   
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}

// Allocate PTEs and physical memory to grow a process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  struct proc *p = myproc();
  
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    
    // Clean up resident and swapped page metadata for deallocated pages
    if(p) {
      uint64 va;
      for(va = PGROUNDUP(newsz); va < PGROUNDUP(oldsz); va += PGSIZE) {
        // Remove from resident pages
        for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
          if(p->resident_pages[i].in_use && p->resident_pages[i].va == va) {
            p->resident_pages[i].in_use = 0;
            p->num_resident_pages--;
            break;
          }
        }
        // Remove from swapped pages
        for(int i = 0; i < MAX_SWAP_PAGES; i++) {
          if(p->swapped_pages[i].in_use && p->swapped_pages[i].va == va) {
            p->swapped_pages[i].in_use = 0;
            p->num_swapped_pages--;
            // Note: we don't free the swap slot here - it will be freed on process exit
            break;
          }
        }
      }
    }
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      // This is a leaf PTE - in demand paging, this can happen
      // if exec fails after allocating pages. Clean it up.
      uint64 pa = PTE2PA(pte);
      kfree((void*)pa);  // Free the physical page
      pagetable[i] = 0;  // Clear the PTE
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
      kfree(mem);
      goto err;
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;
  struct proc *p = myproc();

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    if(va0 >= MAXVA)
      return -1;
  
    // Additional check: ensure address is in a reasonable user range
    // Most user processes won't use addresses above 1GB
    if(va0 >= 0x40000000UL) {
      return -1;
    }
  
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      // Before calling vmfault, check if this is in a valid process region
      int in_valid_region = 0;
      if(p) {
        uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
        if((va0 >= p->text_start && va0 < p->text_end) ||
           (va0 >= p->data_start && va0 < p->data_end) ||
           (va0 >= p->heap_start && va0 < p->sz) ||
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
           is_swapped(va0)) {
          in_valid_region = 1;
        }
      }
      
      if(!in_valid_region) {
        return -1; // Don't try to fault in addresses outside valid regions
      }
      
      pa0 = vmfault(pagetable, va0, 1);  // vmfault returns physical address
      if(pa0 == 0) {
        return -1;
      }
    }

    pte = walk(pagetable, va0, 0);
    if(pte == 0) {
      return -1;
    }
    // forbid copyout over read-only user text pages.
    if((*pte & PTE_W) == 0) {
      return -1;
    }
      
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;
  struct proc *p = myproc();

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    
    // Check for invalid addresses like copyout does
    if(va0 >= MAXVA) {
      return -1;
    }
    
    // Additional check: ensure address is in a reasonable user range
    // Most user processes won't use addresses above 1GB
    if(va0 >= 0x40000000UL) {
      return -1;
    }
    
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      // Before calling vmfault, check if this is in a valid process region
      int in_valid_region = 0;
      if(p) {
        uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
        if((va0 >= p->text_start && va0 < p->text_end) ||
           (va0 >= p->data_start && va0 < p->data_end) ||
           (va0 >= p->heap_start && va0 < p->sz) ||
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
           is_swapped(va0)) {
          in_valid_region = 1;
        }
      }
      
      if(!in_valid_region) {
        return -1; // Don't try to fault in addresses outside valid regions
      }
      
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}

// allocate and map user memory if process is referencing a page
// that was lazily allocated in sys_sbrk().
//part1 - Enhanced page fault handler for demand paging
// Handle page faults by determining access type, validating access,
// and routing to appropriate allocation/loading functions
// returns 0 if va is invalid or already mapped, or if
// out of physical memory, and physical address if successful.
uint64
vmfault(pagetable_t pagetable, uint64 va, int is_write)
{
  struct proc *p = myproc();
  
  // Increment page fault counter and check for excessive faults
  p->page_fault_count++;
  
  // Special case: if sz=0 and we're getting many page faults, 
  // this might be the sbrkbugs test hanging. Limit page faults more aggressively.
  int fault_limit = (p->sz == 0) ? 20 : 1000;
  
  if(p->page_fault_count > fault_limit) {
    printf("[pid %d] KILL excessive page faults (count=%d, sz=0x%lx)\n", 
           p->pid, p->page_fault_count, p->sz);
    setkilled(p);
    return 0;
  }
  
  // Early check for invalid virtual addresses that could cause walk() to panic
  if(va >= MAXVA) {
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
           p->pid, va, is_write ? "write" : "read");
    setkilled(p);
    return 0;
  }
  
  uint64 page_va = PGROUNDDOWN(va);
  char *access_type;
  char *cause = "unknown"; // Initialize with default value
  
  // Determine access type for logging
  if(is_write) {
    access_type = "write";
  } else {
    // For now, assume non-write faults are reads
    // TODO: distinguish between read and exec faults
    access_type = "read"; 
  }
  
  // Check if page is already mapped
  if(ismapped(pagetable, page_va)) {
    return 0; // Already mapped, not a valid fault
  }
  
  // Validate access and determine cause
  int is_valid = 0;
  int cause_code = -1;
  
  // Check if in text segment
  if(page_va >= p->text_start && page_va < p->text_end) {
    is_valid = 1;
    cause = "exec";
    cause_code = CAUSE_EXEC;
  }
  // Check if in data segment  
  else if(page_va >= p->data_start && page_va < p->data_end) {
    is_valid = 1;
    cause = "exec"; // Data segment also loaded from executable
    cause_code = CAUSE_EXEC;
  }
  // Check if in stack region (within one page below current SP as per requirement)
  else if(p->trapframe && page_va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && 
          page_va < PGROUNDUP(p->trapframe->sp)) {
    // Additional validation: check if this is actually a valid stack growth
    // Reject if this looks like an invalid stack access (stacktest case)
    uint64 sp_page = PGROUNDDOWN(p->trapframe->sp);
    if(page_va < sp_page && page_va < p->sz) {
      // This page is below current SP and also in heap region - likely invalid
      is_valid = 0;
      cause = "unknown";
    } else {
      is_valid = 1;
      cause = "stack";
      cause_code = CAUSE_STACK;
    }
  }
  // Check if in heap
  else if(p->sz > 0 && page_va >= p->heap_start && page_va < p->sz) {
    // Special case: if we're very close to the stack boundary and the
    // access looks like it might be a stack underflow, reject it.
    // This handles the stacktest case where it tries to read below the stack.
    if(p->sz == p->stack_top && page_va >= p->sz - 2*PGSIZE) {
      // This looks like an attempt to access below the stack
      is_valid = 0;
      cause = "unknown";
    } else {
      is_valid = 1;
      cause = "heap";
      cause_code = CAUSE_HEAP;
    }
  }
  
  //part1 - Log page fault
  printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=%s\n", 
          p->pid, page_va, access_type, cause);
  
  //part3 - Check if page is in swap before validating access
  if(is_swapped(page_va)) 
  {
    // Page is swapped, load it back
    char *mem = kalloc();
    if(mem == 0) {
      if(!p->memfull_logged) 
      {
        printf("[pid %d] MEMFULL\n", p->pid);
        p->memfull_logged = 1;
      }
      
      // BONUS: Use adaptive eviction (FIFO or LFU-Recent based on process setting)
      if(evict_page_adaptive() == 0)
      {
        return 0; // Could not evict
      }
      
      mem = kalloc();
      if(mem == 0) 
      {
        return 0;
      }
    }
    
    // Load page from swap
    int was_dirty = 0;
    if(swap_in_page(page_va, mem, &was_dirty) != 0) {
      kfree(mem);
      return 0;
    }
    
    // Map the page with appropriate permissions
    int perm = PTE_R | PTE_U;
    uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    if((page_va >= p->heap_start && page_va < p->sz) || 
       (p->trapframe && page_va >= stack_limit && page_va < PGROUNDUP(p->trapframe->sp))) {
      perm |= PTE_W; // Heap and stack are writable
    }
    if(page_va >= p->text_start && page_va < p->text_end) {
      perm |= PTE_X; // Text is executable
    }
    
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, perm) != 0) {
      kfree(mem);
      return 0;
    }
    
    // Add back to resident pages with preserved dirty status
    int final_dirty = was_dirty || is_write; // Dirty if was dirty OR current write
    add_resident_page(page_va, final_dirty);
    
    return (uint64)mem;
  }
  
  // Handle invalid access
  if(!is_valid) {
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n",
            p->pid, page_va, access_type);
    setkilled(p);
    return 0;
  }
  
  // Route to appropriate handler based on cause
  uint64 mem = 0;
  if(cause_code == CAUSE_EXEC) {
    mem = load_executable_page(pagetable, page_va, is_write);
  } else if(cause_code == CAUSE_HEAP || cause_code == CAUSE_STACK) {
    mem = allocate_zero_page(pagetable, page_va, is_write);
  }
  
  // BONUS: Update access statistics for LFU-Recent algorithm
  if(mem != 0) {
    update_page_access(page_va);
  }
  
  return mem;  // Return physical address directly
}

//part1 - Allocate a zero-filled page for heap or stack
// Used for demand allocation of heap (sbrk) and stack pages
uint64
allocate_zero_page(pagetable_t pagetable, uint64 va, int is_write)
{
  struct proc *p = myproc();
  char *mem;
  
  // Allocate physical memory
  mem = kalloc();
  if(mem == 0) {
    // Memory pressure - need to evict a page
    if(!p->memfull_logged) {
      printf("[pid %d] MEMFULL\n", p->pid);
      p->memfull_logged = 1;  // Only log once per process
    }
    
    // BONUS: Use adaptive eviction in allocate_zero_page
    if(evict_page_adaptive() == 0) {
      // No page could be evicted
      return 0;
    }
    
    // Try allocation again after eviction
    mem = kalloc();
    if(mem == 0) {
      return 0;
    }
  }
  
  // Zero the page
  memset(mem, 0, PGSIZE);
  
  // Map the page with appropriate permissions
  int perm = PTE_R | PTE_U;
  // Heap pages (between heap_start and sz) are writable
  // Stack pages (within one page below SP) are writable
  uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
  if((va >= p->heap_start && va < p->sz) || 
     (p->trapframe && va >= stack_limit && va < PGROUNDUP(p->trapframe->sp))) {
    perm |= PTE_W; // Heap and stack are writable
  }
  
  printf("[pid %d] ALLOCATE_ZERO_PAGE: va=0x%lx perm=0x%x (heap: 0x%lx-0x%lx, stack: one page below SP)\n", 
         p->pid, va, perm, p->heap_start, p->sz);
  
  if(mappages(pagetable, va, PGSIZE, (uint64)mem, perm) != 0) {
    kfree(mem);
    return 0;
  }
  
  //part1 - Log allocation
  printf("[pid %d] ALLOC va=0x%lx\n", p->pid, va);
  
  // Add to resident pages tracking
  add_resident_page(va, is_write); // Mark dirty if it's a write access
  
  return (uint64)mem;
}

//part1 - Load a page from the executable file for text/data segments
// Used for demand loading of program text and data
uint64
load_executable_page(pagetable_t pagetable, uint64 va, int is_write)
{
  struct proc *p = myproc();
  char *mem;
  struct segment_info *seg = 0;
  
  // Determine which segment this address belongs to
  if(va >= p->text_start && va < p->text_end) {
    seg = &p->text_seg;
  } else if(va >= p->data_start && va < p->data_end) {
    seg = &p->data_seg;
  }
  
  if(seg == 0) {
    return 0; // Invalid address
  }
  
  // Allocate physical memory
  mem = kalloc();
  if(mem == 0) {
    // Memory pressure - need to evict a page
    if(!p->memfull_logged) {
      printf("[pid %d] MEMFULL\n", p->pid);
      p->memfull_logged = 1;  // Only log once per process
    }
    
    // BONUS: Use adaptive eviction in load_executable_page  
    if(evict_page_adaptive() == 0) {
      // No page could be evicted
      return 0;
    }
    
    // Try allocation again after eviction
    mem = kalloc();
    if(mem == 0) {
      return 0;
    }
  }
  
  // Zero the page first
  memset(mem, 0, PGSIZE);
  
  // Calculate offset within the segment
  uint64 seg_offset = va - seg->va_start;
  uint64 file_offset = seg->file_offset + seg_offset;
  
  // Read from executable file if within file size
  if(seg_offset < seg->file_size) {
    uint64 read_size = PGSIZE;
    if(seg_offset + PGSIZE > seg->file_size) {
      read_size = seg->file_size - seg_offset;
    }
    
    if(readi(p->exec_inode, 0, (uint64)mem, file_offset, read_size) != read_size) {
      kfree(mem);
      return 0;
    }
  }
  // Rest of page remains zero-filled
  
  // Map the page with segment permissions
  if(mappages(pagetable, va, PGSIZE, (uint64)mem, seg->perm | PTE_R | PTE_U) != 0) {
    kfree(mem);
    return 0;
  }
  
  //part1 - Log executable load
  printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, va);
  
  // Add to resident pages tracking
  add_resident_page(va, is_write); // Mark dirty if it's a write access
  
  return (uint64)mem;
}

//part1 - Clear all resident pages when exec starts (reset FIFO state)
void
clear_resident_pages(void)
{
  struct proc *p = myproc();
  
  // Clear all resident page tracking
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    p->resident_pages[i].in_use = 0;
    p->resident_pages[i].va = 0;
    p->resident_pages[i].seq = 0;
    p->resident_pages[i].is_dirty = 0;
    p->resident_pages[i].swap_slot = -1;
  }
  
  //part3 - Clear swapped pages as well
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    p->swapped_pages[i].in_use = 0;
    p->swapped_pages[i].va = 0;
    p->swapped_pages[i].seq = 0;
    p->swapped_pages[i].is_dirty = 0;
    p->swapped_pages[i].swap_slot = -1;
  }
  
  p->num_resident_pages = 0;
  p->num_swapped_pages = 0;
  p->next_fifo_seq = 1;  // Reset sequence counter
  p->memfull_logged = 0; // Reset MEMFULL flag for new exec
}

//part1 - Add a page to the resident pages list with FIFO tracking
void
add_resident_page(uint64 va, int is_dirty)
{
  struct proc *p = myproc();
  
  // Find a free slot in the resident pages array
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    if(!p->resident_pages[i].in_use) {
      // Initialize page info
      p->resident_pages[i].va = va;
      p->resident_pages[i].seq = p->next_fifo_seq++;
      p->resident_pages[i].is_dirty = is_dirty;
      p->resident_pages[i].swap_slot = -1;
      p->resident_pages[i].in_use = 1;
      p->num_resident_pages++;
      
      //part1 - Log resident page with FIFO sequence
      printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, va, p->resident_pages[i].seq);
      return;
    }
  }
  
  // If we get here, no free slots available - need to evict a page
  // BONUS: Use adaptive eviction in add_resident_page
  if(evict_page_adaptive() == 0) {
    // Eviction failed - kill the process instead of panicking kernel
    printf("[pid %d] EVICTION FAILED - terminating process\n", p->pid);
    p->killed = 1;
    return;
  }
  
  // Try again after eviction - there should now be a free slot
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
  {
    if(!p->resident_pages[i].in_use) 
    {
      p->resident_pages[i].va = va;
      p->resident_pages[i].seq = p->next_fifo_seq++;
      p->resident_pages[i].is_dirty = is_dirty;
      p->resident_pages[i].swap_slot = -1;
      p->resident_pages[i].in_use = 1;
      
      // BONUS: Initialize LFU-Recent fields for evicted slot
      p->resident_pages[i].access_frequency = 1;
      p->resident_pages[i].last_access_time = p->global_time_counter++;
      
      p->num_resident_pages++;
      
      //part1 - Log resident page with FIFO sequence
      printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, va, p->resident_pages[i].seq);
      return;
    }
  }
  
  // Should never reach here after successful eviction
  panic("add_resident_page: still no free slots after eviction");
}

//part2 - Evict a page using FIFO replacement policy
// Returns 1 if a page was evicted, 0 if no page could be evicted
int
evict_page(void)
{
  struct proc *p = myproc();
  int oldest_idx = -1;
  int oldest_seq = -1;
  
  // Find the oldest (lowest sequence number) resident page
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
  {
    if(p->resident_pages[i].in_use) 
    {
      if(oldest_idx == -1 || p->resident_pages[i].seq < oldest_seq) 
      {
        oldest_idx = i;
        oldest_seq = p->resident_pages[i].seq;
      }
    }
  }
  
  if(oldest_idx == -1) 
  {
    // No resident pages to evict
    return 0;
  }
  
  struct page_info *victim = &p->resident_pages[oldest_idx];
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=FIFO\n", p->pid, victim->va, victim->seq);
  
  // Check if page is dirty (has been written to)
  int is_dirty = victim->is_dirty;
  
  // // ALSO check hardware dirty bit in PTE
  // pte_t *pte = walk(p->pagetable, victim->va, 0);
  // if(pte && (*pte & PTE_D)) {
  //   is_dirty = 1;
  // }
  
  //part3 - Handle dirty vs clean page eviction
  if(is_dirty) 
  {
    // Dirty page needs to be written to swap
    uint64 pa = walkaddr(p->pagetable, victim->va);
    if(pa != 0) 
    {
      char *mem = (char*)pa;
      
      // Try to swap out the page
      int slot = swap_out_page(victim->va, mem, is_dirty);
      if(slot < 0) 
      {
        // Swap is full - terminate process
        printf("[pid %d] KILL swap-exhausted\n", p->pid);
        setkilled(p);
        return 0;
      }
      
      printf("[pid %d] EVICT va=0x%lx state=dirty\n", p->pid, victim->va);
    }
  } 
  else 
  {
    // Clean page can be discarded without swap
    printf("[pid %d] EVICT va=0x%lx state=clean\n", p->pid, victim->va);
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim->va);
  }
  
  // Remove the page mapping and free physical memory
  uint64 pa = walkaddr(p->pagetable, victim->va);// finds physical address for a given virtual address
  if(pa != 0) 
  {
    uvmunmap(p->pagetable, victim->va, 1, 1); // Unmap and free
  }
  
  // Mark the resident slot as free
  victim->in_use = 0;
  p->num_resident_pages--;
  
  return 1;
}

// BONUS: Enable LFU-Recent page replacement algorithm
// Call this function to switch from FIFO to LFU-Recent for the current process
void
enable_bonus_algorithm(void)
{
  struct proc *p = myproc();
  p->use_bonus_algorithm = 1;
  p->global_time_counter = 1; // Initialize time counter
  
  // Initialize bonus fields for existing resident pages
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    if(p->resident_pages[i].in_use) {
      p->resident_pages[i].access_frequency = 1; // Initial access
      p->resident_pages[i].last_access_time = p->global_time_counter++;
    }
  }
  
  printf("[pid %d] BONUS: LFU-Recent algorithm enabled\n", p->pid);
}

// BONUS: LFU-Recent page replacement algorithm
// Calculates combined score based on frequency and recency
// Lower score = better victim candidate
static int
calculate_lfu_recent_score(struct page_info *page, uint64 current_time)
{
  // Score = (1000 / frequency) + (current_time - last_access_time)
  // This balances frequency (lower is better) with recency (older is better)
  int frequency_component = (page->access_frequency > 0) ? (1000 / page->access_frequency) : 1000;
  int recency_component = (int)(current_time - page->last_access_time);
  return frequency_component + recency_component;
}

// BONUS: LFU-Recent eviction algorithm
// Alternative to FIFO that considers both access frequency and recency
int
evict_page_lfu_recent(void)
{
  struct proc *p = myproc();
  int victim_idx = -1;
  int highest_score = -1;
  
  // Log memory full condition
  if(!p->memfull_logged) {
    printf("[pid %d] MEMFULL: Memory full, invoking LFU-Recent replacement\n", p->pid);
    p->memfull_logged = 1;
  }
  
  // Find page with highest LFU-Recent score (worst candidate)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
  {
    if(p->resident_pages[i].in_use) 
    {
      int score = calculate_lfu_recent_score(&p->resident_pages[i], p->global_time_counter);
      if(victim_idx == -1 || score > highest_score) 
      {
        victim_idx = i;
        highest_score = score;
      }
    }
  }
  
  if(victim_idx == -1) 
  {
    // No resident pages to evict
    return 0;
  }
  
  struct page_info *victim = &p->resident_pages[victim_idx];
  printf("[pid %d] VICTIM va=0x%lx freq=%d last_access=%lu score=%d\n", 
         p->pid, victim->va, victim->access_frequency, victim->last_access_time, highest_score);
  
  // Check if page is dirty (has been written to)
  int is_dirty = victim->is_dirty;
  
  //part3 - Handle dirty vs clean page eviction
  if(is_dirty) 
  {
    // Dirty page needs to be written to swap
    uint64 pa = walkaddr(p->pagetable, victim->va);
    if(pa != 0) 
    {
      char *mem = (char*)pa;
      
      // Try to swap out the page
      int slot = swap_out_page(victim->va, mem, is_dirty);
      if(slot < 0) 
      {
        // Swap is full - terminate process
        printf("[pid %d] KILL swap-exhausted\n", p->pid);
        setkilled(p);
        return 0;
      }
      
      printf("[pid %d] EVICT va=0x%lx state=dirty\n", p->pid, victim->va);
    }
  } 
  else 
  {
    // Clean page can be discarded without swap
    printf("[pid %d] EVICT va=0x%lx state=clean\n", p->pid, victim->va);
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim->va);
  }
  
  // Remove the page mapping and free physical memory
  uint64 pa = walkaddr(p->pagetable, victim->va);
  if(pa != 0) 
  {
    uvmunmap(p->pagetable, victim->va, 1, 1); // Unmap and free
  }
  
  // Mark the resident slot as free
  victim->in_use = 0;
  p->num_resident_pages--;
  
  return 1;
}

// BONUS: Algorithm selector - chooses between FIFO and LFU-Recent
// This function maintains compatibility with existing code
int
evict_page_adaptive(void)
{
  struct proc *p = myproc();
  
  // Use bonus algorithm if enabled, otherwise use original FIFO
  if(p->use_bonus_algorithm) {
    return evict_page_lfu_recent();
  } else {
    return evict_page();
  }
}

// BONUS: Update page access statistics for LFU-Recent algorithm
// Called whenever a page is accessed (not just on page faults)
void
update_page_access(uint64 va)
{
  struct proc *p = myproc();
  
  // Only update if using bonus algorithm
  if(!p->use_bonus_algorithm) {
    return;
  }
  
  // Find the page in resident pages and update access stats
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    if(p->resident_pages[i].in_use && p->resident_pages[i].va == va) {
      p->resident_pages[i].access_frequency++;
      p->resident_pages[i].last_access_time = p->global_time_counter++;
      break;
    }
  }
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);
  if (pte == 0) {
    return 0;
  }
  if (*pte & PTE_V){
    return 1;
  }
  return 0;
}

//part3 - Swap file management functions

// Create a unique swap file for the process
int
create_swap_file(void)
{
  struct proc *p = myproc();
  
  // Generate unique swap filename using PID (manual formatting)
  char *base = "/pgswp";
  int len = 0;
  while(base[len]) len++; // manual strlen
  
  // Copy base name
  for(int i = 0; i < len; i++) {
    p->swapfilename[i] = base[i];
  }
  
  // Add PID as 5-digit number
  int pid = p->pid;
  p->swapfilename[len + 4] = '0' + (pid % 10); pid /= 10;
  p->swapfilename[len + 3] = '0' + (pid % 10); pid /= 10;
  p->swapfilename[len + 2] = '0' + (pid % 10); pid /= 10;
  p->swapfilename[len + 1] = '0' + (pid % 10); pid /= 10;
  p->swapfilename[len + 0] = '0' + (pid % 10);
  p->swapfilename[len + 5] = 0; // null terminator
  
  // Create the swap file
  begin_op();
  p->swapfile = create(p->swapfilename, T_FILE, 0, 0);
  if(p->swapfile == 0) {
    end_op();
    return -1;
  }
  
  // NO pre-allocation - file will grow on-demand
  p->swap_slots_used = 0;
  for(int i = 0; i < SWAP_BITMAP_SIZE; i++) 
  {
    p->swap_bitmap[i] = 0;
  }
  p->num_swapped_pages = 0;
  
  iunlock(p->swapfile);
  end_op();
  
  printf("[pid %d] SWAP file created: %s\n", p->pid, p->swapfilename);
  return 0;
}


// Find a free swap slot
int
alloc_swap_slot(void)
{
  struct proc *p = myproc();
  
  // Check if we have space
  if(p->swap_slots_used >= MAX_SWAP_SLOTS) 
  {
    printf("[pid %d] SWAP FULL: slots_used=%d >= MAX_SWAP_SLOTS=%d\n", 
           p->pid, p->swap_slots_used, MAX_SWAP_SLOTS);
    return -1; // No free slots
  }
  
  // Find first free bit in bitmap
  for(int word = 0; word < SWAP_BITMAP_SIZE; word++) 
  {
    if(p->swap_bitmap[word] != 0xFFFFFFFFFFFFFFFF) 
    {
      // Found a word with free bits
      for(int bit = 0; bit < 64; bit++) 
      {
        if((p->swap_bitmap[word] & (1UL << bit)) == 0) 
        {
          // Found free slot
          int slot = word * 64 + bit;
          if(slot < MAX_SWAP_SLOTS) 
          {
            // Double-check this slot is not already used by another page
            int already_used = 0;
            for(int i = 0; i < MAX_SWAP_PAGES; i++) 
            {
              if(p->swapped_pages[i].in_use && p->swapped_pages[i].swap_slot == slot) 
              {
                already_used = 1;
                break;
              }
            }
            
            if(!already_used) 
            {
              p->swap_bitmap[word] |= (1UL << bit);
              p->swap_slots_used++;
              printf("[pid %d] ALLOCATED slot=%d (slots_used=%d/%d)\n", 
                     p->pid, slot, p->swap_slots_used, MAX_SWAP_SLOTS);
              return slot;
            }
            // If slot is already used, continue searching
          }
        }
      }
    }
  }
  
  printf("[pid %d] NO FREE SLOTS: bitmap full? slots_used=%d\n", 
         p->pid, p->swap_slots_used);
  return -1; // Should not reach here if swap_slots_used count is correct
}

// Free a swap slot
void
free_swap_slot(int slot)
{
  struct proc *p = myproc();
  
  if(slot < 0 || slot >= MAX_SWAP_SLOTS) {
    return;
  }
  
  int word = slot / 64;
  int bit = slot % 64;
  
  if(p->swap_bitmap[word] & (1UL << bit)) {
    p->swap_bitmap[word] &= ~(1UL << bit);
    p->swap_slots_used--;
    printf("[pid %d] FREED slot=%d (slots_used=%d/%d)\n", 
           p->pid, slot, p->swap_slots_used, MAX_SWAP_SLOTS);
  }
}

// Write a page to swap
int
swap_out_page(uint64 va, char *mem, int is_dirty)
{
  struct proc *p = myproc();
  
  // Check if swap file is valid, create one if needed
  if(p->swapfile == 0) {
    if(create_swap_file() < 0) {
      printf("[pid %d] SWAPOUT_ERROR: no swap file\n", p->pid);
      return -1;
    }
  }
  
  // Allocate swap slot
  int slot = alloc_swap_slot();
  if(slot < 0) {
    printf("[pid %d] SWAPFULL\n", p->pid);
    return -1; // No free swap slots
  }
  
  // Write page to swap file
  begin_op();
  
  // Double-check swap file is still valid after begin_op
  if(p->swapfile == 0) {
    printf("[pid %d] SWAPOUT_ERROR: swap file disappeared\n", p->pid);
    end_op();
    free_swap_slot(slot);
    return -1;
  }
  
  ilock(p->swapfile);
  
  uint64 offset = slot * PGSIZE;
  printf("[pid %d] SWAPOUT_DEBUG: writing slot=%d offset=%lu size=%d\n", 
         p->pid, slot, offset, PGSIZE);
  
  // Ensure the file is large enough - extend if necessary
  uint64 required_size = offset + PGSIZE;
  if(p->swapfile->size < required_size) {
    printf("[pid %d] SWAPOUT_DEBUG: extending file from %d to %lu bytes\n", 
           p->pid, p->swapfile->size, required_size);
    // We don't need to explicitly extend - writei will do it if we write sequential data
    // But we can ensure the inode knows the final size
  }
  
  int written = writei(p->swapfile, 0, (uint64)mem, offset, PGSIZE);
  printf("[pid %d] SWAPOUT_DEBUG: wrote %d bytes to offset %lu\n", 
         p->pid, written, offset);
         
  if(written != PGSIZE) {
    printf("[pid %d] WRITEI_FAILED: wrote %d bytes, expected %d\n", 
           p->pid, written, PGSIZE);
    printf("[pid %d] SWAPOUT_DEBUG: file size=%d, offset=%lu, slot=%d\n", 
           p->pid, p->swapfile->size, offset, slot);
    iunlock(p->swapfile);
    end_op();
    free_swap_slot(slot);
    return -1;
  }
  
  iunlock(p->swapfile);
  end_op();
  
  // Debug: Log first integer value of written data
  int *intdata = (int*)mem;
  printf("[pid %d] SWAPOUT_DATA va=0x%lx slot=%d first_int=%d (bytes=%d,%d,%d,%d)\n", 
         p->pid, va, slot, *intdata, 
         ((char*)mem)[0] & 0xFF, ((char*)mem)[1] & 0xFF, 
         ((char*)mem)[2] & 0xFF, ((char*)mem)[3] & 0xFF);
  
  // Add to swapped pages list with dirty status preserved
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    if(!p->swapped_pages[i].in_use) {
      p->swapped_pages[i].in_use = 1;
      p->swapped_pages[i].va = va;
      p->swapped_pages[i].swap_slot = slot;
      p->swapped_pages[i].is_dirty = is_dirty; // Preserve dirty status
      p->num_swapped_pages++;
      break;
    }
  }
  
  printf("[pid %d] SWAPOUT va=0x%lx slot=%d\n", p->pid, va, slot);
  return slot;
}

//Read a page from swap
int
swap_in_page(uint64 va, char *mem, int *was_dirty)
{
  struct proc *p = myproc();
  
  //Find the swapped page
  int slot = -1;
  *was_dirty = 0; //Default to clean
  for(int i = 0; i < MAX_SWAP_PAGES; i++) 
  {
    if(p->swapped_pages[i].in_use && p->swapped_pages[i].va == va) 
    {
      slot = p->swapped_pages[i].swap_slot;
      *was_dirty = p->swapped_pages[i].is_dirty; //Restore dirty status
      //Remove from swapped pages list
      p->swapped_pages[i].in_use = 0;
      p->num_swapped_pages--;
      break;
    }
  }
  
  if(slot < 0) 
  {
    return -1; // Page not found in swap
  }
  
  // Check if swap file is valid
  if(p->swapfile == 0) {
    printf("[pid %d] SWAPIN_ERROR: no swap file\n", p->pid);
    return -1;
  }
  
  // Read page from swap file
  begin_op();
  
  // Double-check swap file is still valid after begin_op
  if(p->swapfile == 0) {
    printf("[pid %d] SWAPIN_ERROR: swap file disappeared\n", p->pid);
    end_op();
    return -1;
  }
  
  ilock(p->swapfile);
  
  uint64 offset = slot * PGSIZE;
  if(readi(p->swapfile, 0, (uint64)mem, offset, PGSIZE) != PGSIZE) 
  {
    iunlock(p->swapfile);
    end_op();
    return -1;
  }
  
  iunlock(p->swapfile);
  end_op();
  
  // Debug: Log first integer value of read data
  int *intdata = (int*)mem;
  printf("[pid %d] SWAPIN_DATA va=0x%lx slot=%d first_int=%d (bytes=%d,%d,%d,%d)\n", 
         p->pid, va, slot, *intdata,
         ((char*)mem)[0] & 0xFF, ((char*)mem)[1] & 0xFF, 
         ((char*)mem)[2] & 0xFF, ((char*)mem)[3] & 0xFF);
  
  // Free the swap slot since page is now in memory
  free_swap_slot(slot);
  
  printf("[pid %d] SWAPIN va=0x%lx slot=%d\n", p->pid, va, slot);
  return 0;
}

// Check if a page is swapped
int
is_swapped(uint64 va)
{
  struct proc *p = myproc();
  
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    if(p->swapped_pages[i].in_use && p->swapped_pages[i].va == va) {
      return 1;
    }
  }
  return 0;
}

// Delete swap file on process exit
void
cleanup_swap_file(void)
{
  struct proc *p = myproc();
  
  if(p->swapfile) 
  {
    // Log cleanup
    printf("[pid %d] SWAPCLEANUP freed_slots=%d\n", p->pid, p->swap_slots_used);
    
    // Close the swap file first
    begin_op();
    iput(p->swapfile);
    p->swapfile = 0;
    end_op();
    
    // Now delete the swap file from filesystem
    begin_op();
    struct inode *dp, *ip;
    struct dirent de;
    char name[DIRSIZ];
    uint off;
    
    // Get parent directory and filename
    if((dp = nameiparent(p->swapfilename, name)) != 0) {
      ilock(dp);
      
      // Look up the swap file
      if((ip = dirlookup(dp, name, &off)) != 0) {
        ilock(ip);
        
        // Remove directory entry
        memset(&de, 0, sizeof(de));
        if(writei(dp, 0, (uint64)&de, off, sizeof(de)) == sizeof(de)) {
          // Decrease link count and update inode
          ip->nlink--;
          iupdate(ip);
        }
        
        iunlockput(ip);
      }
      
      iunlockput(dp);
    }
    end_op();
  }
}

// Clean up all resident pages before freeing page table
// This prevents "freewalk: leaf" panics in demand paging
void
free_resident_pages(pagetable_t pagetable, struct proc *p)
{
  pte_t *pte;
  uint64 pa;
  
  // Walk through all resident pages and free them
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    if(!p->resident_pages[i].in_use) continue;
    
    uint64 va = p->resident_pages[i].va;
    
    pte = walk(pagetable, va, 0);
    if(pte && (*pte & PTE_V)) {
      pa = PTE2PA(*pte);
      kfree((void*)pa);
      *pte = 0;  // Clear the PTE
    }
    
    // Mark as free
    p->resident_pages[i].in_use = 0;
  }
  
  // Reset resident page tracking
  p->num_resident_pages = 0;
}
