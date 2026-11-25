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
$s = (R, \mathcal{M}, pc)$ with registers $R$,
[memory](memory_and_addresses.md#memory) $\mathcal{M}$ and program counter $pc$, and
running a program is iterating a transition function:

$$s_{t+1} = \delta(s_t), \qquad \delta = \text{execute}\circ\text{decode}\circ\text{fetch}$$

Everything else in `Infrastructure/` (code execution, OS, network, APIs) is a layer
that builds a richer $\delta$ out of this one.

## Memory and addresses

The formal definition of memory, addresses (including why only 48 of the 64 bits are
used), types, byte order and the bulb picture are in
[`memory_and_addresses.md`](memory_and_addresses.md).

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
