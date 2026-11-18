# Processes and threads

> **History:** early machines ran one program at a time; time-sharing (CTSS 1961,
> Unix 1969) let several programs share one CPU; multicore (2005) made real
> parallelism the norm; Docker (2013) packaged isolation from kernel features. See the
> [timeline](../timeline.md#operating-systems). Previous:
> [system calls](system_calls.md). Next: [scheduling](scheduling.md).

## Process

A **program** is a file (code). A **process** is a program *in execution*: code
plus state. Formally a process is a tuple

$$P = (\text{pid},\; \text{address space},\; R,\; pc,\; \text{fd table},\; \text{state},\; \dots)$$

stored by the kernel in a **process control block** (`task_struct` in Linux).
Each process believes it owns the whole machine: its own memory
([virtual memory](virtual_memory.md)) and its own CPU registers.

### States

```text
              schedule
   Ready  ------------->  Running
     ^   <-------------      |
     |      preempted        | waits for I/O
     |                       v
     +-----------------  Blocked (waiting)
          I/O done
```

$\text{Ready}\leftrightarrow\text{Running}\to\text{Blocked}\to\text{Ready}$, plus
`New` and `Terminated` (a **zombie** has exited but its parent has not read its exit code yet).

### Creating processes: fork and exec

Unix separates creation into two calls:

- `fork()`: duplicate the calling process (child gets a copy of memory, using
  copy-on-write, and of the fd table). Returns 0 in the child, the child's pid in the parent.
- `execve(path, args)`: replace the process's code and data with another program.

```c
pid_t pid = fork();
if (pid == 0) execve("/bin/ls", args, env);   // child becomes ls
else          waitpid(pid, &status, 0);        // parent waits
```

Every process has a parent, giving a **tree** rooted at `init`/`systemd` (pid 1):
$\text{parent}: \text{Process}\to\text{Process}$. This is exactly what a shell does
for each command. `ps -ef --forest` or `pstree` show it.

### Context switch

To switch from $P_1$ to $P_2$ the kernel saves $(R, pc)$ of $P_1$ in its PCB,
loads those of $P_2$ and changes the address space. It costs microseconds plus
cache and TLB pollution, so switching too often is wasteful (see
[scheduling](scheduling.md#context-switch-overhead)).

## Threads

A **thread** is an execution flow (its own $R$, $pc$, stack) **inside** a process.
Threads of one process share code, heap, globals and fds.

| | Process | Thread |
|---|---------|--------|
| Memory | private | shared with the siblings |
| Creation / switch cost | high | low |
| Communication | via IPC (pipes, sockets, shared memory) | direct memory access |
| Failure | isolated | a crash kills the whole process |

### Concurrency vs parallelism

- **Concurrency**: several tasks making progress in overlapping time (possibly on
  one core, interleaved). It is about *structure*.
- **Parallelism**: several tasks running at the same instant on several cores.
  It is about *speed*.

**Amdahl's law**: if a fraction $p$ of the work is parallelizable on $n$ cores,

$$S(n) = \frac{1}{(1-p) + \dfrac{p}{n}} \;\xrightarrow[n\to\infty]{}\; \frac{1}{1-p}$$

Example: $p=0.9$ gives at most $10\times$ speedup, whatever the core count.

### Python specifics

CPython has a **Global Interpreter Lock** (GIL): only one thread runs Python
bytecode at a time. Consequences:

| Workload | Best tool |
|----------|-----------|
| I/O-bound (network, disk) | `threading` or `asyncio` (threads wait, so the GIL is released) |
| CPU-bound | `multiprocessing` (separate processes, separate GILs) or native extensions (NumPy) |

## Synchronization

Shared memory creates **race conditions**: the result depends on the
interleaving. `counter += 1` is really load, add, store, so two threads can both
read 5 and both write 6, losing an update.

Tools: **mutex** (only one thread in a critical section), **semaphore**
(counter allowing up to $k$ holders), **condition variable**, **atomic**
operations.

**Deadlock** needs all four Coffman conditions at once: mutual exclusion, hold
and wait, no preemption, circular wait. Break one, for instance always acquire
locks in a global order, and deadlock is impossible.

## Inter-process communication (IPC)

| Mechanism | Idea |
|-----------|------|
| Pipe | one-way byte stream (`f \| g`) |
| Signal | tiny asynchronous message (`SIGINT`, `SIGTERM`, `SIGKILL`) |
| Shared memory | same physical pages mapped in two processes (fastest, needs sync) |
| Socket | a stream or datagrams, locally (Unix socket) **or over the network** |

Sockets are the bridge to the [networking chapter](../4_networking/).

## Isolation: namespaces and cgroups

Containers are not tiny virtual machines but ordinary processes with a restricted
view, built from two kernel features:

- **Namespaces** limit what a process *sees*: its own pids, mounts, network
  interfaces, hostnames.
- **cgroups** limit what it can *use*: CPU, memory, I/O.

$$\text{container} \approx \text{process} + \text{namespaces} + \text{cgroups} + \text{image filesystem}$$

A VM, in contrast, virtualizes hardware and runs a full separate kernel. See
`Virtualization/docker/notes.md`.

## Things to remember

- Process = program + state, isolated; thread = flow of control sharing a process's memory.
- Creating a process = `fork` then `exec`; the processes form a tree.
- Amdahl: the serial fraction bounds the speedup.
- Shared state needs synchronization; deadlock needs four conditions.
- A container is a process in disguise.

## Exercises

1. `pstree -p $$` and `ps -o pid,ppid,stat,cmd`; find your shell's parent.
2. Run `sleep 100 &` then `kill -STOP`, `kill -CONT` and look at the `STAT` column.
3. Python: increment a shared counter from 4 threads 1e6 times each without a lock.
   Is the result 4e6? Add a `Lock`.
4. Time a CPU-bound function with `threading` vs `multiprocessing`.
5. `unshare --pid --fork --mount-proc bash` then `ps`: what do you see?

## Going further

- OSTEP: virtualization of the CPU, concurrency parts.
- `man 2 fork`, `man 7 namespaces`, `man 7 cgroups`.
