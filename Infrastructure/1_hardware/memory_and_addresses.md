# Memory and addresses

> Companion of [CPU and memory](cpu_and_memory.md): what memory is, what an address is, and
> how bytes get a meaning through a type.

## Memory

`Memory` is a large array of **bytes**. Formally it is a function from addresses to bytes:

$$
\mathcal{M} : \left\{
\begin{array}{ccc}
[\![0,\,2^{n}-1]\!] & \to & [\![0,\,2^{8}-1]\!] \\
a & \mapsto & b
\end{array}
\right.
$$

Here $[\![p,q]\!]$ is the set of all integers from $p$ to $q$, both included, $a$ is an
address, $b$ is the byte stored at that address, and $n$ is the address width. There are
$2^n$ addresses; the largest one is $2^n-1$ (counting starts at $0$). On a 64-bit machine
$n=64$, so there are $2^{64}$ addresses in theory (in practice fewer are usable, see
[addresses](#addresses-64-bits-48-used)). A byte is 8 bits, so it holds $2^8=256$
distinct values.

$\mathcal{M}$ is a function, not a bijection: there are far more addresses than byte values,
so many addresses hold the same byte (it is **not injective**), and nothing forces every
byte value to appear (it is not necessarily **surjective**: a freshly zeroed memory maps
every address to $0$). Also, this description is only valid at a **given moment**: the
program keeps writing bytes, so strictly $\mathcal{M}=\mathcal{M}_t$ depends on the time $t$.

A program only touches a small fraction of this array at a time, usually a few
**consecutive** bytes (4 for an `int32`, 8 for a `float64`...), not the whole of it.

**Why consecutive?** One byte holds only 256 values, so larger values need several bytes.
Keeping them consecutive has three advantages:

- **One address is enough.** A value of length $\ell$ bytes (see [type](#type)) stored at
  $a$ occupies the addresses $[\![a,\,a+\ell-1]\!]$. For an `int32` ($\ell=4$) at address
  $1000$, these are $1000$ to $1003$. If the 4 bytes were scattered, finding them could
  take 4 separate addresses: $4\times8=32$ bytes on a 64-bit machine.
- **Direct access in arrays.** If elements of the same length $\ell$ follow one another
  from address $a$, element $i$ (counting from $0$) starts at

  $$a_i = a + i\,\ell$$

  In an `int32` array starting at $1000$, element $5$ is at $1000+5\times4=1020$: there
  is no need to read the previous elements.
- **Faster hardware.** The CPU can usually load several consecutive bytes with one
  instruction. It also copies memory into its cache by blocks called **cache lines**
  (typically 64 bytes, see the
  [memory hierarchy](cpu_and_memory.md#the-memory-hierarchy)), so reading neighbouring
  bytes next is usually fast.

This applies to **one value**, or to one contiguous block such as an array, not to all the
data of a program: the nodes of a linked list can be far apart. Also, consecutive
**virtual** addresses are not always neighbours in physical RAM, since they can cross from
one [memory page](../3_operating_systems/virtual_memory.md) into another.

## Address

An `Address` is an **index** $a\in[\![0,\,2^{n}-1]\!]$: the position of a byte in `Memory`. It is
not the content: $\mathcal{M}(a)$ is the byte *stored at* $a$. A *pointer* is a variable whose
value is an address.

### Addresses: 64 bits, 48 used

A 64-bit machine has 64-bit pointers ($n=64$), so each address is stored on 8 bytes. With
4-level paging, however, the CPU only translates the lower **48 bits**, so $2^{48}$ bytes
$=256$ TiB are addressable. The top 16 bits are not free: they must be copies of bit 47
(**canonical address**), which splits the space in two halves (x86-64):

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
([integers](cpu_and_memory.md#integers-and-overflow)): a canonical address is a 48-bit
signed number copied into 64 bits, in $[\![-2^{47},\,2^{47}-1]\!]$. Non-negative values
form the user half, negative values the kernel half.

Why not use all 64 bits? Each address bit makes the page tables and translation
hardware bigger and slower: $48=4\times9+12$ is four page-table levels plus a 12-bit
offset (see [virtual memory](../3_operating_systems/virtual_memory.md#multi-level-page-tables)).
256 TiB was plenty when x86-64 appeared (2003); recent CPUs offer 5 levels (57 bits,
128 PiB) for very large servers.

## Type

Bytes have no meaning by themselves. A `type` says how to interpret and manipulate a
sequence of bytes. Let $\mathcal{T}$ be the set of types; a type $\tau\in\mathcal{T}$
(of any size, from a `char` to a large `struct`) specifies:

- **how many bytes to read**: its length $\ell_\tau\in\mathbb{N}$;
- **how to decode them** (integer, float, string, ...): a decoding map $d_\tau$;
- **which operations are legal**: a set $\Omega_\tau$ (for an `int32`: $+,-,\times,\dots$; for
  a string: concatenation, ...).

A **pair** $(a,b)$ is two objects grouped in a fixed order (like a Python tuple of
length 2); a **triple** groups three. So a type is the triple

$$\tau=(\ell_\tau,\ d_\tau,\ \Omega_\tau), \qquad
\text{value of type }\tau\text{ at }a \;=\; d_\tau\big(\mathcal{M}(a),\dots,\mathcal{M}(a+\ell_\tau-1)\big)$$

| Type $\tau$ | Length $\ell_\tau$ | Decoding $d_\tau$ | Legal operations $\Omega_\tau$ (examples) |
|-------------|--------------------|-------------------|-------------------------------------------|
| `char` | 1 | byte as a character code | comparison, conversion |
| `int32` | 4 | little-endian, two's complement | $+,-,\times,\div,\bmod$, bitwise, comparison |
| `float64` | 8 | IEEE 754 double | $+,-,\times,\div$ (IEEE rules), comparison, `sqrt` |

Example: the bytes `2A 00 00 00` at address $a$ are the integer $42$ as an `int32`
($\ell=4$) but the character `'*'` as a `char` ($\ell=1$): memory is the same, only $\tau$
changes the meaning. The operations matter too: the same
bit patterns are added by a different CPU instruction for integers (`add`) and for floats
(`addsd`), which is why the compiler must know the type of every value.

### Byte order (endianness)

A value longer than one byte occupies consecutive addresses, so the bytes need an order.
A $k$-byte unsigned integer stored at $a$ is, in **little-endian** (x86, usually ARM), the
least significant byte first:

$$x = \sum_{i=0}^{k-1} \mathcal{M}(a+i)\, 256^{\,i}$$

and in **big-endian** the most significant byte first, with weight $256^{\,k-1-i}$. The
`int32` $42$ is stored `2A 00 00 00` in little-endian and `00 00 00 2A` in big-endian.
Network protocols use big-endian ("network byte order"), so programs convert at the
boundary (`htons`, `htonl`; `int.from_bytes(b, "big")` in Python).

## Picture: bulbs

Think of each bit as a bulb, on ($\bullet=1$) or off ($\circ=0$).

**Memory** is a long column of rows, one row of 8 bulbs (one byte) per address. It is like
a building with $2^n$ apartments: the contents are the 8 bulbs inside, the address is
the number on the door.

```text
 address   contents (1 byte)
 0         ○ ○ ● ○ ● ○ ● ○     (0x2A)
 1         ○ ○ ○ ○ ○ ○ ○ ○
 ...       ...
 2^n - 1   ○ ● ○ ○ ● ● ○ ●
```

Total: $8\times2^n$ bulbs. An 8×8 grid is therefore only 8 bytes.

**An address** (a pointer in a register) is a separate set of $n$ bulbs whose pattern is
read as a number: it is not stored in the row it selects, it *chooses* the row. A 64-bit
value is 8 rows of 8 bulbs, for example the pointer `0x0000_7FFF_FFFF_FFFF`:

```text
 byte 7  00   ○ ○ ○ ○ ○ ○ ○ ○
 byte 6  00   ○ ○ ○ ○ ○ ○ ○ ○     <- top 16 bits: all off
 byte 5  7F   ○ ● ● ● ● ● ● ●     <- bit 47 (leftmost bulb of this byte): off
 byte 4  FF   ● ● ● ● ● ● ● ●
 byte 3  FF   ● ● ● ● ● ● ● ●
 byte 2  FF   ● ● ● ● ● ● ● ●
 byte 1  FF   ● ● ● ● ● ● ● ●
 byte 0  FF   ● ● ● ● ● ● ● ●
```

Small machine, $n=3$: $2^3=8$ rows, so $8\times8=64$ memory bulbs, and each address is 3
bulbs (`000` selects row 0, `101` selects row 5). A pointer stored *in* memory occupies 8
consecutive rows: its 64 data bulbs encode the door number of another row.
