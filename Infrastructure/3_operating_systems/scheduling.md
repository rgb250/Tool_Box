# Scheduling

> **History:** batch systems ran jobs to completion; time-sharing (1960s) introduced
> **preemption** and round robin; Linux used $O(1)$ then the **CFS** scheduler
> (2007, "completely fair"), and **EEVDF** since kernel 6.6 (2023). See the
> [timeline](../timeline.md#operating-systems). Previous:
> [processes and threads](processes_and_threads.md). Next:
> [virtual memory](virtual_memory.md).

## The problem

There are $n$ ready tasks and $c$ cores, with $n\gg c$. At each instant the
scheduler picks which task runs, i.e. a map

$$\sigma : \text{time}\to\text{Tasks}\cup\{\text{idle}\}$$

The timer interrupt ([system calls](system_calls.md#interrupts-the-other-way-in))
lets the kernel take back the CPU, so scheduling is **preemptive**.

## Metrics

For a task $i$ with arrival $a_i$, CPU burst $b_i$ and completion time $f_i$:

| Metric | Definition |
|--------|------------|
| Turnaround time | $T_i = f_i - a_i$ |
| Waiting time | $W_i = T_i - b_i$ (time spent ready but not running) |
| Response time | time from arrival to first run |
| Throughput | tasks completed per unit time |
| Fairness | each task gets a fair share |

These goals conflict: minimizing average turnaround favours short jobs;
interactive responsiveness needs frequent switches; throughput prefers few switches.

## Classic algorithms

Worked example: three tasks arrive at $t=0$ with bursts $b=(24, 3, 3)$.

| Algorithm | Rule | Waiting times | Average $\bar W$ |
|-----------|------|---------------|------------------|
| **FCFS** (first come, first served) | run in arrival order, no preemption | $0, 24, 27$ | $17$ |
| **SJF** (shortest job first) | run the shortest burst first | $0, 3, 6$ (order 3, 3, 24) | $3$ |
| **Round robin**, quantum $q=4$ | each task runs at most $q$, then goes to the back of the queue | $6, 4, 7$ | $5.67$ |

- SJF is **provably optimal** for $\bar W$ (swapping a long job before a short one
  always increases the sum), but needs to know bursts in advance, and can starve
  long jobs.
- FCFS suffers from the **convoy effect**: short jobs stuck behind a long one.
- Round robin is fair and responsive; the choice of $q$ is the trade-off below.
- **Priority** scheduling: highest priority first; risk of **starvation**, solved
  by **aging** (priority grows while waiting).
- **Multilevel feedback queue**: start high priority, demote tasks that use their full
  quantum (CPU-bound) and keep interactive ones high. Approximates SJF without knowing the future.

### Context switch overhead

With quantum $q$ and switch cost $c$, the useful fraction of CPU time is

$$\eta = \frac{q}{q+c}$$

Example: $c=5\,\mu s$, $q=10$ ms gives $\eta\approx 99.95\%$; $q=50\,\mu s$
gives $\eta\approx 91\%$. A small $q$ improves response time but wastes CPU; a huge $q$
degenerates to FCFS.

## Linux: CFS in one idea

CFS gives each task a **virtual runtime** and always runs the task with the
smallest one (kept in a red-black tree, $O(\log n)$). While running for $\Delta t$,
a task with weight $w_i$ (derived from its `nice` value) advances by

$$\text{vruntime}_i \mathrel{+}= \Delta t\cdot\frac{w_0}{w_i}$$

so heavier (higher priority) tasks age slower and get more CPU, in proportion to
$w_i / \sum_j w_j$. No fixed priorities and no magic constants: just "equalize
vruntime".

`nice` ranges from $-20$ (most priority) to $19$; each step is about $10\%$ CPU.
Real-time classes (`SCHED_FIFO`, `SCHED_RR`) always preempt normal tasks.

## Scheduling and I/O

Most tasks alternate CPU bursts and I/O waits. When a task calls `read`, it moves
to **Blocked** and another task runs; the CPU is kept busy. If a fraction $p$ of
its time a process waits on I/O, with $k$ such processes in memory the CPU
utilization is approximately

$$U \approx 1 - p^{k}$$

(e.g. $p=0.8$, $k=5$: $U\approx 67\%$; $k=10$: $89\%$). This is the rationale for
multiprogramming, and for `asyncio`/event loops at the application level.

## Little's law (a useful bridge to servers)

For any stable queueing system, with average arrival rate $\lambda$, average
time spent in the system $W$ and average number in the system $L$:

$$L = \lambda\, W$$

It applies to a CPU run queue, a web server (concurrent requests = request rate $\times$ latency)
or a thread pool. We will reuse it in the networking and API chapters.

## Things to remember

- Preemption relies on the timer interrupt.
- $T_i=f_i-a_i$ and $W_i=T_i-b_i$; SJF minimizes average waiting time but is
  not implementable exactly; real schedulers approximate it.
- The quantum trades responsiveness against efficiency $q/(q+c)$.
- Linux runs the task with the smallest weighted virtual runtime.
- $L=\lambda W$.

## Exercises

1. Recompute the table above by drawing the Gantt chart of each algorithm.
2. `nice -n 19 python3 busy.py &` and `python3 busy.py &` on a single core
   (`taskset -c 0`); watch `top`. Do shares match the weights?
3. `cat /proc/sched_debug` or `chrt -p $$` to see your shell's policy.
4. A server handles 200 req/s with 50 ms average latency: how many requests are
   in flight on average?

## Going further

- OSTEP: "Scheduling" chapters (MLFQ, proportional share).
- `man 7 sched`.
