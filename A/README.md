# Part A — PagedOut Inc. Demand Paging and Swapping Implementation

## Overview

This project implements a comprehensive demand paging and swapping system for xv6, transforming it from eager memory allocation to a lazy allocation system that only allocates memory when actually needed. The implementation includes on-demand loading, FIFO page replacement, per-process swap files, and detailed system state inspection.

## Implementation Architecture

### Core Design Philosophy
- **Lazy Allocation**: Memory is not allocated until actually accessed
- **Demand Loading**: Program text/data loaded from executable on page faults
- **FIFO Replacement**: Oldest resident page is evicted when memory is full
- **Per-Process Swapping**: Each process has its own isolated swap file
- **Complete Logging**: Every operation is logged with exact required formats

## File Structure and Implementation Details

### 1. Core Header Files

#### `kernel/demand.h` - Central Data Structures
```c
#define MAX_SWAP_PAGES 1024      // 4MB swap capacity per process
#define MAX_RESIDENT_PAGES 64    // Maximum tracked resident pages
#define MAX_SWAP_SLOTS 1024      // Swap slot management
#define SWAP_BITMAP_SIZE 16      // Bitmap for 1024 slots (16*64=1024)
```

**Key Structures:**
- `struct page_info`: Tracks individual pages with VA, FIFO sequence, dirty status, swap slot
- `struct segment_info`: Stores executable segment boundaries for demand loading

#### `kernel/memstat.h` - System State Inspection
**Implements required memstat() system call interface:**
```c
#define MAX_PAGES_INFO 128
#define UNMAPPED 0 / RESIDENT 1 / SWAPPED 2

struct page_stat { va, state, is_dirty, seq, swap_slot }
struct proc_mem_stat { pid, num_pages_total, num_resident_pages, ... }
```

### 2. Process Structure Extensions (`kernel/proc.h`)

**Added to struct proc:**
```c
// Executable segment boundaries for demand loading
uint64 text_start, text_end, data_start, data_end;
uint64 heap_start, stack_top;
struct inode *exec_file; 

// FIFO page tracking
int next_fifo_seq;
struct page_info resident_pages[MAX_RESIDENT_PAGES];
int num_resident_pages;

// Per-process swap management
struct inode *swapfile;
char swapfilename[16];  // "/pgswpXXXXX" format
int swap_slots_used;
uint64 swap_bitmap[16]; // Tracks used/free swap slots
```

### 3. Core Implementation Files

#### `kernel/vm.c` - Memory Management Core

**Major Functions Implemented:**

1. **Page Fault Handler** (`pagefault_handler()`)
   - **Location**: Lines 516-686
   - **Purpose**: Central dispatcher for all page faults
   - **Logic**:
     ```
     PAGEFAULT → Check if swapped → Load from swap
                        ↓
                Check access validity → Allocate/Load → Make resident
                        ↓
                Invalid access → Terminate process
     ```

2. **Demand Allocation** (`allocate_zero_page()`)
   - **Location**: Lines 688-744
   - **Purpose**: Allocates zero-filled pages for heap/stack
   - **Triggers**: sbrk() calls, stack growth

3. **Demand Loading** (`load_executable_page()`)
   - **Location**: Lines 745-821
   - **Purpose**: Loads text/data pages from executable file
   - **Logic**: Reads from `proc->exec_file` at correct offset

4. **FIFO Page Replacement** (`evict_page_fifo()`)
   - **Location**: Lines 914-993
   - **Purpose**: Implements strict FIFO eviction policy
   - **Algorithm**: Finds oldest page (lowest seq number), evicts it

5. **Swap Management**:
   - `create_swap_file()` (Lines 1166-1293): Creates `/pgswpXXXXX` files
   - `swap_out_page()` (Lines 1295-1382): Writes dirty pages to swap
   - `swap_in_page()` (Lines 1383-1465): Reloads pages from swap

#### `kernel/exec.c` - Lazy Program Loading

**Key Modifications:**
- **Commented out `loadseg()`**: No longer pre-loads program segments
- **INIT-LAZYMAP logging**: Logs memory layout boundaries
- **Segment boundary tracking**: Stores text/data ranges for later demand loading
- **Executable file retention**: Keeps file reference for demand loading

#### `kernel/sysproc.c` - System Call Integration

