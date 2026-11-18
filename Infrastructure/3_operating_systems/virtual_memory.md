# Virtual memory

> **History:** Atlas (1962) invented paging; Unix on the PDP-11 and VAX (1970s)
> brought it to everyday machines; x86 got an MMU with paging in 1985 (386), and
> 64-bit x86 (2003) extended it to 4-level page tables. See the
> [timeline](../timeline.md#operating-systems). Previous:
> [scheduling](scheduling.md). Next: [file systems](file_systems.md).
> Hardware background: [memory hierarchy](../1_hardware/cpu_and_memory.md#the-memory-hierarchy).

## Why

Physical RAM is a single shared array. Without help, programs would overwrite each
other, need to know where they are loaded, and be limited by RAM size. **Virtual
memory** gives each process its own private address space, as if it owned the machine.

Three benefits: **isolation** (protection), **convenience** (each program sees
the same clean layout, see [loader](../2_from_code_to_execution/how_a_computer_understands_code.md#3-running-a-program-the-loader)),
and **capacity** (disk can extend RAM).

## Address translation

The CPU emits **virtual addresses** $v$; the **MMU** (memory management unit)
translates them on the fly to **physical addresses** $p$ using tables the kernel
maintains. For each process:

$$\text{translate} : \text{virtual addresses} \rightharpoonup \text{physical addresses} \cup \{\text{fault}\}$$

It is a *partial* function: unmapped addresses give a fault.

### Paging

Memory is cut into fixed-size **pages** (4 KiB $=2^{12}$ bytes) in virtual space
and **frames** of the same size in RAM. A virtual address splits into

$$v = (\underbrace{\text{VPN}}_{\text{page number}},\; \underbrace{\text{off}}_{12\text{ bits}}), \qquad
p = \text{PT}[\text{VPN}]\cdot 2^{12} + \text{off}$$

where $\text{PT}$ is the **page table**: one entry per page, holding the frame
number and flags (present, read/write, user/kernel, dirty, accessed). The offset is
unchanged by translation.

Example: $v=\texttt{0x7f3a2123}$, VPN $=\texttt{0x7f3a2}$, off $=\texttt{0x123}$. If
$\text{PT}[\texttt{0x7f3a2}]=\texttt{0x00042}$ then $p=\texttt{0x42123}$.

### Multi-level page tables

A flat table for 48-bit addresses would need $2^{36}$ entries per process. Instead
the VPN is split into indexes into a **tree** of tables; only used branches exist.
On x86-64: 4 levels $\times$ 9 bits $+$ 12 bits offset $=48$ bits.

$$48 = 4\times 9 + 12$$

Each level has $2^9=512$ entries of 8 bytes $=4$ KiB, exactly one page.

### TLB

Walking 4 levels means 4 extra memory accesses per access. The **TLB**
(translation lookaside buffer) caches recent translations. With hit rate $h$:

$$t_{\text{eff}} = h\,(t_{\text{tlb}}+t_{\text{mem}}) + (1-h)\,(t_{\text{tlb}}+ 5\,t_{\text{mem}})$$

(page walk = 4 table reads, then the data). With $t_{\text{tlb}}=1$ ns,
$t_{\text{mem}}=100$ ns, $h=99\%$: $t_{\text{eff}}\approx 105$ ns versus $500$ ns
with no TLB. Locality again.

## Page faults and demand paging

A page may be marked *not present*; touching it raises a **page fault**
(an [exception](system_calls.md#interrupts-the-other-way-in)). The kernel decides:

| Situation | Action |
|-----------|--------|
| Page valid but not yet loaded (first touch, file-backed) | **demand paging**: read it from disk, map it, resume |
| Page swapped out | read it back from swap |
| Illegal address | send `SIGSEGV` (segmentation fault) |
| Write to a copy-on-write page | copy the page, then map the private copy |

Pages are loaded lazily, so a program starts without being fully read into RAM.

**Effective access time** with fault probability $p$:

$$\text{EAT} = (1-p)\,t_{\text{mem}} + p\,t_{\text{fault}}$$

With $t_{\text{mem}}=100$ ns and $t_{\text{fault}}=8$ ms: $p=10^{-6}$ gives
$\approx 108$ ns (8 % slower), $p=10^{-3}$ gives $\approx 8\,\mu s$, 80x slower.
Faults must be extremely rare. This is **thrashing**: when the working set does
not fit in RAM, the system spends its time swapping.

### Page replacement

When RAM is full, the kernel evicts a page. Ideal policy (Belady): evict the page
used furthest in the future (impossible). **LRU** (least recently used)
approximates it using the *accessed* bit; Linux uses an approximation with
active/inactive lists.

## Useful consequences

- **Copy-on-write**: `fork` duplicates only the page tables, sharing frames
  marked read-only; a frame is copied at the first write. That is why `fork` is cheap.
- **Shared libraries**: one physical copy of `libc` mapped in every process.
- **`mmap`**: map a file into the address space; reading memory reads the file
  (basis of loading executables, and of NumPy's `memmap`).
- **Overcommit**: `malloc` gives virtual space; frames are allocated on first touch.
  If RAM runs out, Linux's **OOM killer** terminates a process.
- **Page cache**: free RAM is used to cache files ([file systems](file_systems.md#page-cache)).
- **Stack vs heap**: both are just regions of the address space; the stack grows
  down by faults, the heap via `brk`/`mmap` (see
  [process layout](../2_from_code_to_execution/how_a_computer_understands_code.md#3-running-a-program-the-loader)).
- Security: kernel pages are mapped but marked supervisor-only; this is the
  mechanism that Meltdown (2018) bypassed through speculative execution.

## Things to remember

- Virtual address $=(\text{VPN}, \text{offset})$; translation replaces only the VPN.
- Multi-level tables and the TLB make translation affordable.
- Page faults are normal (lazy loading, copy-on-write) but must be rare to
  keep EAT near $t_{\text{mem}}$.
- Virtual memory is the key to isolation, `fork`, `mmap` and shared libraries.

## Exercises

1. `cat /proc/self/maps` and `pmap $$`: identify code, heap, stack, libraries.
2. `getconf PAGESIZE`; `free -h`; `vmstat 1` (columns `si`, `so` are swap in/out).
3. `/usr/bin/time -v ls`: read "Minor/Major page faults".
4. Python: `mmap` a large file and read a few bytes; compare memory use (`ps -o rss`)
   with reading the whole file.
5. How many page-table pages are needed (at least) to map 1 GiB contiguous?

## Going further

- OSTEP: "Paging", "TLBs", "Beyond Physical Memory".
- *CS:APP* ch. 9.
