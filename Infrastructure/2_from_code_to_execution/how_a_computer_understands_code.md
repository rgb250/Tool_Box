# How a computer understands code

> **History:** assembly $\to$ FORTRAN compiler (1957) $\to$ C and Unix (1972) $\to$
> Python (1991) $\to$ Java/JVM and JavaScript JIT (1995) $\to$ Go and Rust (2009-15).
> See the [languages](../timeline.md#languages) and
> [operating systems](../timeline.md#operating-systems) timelines. Previous:
> [CPU and memory](../1_hardware/cpu_and_memory.md).

## The core problem

The CPU only understands **machine code**: binary instructions of its ISA
(x86-64, ARM...). Humans write `print("hi")` or `ls -l`. Something must
**translate** between the two. There are three main strategies.

| Strategy | Translation happens | Examples |
|----------|---------------------|----------|
| **Compiled** (ahead of time) | Once, before running, to native machine code | C, C++, Rust, Go |
| **Interpreted** | Line by line (or bytecode by bytecode) while running | Python (CPython), Bash, R |
| **JIT-compiled** | Bytecode compiled to machine code at runtime, on hot paths | Java (JVM), JavaScript (V8), PyPy, Julia |

**Formalisation.** Let $\llbracket p \rrbracket_L : \text{Input}\to\text{Output}$ be
the meaning of a program $p$ written in language $L$.

- A **compiler** is a function $C: L \to \text{ISA}$ that preserves meaning:
  $\llbracket C(p) \rrbracket_{\text{ISA}} = \llbracket p \rrbracket_L$.
- An **interpreter** is a program $I_L$ that takes the program as data:
  $\llbracket I_L \rrbracket(p, x) = \llbracket p \rrbracket_L(x)$.
- Compiled: translate once, then run $C(p)$ on many inputs. Interpreted: pay the
  translation on every run. The cost split is
  $T_{\text{compiled}} = T_C + T_{\text{run}}$ versus
  $T_{\text{interp}} = T_{\text{run}}\times\text{overhead}$.

The boundary is blurry: CPython first compiles source to bytecode, then
interprets that bytecode. "Compiled vs interpreted" describes an
*implementation*, not a language.

## 1. What machine code looks like

An instruction is a few bytes: an **opcode** (what to do) plus operands
(registers, constants, addresses). For `a = b + 1` a compiler may emit
(x86-64 assembly, a human-readable form of machine code):

```asm
mov  eax, [rbp-8]     ; load b from memory into register eax
add  eax, 1           ; eax = eax + 1
mov  [rbp-4], eax     ; store the result into a
```

Assembly maps almost 1:1 to machine code; an **assembler** converts the
mnemonics to bytes (e.g. `83 C0 01` for `add eax, 1`).

## 2. The compilation pipeline (C as the reference)

A compiler is a **composition of simple passes**, each preserving meaning:

$$C = \text{link}\circ\text{asm}\circ\text{codegen}\circ\text{optimize}\circ\text{analyze}\circ\text{parse}\circ\text{lex}\circ\text{preprocess}$$

Each pass changes the representation: text $\to$ tokens $\to$ AST $\to$ IR
$\to$ assembly $\to$ object code $\to$ executable. The optimizer is the only
$IR\to IR$ step and uses rewrite rules $e \rightsquigarrow e'$ with
$\llbracket e\rrbracket=\llbracket e'\rrbracket$ (e.g. $x\times 2 \rightsquigarrow x \ll 1$,
$2+3 \rightsquigarrow 5$).

```text
 source.c
   | preprocessor    expands #include, #define         -> pure C text
   v
 compiler
   |  lexer          characters -> tokens
   |  parser         tokens -> syntax tree (AST), checks grammar
   |  semantic pass  types, scopes, undefined names
   |  optimizer      intermediate representation (IR): inline, remove dead code, ...
   |  code generator IR -> assembly for the target ISA
   v
 source.s
   | assembler                                          -> object file
   v
 source.o   (machine code + symbol table, addresses not final)
   | linker          merges .o files and libraries, resolves symbols
   v
 executable (ELF on Linux, Mach-O on macOS, PE on Windows)
```

Try it:

```bash
gcc -E hello.c -o hello.i   # preprocess
gcc -S hello.c              # to assembly (hello.s)
gcc -c hello.c              # to object file (hello.o)
gcc hello.c -o hello        # full pipeline
objdump -d hello | less     # disassemble machine code
file hello                  # "ELF 64-bit LSB executable"
```

### Static vs dynamic linking

- **Static**: library code is copied into the executable (bigger, self-contained).
- **Dynamic**: the executable references shared libraries (`.so` / `.dll`),
  loaded at start by the **dynamic loader**. `ldd hello` lists them.

### The executable file

An ELF file contains sections: `.text` (code), `.data` (initialised globals),
`.bss` (zero-initialised globals), `.rodata` (constants), plus headers telling
the OS where to put each in memory and where execution starts.

## 3. Running a program: the loader

When you type `./hello`, the **OS loader**:

1. reads the ELF headers;
2. creates a **process** with its own virtual address space (OS chapter);
3. maps `.text`, `.data` into that space and sets up the **stack** and **heap**;
4. loads shared libraries;
5. sets the program counter to the entry point. The CPU is now running your code.

Memory layout of a process (high to low addresses):

```text
 stack   (function calls, local variables; grows down)
   ...
 heap    (malloc / dynamic objects; grows up)
 .bss / .data
 .text   (machine code)
```

Calling a function pushes a **stack frame** (arguments, return address, locals);
returning pops it. A stack overflow is infinite recursion filling the stack.

## 4. Interpreters and bytecode (Python)

```text
 script.py -> lexer/parser -> AST -> bytecode (.pyc) -> CPython virtual machine
```

The interpreter is itself a compiled C program that loops: read a bytecode,
perform the corresponding action. Inspect it:

```python
import dis
dis.dis(lambda a, b: a + b)
# LOAD_FAST a / LOAD_FAST b / BINARY_OP + / RETURN_VALUE
```

Consequences: a Python addition costs tens of machine instructions instead of one
(dynamic typing, object boxing, interpreter loop), which is why NumPy delegates
loops to compiled C/Fortran code, and why `Numba`, `Cython` or `PyPy` exist.
Python is not slow because it is "interpreted" only, but because of this
per-operation overhead and the Global Interpreter Lock for threads.

**JIT** (JVM, V8): the runtime watches which code is hot, compiles it to
machine code with profile-based optimisations, and falls back to the
interpreter otherwise. Slow start, fast steady state.

## 5. How a shell command is understood

Typing `ls -l /tmp | grep log > out.txt` in Bash:

1. **Read** the line and **parse** it: tokens, pipes, redirections, quotes,
   variable expansion (`$HOME`), globbing (`*.py`).
2. Decide if each command is a **builtin** (`cd`, `export`: run inside the shell
   itself) or an **external program**.
3. For external programs, search `$PATH` for an executable named `ls`.
4. Ask the OS to create a process: `fork()` duplicates the shell, `exec()` replaces
   the copy with the program; `wait()` waits for it.
5. Wire the plumbing: the pipe connects `ls` stdout to `grep` stdin; `>`
   redirects stdout to a file.
6. The program runs, returns an **exit code** (`echo $?`; 0 = success).

**Pipes are function composition.** If a program is a function on byte streams,
$\texttt{f | g} = g\circ f$, and $\texttt{f | g | h} = h\circ g\circ f$ (associative,
data flows left to right). Redirection `> file` just changes where the final
stream goes. The exit code is a map $\text{status}\in\{0,\dots,255\}$ with $0$ meaning success.

So a shell is just an interpreter whose "instructions" are mostly "run this
program". Try `type cd ls`, `which python`, `strace -f -e execve bash -c 'ls'`.

Related: a **shebang** (`#!/usr/bin/env python3`) on the first line of a script
tells the OS which interpreter to launch for it.

## 6. System calls: how programs reach the hardware

A program cannot directly touch disk, network or screen. It asks the kernel via a
**system call** (`open`, `read`, `write`, `socket`, `fork`...). `print("hi")`
ends up as `write(1, "hi\n", 3)`. This boundary between user code and the kernel
is the topic of the operating systems chapter, and the network sockets of the
networking chapter go through it too.

## Things to remember

- CPU executes only machine code; every language ends up there, directly (compiled)
  or through an interpreter/VM (which is itself machine code).
- Compile = lex, parse, analyse, optimise, generate code, assemble, link.
- Compiled languages catch more errors early and run faster; interpreted ones
  trade speed for flexibility and fast iteration.
- Running a program = OS loader builds a process, maps the file, jumps to entry point.
- Shell command = parse, find the program, `fork` + `exec`, wire the pipes.

## Exercises

1. Write `hello.c`, run each `gcc` stage above, and read the `.s` file.
2. `dis.dis` a Python function with a loop and a list comprehension; compare.
3. Run `strace -c python -c "print(1)"` and `ldd $(which python3)`.
4. Compare timings of `sum(range(10**7))` in pure Python and `np.arange(10**7).sum()`.
5. Write a 10-line Go or Rust program, build it, and compare binary sizes with C.

## Going further

- *Crafting Interpreters* (Nystrom, free online): build an interpreter step by step.
- *Computer Systems: A Programmer's Perspective*, ch. 3 and 7.
- *Compilers: Principles, Techniques and Tools* ("the Dragon Book").
