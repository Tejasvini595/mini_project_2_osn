#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "memstat.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_LAZY) {
    // COMPLETELY LAZY mode for sbrklazy() calls
    // Only adjust proc->sz, never allocate/deallocate pages
    
    if(n < 0) {
      // For shrinking, just adjust sz - don't actually free pages
      uint64 new_sz = addr + n;
      if(new_sz < myproc()->heap_start) {
        return -1;  // Error: would shrink below heap start
      }
      myproc()->sz = new_sz;
    } else {
      // For growing, just adjust sz - don't allocate pages
      if(addr + n < addr)
        return -1;
      if(addr + n >= MAXVA)
        return -1;
      
      myproc()->sz += n;
    }
  } else {
    // SBRK_EAGER mode (default for regular sbrk() calls)
    // Use hybrid allocation: lazy growing, immediate shrinking
    
    if(n < 0) {
      // CRITICAL: Don't let sz go below heap_start
      uint64 new_sz = addr + n;
      if(new_sz < myproc()->heap_start) {
        return -1;  // Error: would shrink below heap start
      }
      
      // For shrinking heap, we need to actually deallocate pages
      // The sbrkmuch test expects pages to be freed immediately
      if(growproc(n) < 0) {
        return -1;
      }
    } else {
      //part1 - Lazily allocate memory: increase memory size but don't allocate physical pages
      // Physical pages will be allocated on demand when accessed (page fault)
      if(addr + n < addr)
        return -1;
      if(addr + n > TRAPFRAME)
        return -1;
      
      // BONUS: Add reasonable memory limit to prevent thrashing in usertests
      // Increase limit to allow sbrkmuch test to test swapping (e.g., 65536 pages = 256MB)
      // This allows for large allocations while still preventing infinite loops
      if((addr + n - myproc()->heap_start) > (65536 * PGSIZE)) {
        return -1; // Return error for excessive memory requests
      }
      
      myproc()->sz += n;
    }
  }
  
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

//part4 - Memory statistics system call
uint64
sys_memstat(void)
{
  uint64 info_addr;
  struct proc_mem_stat info;
  struct proc *p = myproc();
  
  // Get the user address for the proc_mem_stat structure
  argaddr(0, &info_addr);
  
  // Fill in the basic process information
  info.pid = p->pid;
  info.num_resident_pages = p->num_resident_pages;
  info.num_swapped_pages = p->num_swapped_pages;
  info.next_fifo_seq = p->next_fifo_seq;
  
  // Calculate total pages from start to proc->sz
  uint64 total_pages = PGROUNDUP(p->sz) / PGSIZE;
  info.num_pages_total = (int)total_pages;
  
  // Initialize pages array
  int page_count = 0;
  
  // Add resident pages
  for(int i = 0; i < MAX_RESIDENT_PAGES && page_count < MAX_PAGES_INFO; i++) {
    if(p->resident_pages[i].in_use) {
      info.pages[page_count].va = p->resident_pages[i].va;
      info.pages[page_count].state = RESIDENT;
      info.pages[page_count].is_dirty = p->resident_pages[i].is_dirty;
      info.pages[page_count].seq = p->resident_pages[i].seq;
      info.pages[page_count].swap_slot = -1;
      page_count++;
    }
  }
  
  // Add swapped pages
  for(int i = 0; i < MAX_SWAP_PAGES && page_count < MAX_PAGES_INFO; i++) {
    if(p->swapped_pages[i].in_use) {
      info.pages[page_count].va = p->swapped_pages[i].va;
      info.pages[page_count].state = SWAPPED;
      info.pages[page_count].is_dirty = p->swapped_pages[i].is_dirty;
      info.pages[page_count].seq = p->swapped_pages[i].seq;
      info.pages[page_count].swap_slot = p->swapped_pages[i].swap_slot;
      page_count++;
    }
  }
  
  // Add unmapped pages (pages that are in the address space but not allocated)
  for(uint64 va = 0; va < p->sz && page_count < MAX_PAGES_INFO; va += PGSIZE) {
    // Check if this page is already reported as resident or swapped
    int already_reported = 0;
    for(int j = 0; j < page_count; j++) {
      if(info.pages[j].va == va) {
        already_reported = 1;
        break;
      }
    }
    
    if(!already_reported && !ismapped(p->pagetable, va)) {
      info.pages[page_count].va = va;
      info.pages[page_count].state = UNMAPPED;
      info.pages[page_count].is_dirty = 0;
      info.pages[page_count].seq = 0;
      info.pages[page_count].swap_slot = -1;
      page_count++;
    }
  }
  
  // Copy the structure to user space
  if(copyout(p->pagetable, info_addr, (char*)&info, sizeof(info)) < 0) {
    return -1;
  }
  
  return 0;
}

// BONUS: System call to enable LFU-Recent page replacement algorithm
uint64
sys_enable_bonus(void)
{
  enable_bonus_algorithm();
  return 0;
}