**Enhanced `sys_sbrk()`:**
- **SBRK_LAZY mode**: Completely lazy allocation (just adjusts `proc->sz`)
- **SBRK_EAGER mode**: Backward compatibility for existing tests
- **Adaptive behavior**: Chooses mode based on call type

**`sys_memstat()` Implementation:**
- **Location**: Lines 155-220
- **Purpose**: Reports complete process memory state
- **Data**: Resident pages, swapped pages, FIFO sequences, dirty status

### 4. Test Programs (user/ directory)

**Comprehensive test suite implemented:**
- `heaptest.c`: Tests lazy heap allocation
- `stacktest.c`: Tests stack growth and demand allocation  
- `evicttest.c`: Tests FIFO eviction when memory full
- `cleanevict.c` / `dirtyevict.c`: Tests clean vs dirty page eviction
- `test_swapfile.c`: Tests swap file creation and management
- `test_swapin.c` / `test_swapfull.c`: Tests swap-in and swap exhaustion
- `test_memstat.c`: Tests memstat() system call
- `badaccesstest.c`: Tests invalid access handling

## Implementation Status by Requirements

### 1. Demand Paging (40 Marks) - FULLY IMPLEMENTED

- **No pre-allocation at exec**: `exec.c` modified to skip `loadseg()`
- **Lazy sbrk**: `sys_sbrk()` only adjusts `proc->sz` in LAZY mode  
- **Page fault handling**: Complete handler in `vm.c:pagefault_handler()`
- **Text/Data demand loading**: `load_executable_page()` loads from executable
- **Heap allocation**: `allocate_zero_page()` for sbrk pages
- **Stack growth**: Stack pages allocated within one page below SP
- **Invalid access handling**: Process termination with proper logging
- **Complete logging**: All required log formats implemented

### 2. Page Replacement (30 Marks) - FULLY IMPLEMENTED

- **Per-process resident set**: Tracked in `proc->resident_pages[]`
- **Replacement only on kalloc() failure**: Memory full detection
- **FIFO victim selection**: `evict_page_fifo()` finds oldest page
- **Per-process only eviction**: Never evicts other process pages
- **FIFO sequence handling**: Monotonic sequence numbers with wraparound
- **Complete logging**: MEMFULL, VICTIM, EVICT logs implemented

### 3. Swapping (35 Marks) - FULLY IMPLEMENTED

- **Per-process swap files**: `/pgswpXXXXX` naming scheme
- **Swap file lifecycle**: Created in exec, deleted on exit
- **No sharing between processes**: Each process isolated
- **Clean page discarding**: Only if valid backing copy exists
- **Dirty page swap-out**: Always written to swap file
- **Swap slot management**: Bitmap tracking with free/used slots
- **1024 page limit**: MAX_SWAP_PAGES enforcement
- **Swap exhaustion handling**: Process termination when full
- **Swap-in functionality**: `swap_in_page()` reloads pages
- **Complete logging**: SWAPOUT, SWAPIN, SWAPFULL, SWAPCLEANUP

### 4. System State Inspection (5 Marks) - FULLY IMPLEMENTED

- **memstat() system call**: Fully functional implementation
- **Required data structures**: `memstat.h` with exact specifications
- **Process memory reporting**: Complete state for resident/swapped pages
- **FIFO sequence tracking**: Consistent sequence numbers reported
- **Dirty bit tracking**: Software dirty tracking implemented

### 5. Bonus: Alternative Page Replacement (15 Marks) - IMPLEMENTED

**LFU-Recent Algorithm:**
- **Location**: `vm.c:evict_page_lfu_recent()` (Lines 1003-1078)
- **Strategy**: Combines Least Frequently Used with recency
- **Algorithm**: 
  - Tracks `access_frequency` and `last_access_time` per page
  - Evicts page with lowest frequency
  - Breaks ties using least recent access time
- **Activation**: `enable_bonus_algorithm()` switches from FIFO to LFU-Recent
- **Multi-process safe**: Only evicts from current process resident set
- **Adaptive**: `evict_page_adaptive()` chooses algorithm based on process setting

## Logging Implementation

### Complete Mandatory Logging Formats
All logging exactly matches requirements:

