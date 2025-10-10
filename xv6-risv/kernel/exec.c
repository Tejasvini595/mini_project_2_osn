#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"
#include "file.h"

// part1 - loadseg function is unused in demand paging implementation
// static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

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

  // Open the executable file.
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    goto bad;

  // part1 - Set up for demand paging instead of pre-loading
  // Don't allocate physical pages yet, just track segments
  uint64 text_start = 0, text_end = 0, data_start = 0, data_end = 0;
  int found_text = 0, found_data = 0;
  
  // Parse program headers to identify segments but don't load them
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
    
    // part1 - Track segment boundaries for demand loading
    if(ph.flags & PTE_X) { // Text segment (executable)
      if(!found_text) {
        text_start = ph.vaddr;
        found_text = 1;
      }
      text_end = ph.vaddr + ph.memsz;
    } else { // Data segment  
      if(!found_data) {
        data_start = ph.vaddr;
        found_data = 1;
      }
      data_end = ph.vaddr + ph.memsz;
    }
    
    // Update process size but don't allocate physical pages
    if(ph.vaddr + ph.memsz > sz)
      sz = ph.vaddr + ph.memsz;
  }
  
  // part1 - Keep a reference to the executable file for demand loading
  // We need to convert the inode to a file struct
  struct file *execfile = 0;
  if((execfile = filealloc()) == 0)
    goto bad;
  execfile->type = 2; // FD_INODE
  execfile->ip = idup(ip);
  execfile->off = 0;
  execfile->readable = 1;
  execfile->writable = 0;
  
  p->execfile = execfile;
  p->text_start = text_start;
  p->text_end = text_end;
  p->data_start = data_start;
  p->data_end = data_end;
  iunlockput(ip);
  end_op();
  ip = 0;

  p = myproc();
  uint64 oldsz = p->sz;

  // part1 - Set up stack layout, but only allocate the top page for arguments
  sz = PGROUNDUP(sz);
  sz += (USERSTACK+1)*PGSIZE;  // Reserve space for stack
  sp = sz;
  stackbase = sp - USERSTACK*PGSIZE;
  
  // Allocate only the top stack page where we'll put arguments
  char *stackpage = kalloc();
  if(stackpage == 0)
    goto bad;
  memset(stackpage, 0, PGSIZE);
  
  // Map just the top stack page
  uint64 stack_top = sz - PGSIZE;
  if(mappages(pagetable, stack_top, PGSIZE, (uint64)stackpage, PTE_W | PTE_R | PTE_U) < 0) {
    kfree(stackpage);
    goto bad;
  }
  
  // Adjust sp to be within the allocated page
  sp = sz;

  // Copy argument strings into new stack, remember their
  // addresses in ustack[].
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    if(sp < stackbase)
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push a copy of ustack[], the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;

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
  p->trapframe->epc = elf.entry;  // initial program counter = main
  p->trapframe->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}

// Load an ELF program segment into pagetable at virtual address va.
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
// part1 - This function is unused in demand paging implementation
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
