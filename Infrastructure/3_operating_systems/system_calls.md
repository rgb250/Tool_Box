# Kernel, interrupts and system calls

> **History:** Unix (1969) put a small **kernel** between programs and hardware and
> made "everything a file"; Linux (1991) reimplemented it freely. See the
> [operating systems timeline](../timeline.md#operating-systems). Previous chapter:
> [code to execution](../2_from_code_to_execution/how_a_computer_understands_code.md#6-system-calls-how-programs-reach-the-hardware).
> Next: [processes and threads](processes_and_threads.md).

## What an OS is

An operating system does two jobs:

1. **Abstraction**: turn raw hardware into clean objects (process, file, socket).
2. **Resource management and protection**: share CPU, memory and devices among
   programs that must not harm each other.

Formally, if the hardware is a state machine $\delta_{\text{hw}}$, the OS builds a
richer machine $\delta_{\text{os}}$ whose "instructions" include `open`, `fork`,
`send`... Each program sees only its own virtual machine.

## Privilege levels

The CPU has (at least) two modes, enforced in hardware:

| Mode | Name | Can do |
|------|------|--------|
| **Kernel mode** (ring 0) | the kernel | everything: access devices, change page tables, halt the CPU |
| **User mode** (ring 3) | your programs | compute on own memory only; anything else must ask the kernel |

A user program touching forbidden memory or running a privileged instruction
triggers a hardware **exception**; the kernel reacts (e.g. kills it with
`Segmentation fault`).

## System calls

A **system call** is the controlled entry point from user mode to kernel mode:

$$\text{sys} : (n, a_1,\dots,a_k) \longmapsto r \in \mathbb{Z}, \qquad r<0 \Rightarrow \text{error } (-r = \texttt{errno})$$

with $n$ the call number and $a_i$ its arguments (registers on x86-64: number in
`rax`, arguments in `rdi, rsi, rdx, ...`).

Steps for `write(1, "hi\n", 3)`:

1. The C library puts $n$ and the arguments in registers.
2. The `syscall` instruction switches to kernel mode and jumps to a fixed kernel address
   (user code cannot choose where).
3. The kernel validates the arguments, performs the work, stores the result.
4. It returns to user mode right after the `syscall` instruction.

Cost: about 0.1-1 µs, far more than a function call, which is why libraries batch
I/O (buffering: one `write` of 4 KB instead of 4096 of 1 byte).

| Domain | Typical calls |
|--------|---------------|
| Files | `open`, `read`, `write`, `close`, `stat`, `unlink` |
| Processes | `fork`, `execve`, `wait`, `exit`, `kill` |
| Memory | `mmap`, `munmap`, `brk` |
| Network | `socket`, `bind`, `connect`, `send`, `recv` |
| Time, misc | `clock_gettime`, `ioctl` |

Programs rarely call them directly; they use the C library (`libc`), which wraps
them, and your language runtime sits on top of that.

```bash
strace -c python3 -c "print('hi')"        # count the syscalls used
strace -e trace=write python3 -c "print('hi')"
man 2 write                                # section 2 = system calls
```

## Interrupts: the other way in

The kernel also runs when the **hardware** needs attention. Three sources:

| Source | Example |
|--------|---------|
| **Interrupt** (asynchronous) | network card received a packet, key pressed, **timer tick** |
| **Exception** (synchronous, error) | division by zero, invalid address, **page fault** |
| **System call** (synchronous, intended) | `read(...)` |

On each, the CPU saves the state $(R, pc)$, jumps to a handler found in the
**interrupt vector table**, then resumes. The **timer interrupt** matters most: it
gives the kernel control back every few milliseconds, even from an infinite
loop, which makes preemptive [scheduling](scheduling.md) possible.

## File descriptors

The kernel represents each open resource (file, pipe, socket, terminal) by a small
integer, the **file descriptor**. Per process it is a partial map:

$$\text{fd} : \mathbb{N} \rightharpoonup \text{OpenResource}$$

By convention $0$ = stdin, $1$ = stdout, $2$ = stderr. This explains the shell:
`> out.txt` changes what fd 1 points to, and a pipe `f | g` connects fd 1 of $f$ to fd 0 of
$g$. Same `read`/`write` calls work on all of them, hence "everything is a file"
(see [file systems](file_systems.md#everything-is-a-file)).

## Kernel architectures

- **Monolithic** (Linux): drivers, file systems and network stack in one big
  kernel. Fast, but a driver bug can crash everything.
- **Microkernel** (Minix, seL4): minimal kernel, the rest in user-space servers.
  Safer, with more message passing.
- Hybrid (Windows NT, macOS XNU): mix of both.

## Things to remember

- User code is confined; privilege is only gained through a syscall, an
  interrupt or an exception, always entering at kernel-chosen addresses.
- A syscall is $\text{sys}(n, \vec a)\to r$ with $r<0$ meaning an error.
- A file descriptor is an index into a per-process table.
- The timer interrupt lets the OS take back the CPU.

## Exercises

1. `strace -c ls` then `strace ls 2>&1 | head -30`; identify `execve`, `openat`,
   `write`.
2. `ls -l /proc/self/fd` in your shell: which resources do 0, 1, 2 point to?
3. Run `python3 -c "import os; os.write(1, b'hi\n')"` and compare to `print`.
4. Cause a segmentation fault in C (`*(int*)0 = 1;`) and see the exit code (139 = 128+11).

## Going further

- *Operating Systems: Three Easy Pieces* (OSTEP, free online), "Limited Direct Execution".
- `man 2 syscalls`, `man 7 signal`.