```c
// Initialization
[pid X] INIT-LAZYMAP text=[0xA,0xB) data=[0xC,0xD) heap_start=0xE stack_top=0xF

// Page Faults  
[pid X] PAGEFAULT va=0xV access=<read|write|exec> cause=<heap|stack|exec|swap>

// Making Pages Resident
[pid X] ALLOC va=0xV
[pid X] LOADEXEC va=0xV  
[pid X] SWAPIN va=0xV slot=N
[pid X] RESIDENT va=0xV seq=S

// Memory Full & Replacement
[pid X] MEMFULL
[pid X] VICTIM va=0xV seq=S algo=FIFO
[pid X] EVICT va=0xV state=<clean|dirty>
[pid X] DISCARD va=0xV
[pid X] SWAPOUT va=0xV slot=N

// Error Conditions
[pid X] KILL invalid-access va=0xV access=<read|write|exec>
[pid X] SWAPFULL  
[pid X] KILL swap-exhausted

// Cleanup
[pid X] SWAPCLEANUP freed_slots=K
```

**Note on Swap Exhaustion Sequence:**
The correct logging sequence for swap exhaustion (as implemented) is:
1. `SWAPFULL` - logged when no free swap slots available
2. `KILL swap-exhausted` - logged before process termination
This ensures compliance with specification requirements for swap capacity failure handling.

## Key Design Decisions and Assumptions

### 1. **Hybrid sbrk() Approach**
- **SBRK_LAZY**: Complete lazy allocation for demand paging tests
- **SBRK_EAGER**: Eager allocation for backward compatibility with existing xv6 tests
- **Rationale**: Allows both new demand paging functionality and existing test compatibility

### 2. **File System Integration**
- **Swap files use regular file system**: No dedicated swap partition
- **Executive file retained**: Kept open during process lifetime for demand loading
- **Automatic cleanup**: Swap files deleted on process exit

### 3. **Memory Management Strategy**
- **Software dirty tracking**: Uses trap on first write for dirty bit
- **Resident page limits**: MAX_RESIDENT_PAGES=64 to prevent unbounded tracking
- **Swap capacity limits**: 1024 pages (4MB) per process as specified

### 4. **FIFO Implementation Details**
- **Monotonic sequence numbers**: Never decrease, handle wraparound
- **Per-process sequences**: Each process has independent FIFO ordering  
- **Strict FIFO**: Always evict lowest sequence number (oldest)

## Testing and Validation

### Automated Testing
- **test-xv6.py**: Python test runner for comprehensive validation
- **Individual test programs**: Focused testing of specific functionality
- **Multi-process testing**: Validates isolation between processes

### Manual Testing Commands
```bash
# Build and run
make clean && make qemu

```

## Known Limitations and Trade-offs

### 1. **File System Dependency**
- **Limitation**: Swap performance depends on file system performance
- **Trade-off**: Simpler implementation vs. dedicated swap partition performance

### 2. **Resident Page Tracking Limit**
- **Limitation**: MAX_RESIDENT_PAGES=64 per process
- **Rationale**: Prevents unbounded memory usage for tracking structures
- **Impact**: Very large processes may hit this limit

### 3. **Backward Compatibility**
- **Trade-off**: Hybrid sbrk() maintains compatibility but adds complexity
- **Benefit**: Existing xv6 tests continue to work

### 4. **File System Capacity Constraints**
- **Limitation**: xv6 file system has ~274KB file size limit, less than theoretical 4MB swap capacity
- **Implementation**: The 1024-page capacity is a logical upper bound; system gracefully terminates when file system limits are reached
- **Behavior**: Processes terminate cleanly with proper logging when file system capacity is exhausted during swap operations
- **Clarification Compliance**: As specified by instructor, system handles disk limitations gracefully with required termination logs

### 5. **usertests and lazyalloc Behavior**
- **Expected Behavior**: usertests may fail on lazyalloc test due to swap exhaustion or file system limits
- **Acceptable Outcome**: Test failure is acceptable as per instructor clarification, provided process terminates cleanly
- **Required Logging**: System logs proper `SWAPFULL` followed by `KILL swap-exhausted` before termination
- **Test Continuation**: When lazyalloc fails, usertests may not proceed to further tests - this is expected behavior

## Performance Characteristics

### Memory Usage
- **Reduced memory footprint**: Only allocates pages when accessed
- **Swap file overhead**: Additional disk I/O for evicted pages
- **Tracking overhead**: ~40 bytes per resident page for metadata

### CPU Overhead
- **Page fault handling**: Additional CPU cycles for demand allocation
- **FIFO tracking**: O(n) victim search where n=resident pages
- **LFU-Recent**: O(n) with frequency comparisons

## Future Enhancements

