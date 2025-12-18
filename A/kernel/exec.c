#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"
#include "demand.h"

//part1 - Commented out loadseg declaration since we're using demand loading
//static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    int perm = 0;
    if(flags & 0x1)
      perm = PTE_X;
    if(flags & 0x2)
      perm |= PTE_W;
    return perm;
}

//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();

  begin_op();

  //part1 - Debug: exec starting
  printf("[pid %d] EXEC starting: %s\n", p->pid, path);

  // Open the executable file.
  if((ip = namei(path)) == 0){
    printf("[pid %d] EXEC failed: cannot open %s\n", p->pid, path);
    end_op();
    return -1;
  }
  ilock(ip);

  //part1 - Debug: file opened successfully
  printf("[pid %d] EXEC file opened successfully\n", p->pid);

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) {
    printf("[pid %d] EXEC failed: cannot read ELF header\n", p->pid);
    goto bad;
  }

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC) {
    printf("[pid %d] EXEC failed: not an ELF file\n", p->pid);
    goto bad;
  }

  if((pagetable = proc_pagetable(p)) == 0) {
    printf("[pid %d] EXEC failed: cannot create page table\n", p->pid);
    goto bad;
  }

  //part1 - Debug: starting segment processing
  printf("[pid %d] EXEC starting segment processing\n", p->pid);

  //part1 - Initialize segment tracking for demand paging
  // Instead of eagerly loading segments, we store their information
  // for later demand loading when pages are accessed
  int text_seg_found = 0, data_seg_found = 0;
  uint64 text_start = 0, text_end = 0, data_start = 0, data_end = 0;

  // Load program into memory.
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    
    //part1 - Store segment information instead of loading eagerly
    // Determine if this is text or data segment based on permissions
    if(ph.flags & ELF_PROG_FLAG_EXEC) {
      // Text segment (executable)
      if(!text_seg_found) {
        text_start = ph.vaddr;
        text_end = ph.vaddr + ph.memsz;
        p->text_seg.va_start = ph.vaddr;
        p->text_seg.va_end = ph.vaddr + ph.memsz;
        p->text_seg.file_offset = ph.off;
        p->text_seg.file_size = ph.filesz;
        p->text_seg.perm = flags2perm(ph.flags);
        text_seg_found = 1;
      }
    } else {
      // Data segment (writable, non-executable)
      if(!data_seg_found) {
        data_start = ph.vaddr;
        data_end = ph.vaddr + ph.memsz;
        p->data_seg.va_start = ph.vaddr;
        p->data_seg.va_end = ph.vaddr + ph.memsz;
        p->data_seg.file_offset = ph.off;
        p->data_seg.file_size = ph.filesz;
        p->data_seg.perm = flags2perm(ph.flags);
        data_seg_found = 1;
      }
    }
    
    // Update process size to include this segment
    if(ph.vaddr + ph.memsz > sz)
      sz = ph.vaddr + ph.memsz;
  }
  
  //part1 - Store executable file reference for demand loading
  // Keep the inode open so we can read from it later
  p->exec_inode = ip;
  idup(ip); // Increment reference count
  iunlockput(ip);
  end_op();
  ip = 0;

  p = myproc();
  uint64 oldsz = p->sz;

  //part1 - Clear old demand paging state when exec starts
  clear_resident_pages();

  //part1 - Set up lazy allocation boundaries 
  // For now, allocate one stack page for arguments, rest will be demand-allocated
  sz = PGROUNDUP(sz);
  
  //part1 - Store memory layout information for demand paging
  p->text_start = text_start;
  p->text_end = text_end;
  p->data_start = data_start;  
  p->data_end = data_end;
  p->heap_start = PGROUNDUP(data_end); // Heap starts after data segment
  
  // Allocate just one page for initial stack and arguments
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + PGSIZE, PTE_W)) == 0) {
    printf("[pid %d] EXEC failed: cannot allocate stack page\n", p->pid);
    goto bad;
  }
  sz = sz1;
  
  //part1 - Debug: stack allocated successfully
  printf("[pid %d] EXEC stack allocated successfully\n", p->pid);
  
  // Set full stack space but only one page is actually allocated
  uint64 stack_bottom = sz;  // Stack starts right after the allocated page
  p->stack_top = stack_bottom + (USERSTACK+1)*PGSIZE; // Full stack top for validation
  sz = p->stack_top; // Reserve full stack space
  
  //part1 - CRITICAL: Update p->sz early so page fault handler can use it
  p->sz = stack_bottom; // p->sz should be end of heap, start of stack
  
  sp = p->stack_top;
  stackbase = sp - USERSTACK*PGSIZE;
  
  // Set trapframe SP early so stack validation works during argument copying
  p->trapframe->sp = sp;
  
  //part1 - Initialize demand paging structures
  p->next_fifo_seq = 1;
  p->num_resident_pages = 0;
  p->num_swapped_pages = 0;
  p->swap_slots_used = 0;
  p->swapfile = 0;
  // Clear swap bitmap
  for(int j = 0; j < SWAP_BITMAP_SIZE; j++) {
    p->swap_bitmap[j] = 0;
  }
  
  //part3 - Create swap file for this process
  if(create_swap_file() != 0) {
    printf("[pid %d] EXEC failed: cannot create swap file\n", p->pid);
    goto bad;
  }
  
  //part1 - Log the lazy mapping initialization
  printf("[pid %d] INIT-LAZYMAP text=[0x%lx,0x%lx) data=[0x%lx,0x%lx) heap_start=0x%lx stack_top=0x%lx\n",
          p->pid, p->text_start, p->text_end, p->data_start, p->data_end, 
          p->heap_start, p->stack_top);

  // Copy argument strings into new stack, remember their
  // addresses in ustack[].
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    // Update trapframe SP so stack validation works
    p->trapframe->sp = sp;
    if(sp < stackbase)
      goto bad;
    printf("[pid %d] EXEC copying arg %ld: '%s' to sp=0x%lx\n", p->pid, argc, argv[argc], sp);
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0) {
      printf("[pid %d] EXEC failed: copyout failed for arg %ld\n", p->pid, argc);
      goto bad;
    }
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push a copy of ustack[], the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  // Update trapframe SP for ustack copying
  p->trapframe->sp = sp;
  if(sp < stackbase)
    goto bad;
  printf("[pid %d] EXEC copying ustack to sp=0x%lx\n", p->pid, sp);
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0) {
    printf("[pid %d] EXEC failed: copyout failed for ustack\n", p->pid);
    goto bad;
  }

  // a0 and a1 contain arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->trapframe->a1 = sp;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));
    
  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
  p->trapframe->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);

  //part1 - Debug: exec completed successfully
  printf("[pid %d] EXEC completed successfully, entry=0x%lx sp=0x%lx\n", p->pid, elf.entry, sp);

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  printf("[pid %d] EXEC failed: going to bad label\n", p->pid);
  if(pagetable) {
    // Note: freewalk() now handles leftover pages automatically
    proc_freepagetable(pagetable, sz);
  }
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}

//part1 - Commented out loadseg since we're doing demand loading instead
// Load an ELF program segment into pagetable at virtual address va.
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
/*
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
      return -1;
  }
  
  return 0;
}
*/
