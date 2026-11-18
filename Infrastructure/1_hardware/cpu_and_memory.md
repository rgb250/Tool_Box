# CPU and memory

> **History:** von Neumann architecture (1945) $\to$ transistor (1947) $\to$
> microprocessor (1971) $\to$ x86 (1978) / ARM (1985) $\to$ multicore (2005).
> See the [hardware timeline](../timeline.md#hardware). Next:
> [how code becomes machine code](../2_from_code_to_execution/how_a_computer_understands_code.md).

## Big picture

A computer is a machine that repeatedly **fetches an instruction from memory,
decodes it, executes it, and stores the result**. Everything else (OS, Internet,
APIs) is software layered on top of this loop.

```text
        +-----------------------+
        |          CPU          |
        |  +-----+   +-------+  |         +-----------+
        |  | ALU |   | Regs  |  |  bus    |   RAM     |
        |  +-----+   +-------+  | <-----> | (volatile)|
        |  | Control unit    |  |         +-----------+
        |  +-----------------+  |               ^
        |  L1 / L2 / L3 caches  |               | I/O bus
        +-----------------------+         +-----+------+
                                          | SSD, NIC,  |
                                          | GPU, ...   |
                                          +------------+
```

## Formal model

A computer is a **deterministic state machine**. Its state is
$s = (R, M, pc)$ with registers $R$, memory $M$ and program counter $pc$, and
running a program is iterating a transition function:

$$s_{t+1} = \delta(s_t), \qquad \delta = \text{execute}\circ\text{decode}\circ\text{fetch}$$

Everything else in `Infrastructure/` (code execution, OS, network, APIs) is a layer
that builds a richer $\delta$ out of this one.

## Memory as a function

With $n$-bit addresses, memory is a map from addresses to bytes:

$$M : \{0,\dots,2^{n}-1\} \to \{0,\dots,255\}$$

There are $2^n$ addresses; the largest one is $2^n-1$ (counting starts at $0$).

### Picture: bulbs

Each bit can be pictured as a bulb, on or off: memory is a column of rows of 8 bulbs
(one per address), and an address is a separate set of $n$ bulbs that selects a row. See
the [bulb picture](memory_and_addresses.md#picture-bulbs) in `memory_and_addresses.md`.

### Addresses: 64 bits, 48 used

A 64-bit machine has 64-bit pointers ($n=64$), but the CPU only translates the lower
**48 bits**, so $2^{48}$ bytes $=256$ TiB are addressable. The top 16 bits are not
free: they must be copies of bit 47 (**canonical address**), which splits the space in
two halves:

```text
 0xFFFF_FFFF_FFFF_FFFF  ┐  upper half: top 16 bits all 1 (128 TiB, kernel)
 0xFFFF_8000_0000_0000  ┘
   non-canonical addresses in between: using one raises a fault
 0x0000_7FFF_FFFF_FFFF  ┐  lower half: top 16 bits all 0 (128 TiB, user programs)
 0x0000_0000_0000_0000  ┘
```

How to read it: an address is 16 hex digits and each hex digit is 4 bits, so the
**top 16 bits** are the 4 leftmost hex digits. "All 1" means `FFFF` ($1111\,1111\,1111\,1111$)
and "all 0" means `0000`. The rule is: bits $63..48$ must equal bit 47.

| Address | Top 16 bits | Bit 47 | Valid? |
|---------|-------------|--------|--------|
| `0x0000_7FFF_FFFF_FFFF` | `0000` | 0 (`7`=`0111`) | yes, last user address |
| `0xFFFF_8000_0000_0000` | `FFFF` | 1 (`8`=`1000`) | yes, first kernel address |
| `0x0000_8000_0000_0000` | `0000` | 1 | no: top bits differ from bit 47 |

This is **sign extension**, as for two's complement
([integers](#integers-and-overflow)): a canonical address is a 48-bit signed number
copied into 64 bits, in $[-2^{47},\,2^{47}-1]$. Non-negative values form the user
half, negative values the kernel half.

Why not use all 64 bits? Each address bit makes the page tables and translation
hardware bigger and slower: $48=4\times9+12$ is four page-table levels plus a 12-bit
offset (see [virtual memory](../3_operating_systems/virtual_memory.md#multi-level-page-tables)).
256 TiB was plenty when x86-64 appeared (2003); recent CPUs offer 5 levels (57 bits,
128 PiB) for very large servers.

### Types as pairs

A **pair** $(a,b)$ is two objects grouped in a fixed order (like a Python tuple of
length 2). To *read* a value, a **type** $\tau$ needs two ingredients, a pair (a third one,
the legal operations $\Omega_\tau$, is in [`memory_and_addresses.md`](memory_and_addresses.md#type)):

$$\tau = (\ell_\tau,\ d_\tau)$$

- $\ell_\tau\in\mathbb{N}$: the **length**, i.e. how many bytes the type occupies;
- $d_\tau$: the **decoding map**, turning those bytes into a value.

| Type $\tau$ | $\ell_\tau$ | Decoding $d_\tau$ |
|-------------|-------------|-------------------|
| `char` | 1 | byte as a character code |
| `int32` | 4 | little-endian, two's complement |
| `float64` | 8 | IEEE 754 double |

Reading a value of type $\tau$ at address $a$ means taking the bytes
$M(a),\dots,M(a+\ell_\tau-1)$ and applying $d_\tau$ (see [`memory_and_addresses.md`](memory_and_addresses.md)). The bytes
`2A 00 00 00` are the integer $42$ as `int32`, but just the character `'*'` if read
as a one-byte `char`: memory is the same, only $\tau$ changes the meaning.

A $k$-byte unsigned integer stored at $a$ is, in **little-endian** (x86, usually
ARM), the least significant byte first:

$$x = \sum_{i=0}^{k-1} M(a+i)\, 256^{\,i}$$

(big-endian: $256^{\,k-1-i}$).

## Integers and overflow

A register or memory cell has a **fixed width** of $w$ bits, so an integer can only take
$2^w$ values. Results that do not fit **overflow**.

**Unsigned.** Values are $0,\dots,2^w-1$ and arithmetic is done **modulo $2^w$**:

$$x\oplus y=(x+y)\bmod 2^{w}$$

For $w=8$: $255+1=0$. For $w=64$: $2^{64}-1+1=0$. So $2^{64}$ itself does not fit in
64 bits (it needs 65), which is also why the largest address is $2^{64}-1$.

**Signed (two's complement).** The top bit has negative weight:

$$x=-b_{w-1}2^{\,w-1}+\sum_{i=0}^{w-2}b_i2^{\,i}\ \in\ [-2^{w-1},\,2^{w-1}-1]$$

Examples: `int8` $\in[-128,127]$, `int32` $\in[-2\,147\,483\,648,\ 2\,147\,483\,647]$,
`int64` up to $2^{63}-1\approx9.2\times10^{18}$. One more than the maximum **wraps to the
minimum**: `INT32_MAX + 1` $=-2^{31}$. Two's complement makes addition identical for signed and
unsigned values, so the ALU needs a single adder; the CPU only sets an *overflow flag*.

| Language | Behaviour on overflow |
|----------|-----------------------|
| C, C++ unsigned | wraps modulo $2^w$ (defined) |
| C, C++ signed | **undefined behaviour**: the compiler may assume it never happens |
| Python `int` | never overflows (arbitrary precision, cost grows with the size) |
| NumPy `int32`, `uint8`... | wraps silently in arrays |
| Rust | panics in debug builds, wraps in release; explicit `checked_add`, `wrapping_add`, `saturating_add` |
| Java, Go | wraps silently |

Famous consequences:

- **Ariane 5** (1996): a 64-bit float converted to a 16-bit signed integer overflowed in the guidance software; the rocket self-destructed.
- **Year 2038**: a signed 32-bit `time_t` counts seconds since 1970 and overflows on 2038-01-19 03:14:07 UTC.
- **Counters**: YouTube's view counter passed $2^{31}-1$ in 2014 (Gangnam Style) and was moved to 64 bits.
- **Binary search**: `mid = (lo + hi) // 2` can overflow in a fixed-width language; use `lo + (hi - lo) // 2` (a bug that lived in the JDK for years).
- **Security**: a size computed as `n * 4` that wraps to a small value leads to an
  undersized buffer, then to a buffer overflow (a different bug: writing past the end of an array).

Tools: `gcc -fsanitize=undefined`, Rust's checked operations, wider types (`int64`, `Decimal`),
and choosing the type from the largest value you must represent: $w\ge\lceil\log_2(\max+1)\rceil$ bits.
Counting how many steps a computation takes is the subject of
[complexity](../2_from_code_to_execution/complexity.md): $2^{64}$ steps do not overflow a
Python integer, but they would take about 585 years at $10^9$ steps per second.

## The CPU

| Component | Role |
|-----------|------|
| **Registers** | A few dozen tiny, ultra-fast storage slots inside the CPU (e.g. `rax`, `rsp`, `rip`). |
| **ALU** | Arithmetic and logic: add, compare, shift, AND/OR. |
| **Control unit** | Decodes instructions and orchestrates the other parts. |
| **Program counter** (`rip`) | Address of the next instruction to execute. |
| **Caches** | Small fast memories (L1/L2/L3) holding recently used data. |

### Fetch-decode-execute cycle

1. **Fetch**: read the instruction at the address in the program counter.
2. **Decode**: determine the operation and its operands.
3. **Execute**: the ALU does the work, or memory is read/written.
4. **Write back** the result and advance the program counter.

A program compiled to **machine code** is just a sequence of such instructions,
for a given **instruction set architecture** (ISA): x86-64 (Intel/AMD), ARM
(phones, Apple M-series, many servers), RISC-V (open).

### Execution time

$$T = \frac{N_{\text{instr}} \times \text{CPI}}{f}$$

with $N_{\text{instr}}$ the instruction count (compiler and algorithm), CPI the
average cycles per instruction (microarchitecture, caches) and $f$ the clock
frequency. Each technique below attacks one factor.

### Why modern CPUs are fast

- **Clock speed**: billions of cycles per second (3 GHz = $3\times10^9$ cycles/s).
- **Pipelining**: while one instruction executes, the next is decoded and the
  following one fetched.
- **Superscalar / out-of-order execution**: several instructions per cycle,
  reordered when independent.
- **Branch prediction**: guess the outcome of an `if` to keep the pipeline full.
- **Multiple cores**: independent CPUs on one chip. Using them requires threads
  or processes (see the operating systems chapter).

## The memory hierarchy

Fast memory is small and expensive; large memory is slow. The hierarchy hides
this trade-off through **caching** based on locality:

- *temporal locality*: data used recently will likely be used again;
- *spatial locality*: data near what was just used will likely be used next.

| Level | Typical size | Typical latency |
|-------|--------------|-----------------|
| Registers | < 1 KB | ~0.3 ns |
| L1 cache | 32-64 KB / core | ~1 ns |
| L2 cache | 256 KB-2 MB / core | ~4 ns |
| L3 cache | 8-64 MB shared | ~15 ns |
| RAM (DRAM) | 8-512 GB | ~80 ns |
| SSD (NVMe) | 0.25-8 TB | ~50-100 µs |
| HDD | 1-20 TB | ~5-10 ms |
| Network (same datacenter) | n/a | ~0.5 ms |
| Network (cross-continent) | n/a | ~100+ ms |

Orders of magnitude to remember: **RAM is ~100x slower than a register, an SSD is
~1000x slower than RAM, the Internet is another ~1000x slower**. Most
performance work is about avoiding the slower levels.

**Average access time.** With levels $1,\dots,L$, latency $t_i$ and miss rate
$m_i$ (fraction of accesses not found at level $i$), the expected cost of an
access starting at level $i$ satisfies a recursion:

$$T_i = t_i + m_i\, T_{i+1}, \qquad T_{L+1}=0
\;\Rightarrow\; T_1 = t_1 + m_1\big(t_2 + m_2(t_3+\cdots)\big)$$

Example: $t_1=1$ ns, $m_1=5\%$, $t_2=80$ ns (RAM, $m_2=0$) gives
$T_1 = 1 + 0.05\times 80 = 5$ ns. A small miss rate dominates the average, which is why locality
matters more than raw speed.

Cache lines (typically 64 bytes) are the unit moved between RAM and cache. This is why
iterating over a contiguous array is much faster than chasing pointers in a
linked list.

## RAM vs storage

- **RAM** is volatile (lost at power off), byte-addressable and fast. It holds
  running programs and their data.
- **Storage** (SSD/HDD) is persistent, accessed in blocks, and slower.
  Programs must be loaded from storage into RAM to run.

## Things to remember

- Code and data both live in memory; the CPU only follows addresses.
- A "64-bit machine" means 64-bit registers and addresses.
- Performance = how well your access pattern fits the cache hierarchy.
- The CPU knows nothing of files, processes or the network. That abstraction is
  provided by the operating system (chapter 3, after
  [code to execution](../2_from_code_to_execution/how_a_computer_understands_code.md)).

## Exercises

1. On Linux, run `lscpu` and `lsblk`; identify cores, cache sizes and disks.
2. Run `free -h` and `cat /proc/meminfo`; how much RAM is used as cache?
3. Write a loop summing a 2D NumPy array row by row, then column by column, and
   time both. Explain the difference with cache lines.
4. Compile a tiny C function with `gcc -S` and read the assembly.

## Going further

- *Computer Systems: A Programmer's Perspective* (Bryant & O'Hallaron), ch. 1, 4-6.
- *Latency Numbers Every Programmer Should Know*.