### Potential Improvements
1. **Clock algorithm**: Replace O(n) FIFO with O(1) clock algorithm
2. **Prefetching**: Anticipatory loading of adjacent pages
3. **Compression**: Compress pages before swap-out
4. **Async I/O**: Non-blocking swap operations

### Extensibility
- **Pluggable algorithms**: Easy to add new replacement policies
- **Configurable limits**: Runtime tuning of MAX_SWAP_PAGES, etc.
- **Statistics**: Detailed performance metrics collection

## Conclusion

This implementation provides a complete, robust demand paging and swapping system for xv6. All required functionality is implemented with exact logging compliance, comprehensive error handling, and extensive testing. The bonus LFU-Recent algorithm demonstrates advanced replacement strategy implementation. The system successfully transforms xv6 from eager to lazy allocation while maintaining backward compatibility and providing detailed system introspection capabilities.

## Bonus Feature: LFU-Recent Page Replacement Algorithm

### Algorithm Description

The LFU-Recent (Least Frequently Used - Recent) algorithm is an enhanced page replacement strategy that combines frequency-based and recency-based metrics to make intelligent eviction decisions. Unlike pure FIFO which only considers age, LFU-Recent evaluates both how often a page is accessed and how recently it was used.

### Design Rationale

**Why LFU-Recent?**
- **Frequency Awareness**: Pages accessed frequently are likely to be accessed again (temporal locality)
- **Recency Consideration**: Recently accessed pages should have higher priority than old frequent pages
- **Balanced Approach**: Combines benefits of LFU and LRU algorithms
- **Adaptive Behavior**: Performs well across different workload patterns

**Advantages:**
- Better hit rates for workloads with repeated access patterns
- Protects frequently used pages from eviction
- Considers both short-term and long-term access patterns
- More sophisticated than simple FIFO replacement

**Trade-offs:**
- Higher computational overhead: O(n) with frequency calculations vs O(1) FIFO
- Additional memory overhead: stores frequency and timestamp per page
- More complex implementation than basic replacement algorithms

### Implementation Details

**Core Scoring Function:**
```c
static int calculate_lfu_recent_score(struct page_info *page, uint64 current_time) {
    int frequency_component = (page->access_frequency > 0) ? (1000 / page->access_frequency) : 1000;
    int recency_component = (int)(current_time - page->last_access_time);
    return frequency_component + recency_component;
}
```

**Victim Selection:**
- Higher scores indicate better eviction candidates
- Frequency component: Less frequently accessed pages get higher scores
- Recency component: Older pages get higher scores
- Combined score balances both factors

**Data Structures:**
```c
struct page_info {
    // ... existing fields ...
    int access_frequency;        // Number of times page accessed
    uint64 last_access_time;     // Global timestamp of last access
};

struct proc {
    // ... existing fields ...
    int use_bonus_algorithm;     // Flag to enable LFU-Recent
    uint64 global_time_counter;  // Monotonic time counter
};
```

**Algorithm Activation:**
- Enabled via `enable_bonus_algorithm()` function
- Can be triggered by `sys_enable_bonus()` system call
- Seamlessly replaces FIFO when activated
- Process-specific: each process can use different algorithms

**Edge Case Handling:**
- **New pages**: Start with frequency=1, current timestamp
- **Overflow protection**: Frequency capped to prevent integer overflow
- **Time wraparound**: Uses difference calculations to handle wraparound
- **Equal scores**: Falls back to deterministic selection (lowest index)

**Multi-Process Environment:**
- Each process maintains independent algorithm state
- No cross-process interference
- Respects process isolation: only evicts own pages
- Consistent with dirty/clean page handling requirements

**Integration with Existing System:**
- Uses same page tracking infrastructure as FIFO
- Maintains all required logging formats
- Preserves swap file management
- Compatible with memstat() system call

### Performance Characteristics

**Time Complexity:**
- Victim selection: O(n) where n = number of resident pages
- Page access update: O(1)
- Algorithm switch: O(n) for initialization

**Space Complexity:**
- Additional 12 bytes per page (frequency + timestamp)
- One global counter per process
- Minimal overhead compared to page size (4KB)

**Expected Performance:**
- Better cache hit rates for temporal locality workloads
- Slightly higher CPU usage due to score calculations
- Improved performance for applications with working sets

This bonus implementation demonstrates advanced virtual memory management concepts and provides a foundation for further algorithm experimentation in the xv6 environment.
