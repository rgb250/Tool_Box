# Memory and addresses

> Companion of [CPU and memory](cpu_and_memory.md): what memory is, what an address is, and
> how bytes get a meaning through a type.

## Memory

`Memory` is a large array of **bytes**. Formally it is a function from addresses to bytes:

$$\mathcal{M} : \{0,\dots,N-1\} \to \{0,\dots,2^{8}-1\}, \qquad N = 2^{n}$$

where $n$ is the address width. On a 64-bit machine $n=64$, so $N=2^{64}$ in theory (in
practice 48 bits are used, see [addresses](cpu_and_memory.md#addresses-64-bits-48-used)).
A byte is 8 bits, so it holds $2^8=256$ distinct values.

A program only touches a small fraction of this array at a time, usually a few
**consecutive** bytes (4 for an `int32`, 8 for a `float64`...), not the whole of it.

## Address

An `Address` is an **index** $a\in\{0,\dots,N-1\}$: the position of a byte in `Memory`. It is
not the content: $\mathcal{M}(a)$ is the byte *stored at* $a$. A *pointer* is a variable whose
value is an address.

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
