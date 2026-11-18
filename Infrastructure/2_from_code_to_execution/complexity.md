# Complexity: how cost grows

> **History:** Turing (1936) asked what is *computable*; Hartmanis and Stearns (1965)
> asked how much time and memory it *costs* and founded complexity theory; Cook (1971)
> defined NP-completeness (the P vs NP question); Knuth (1976) popularized the
> $O/\Omega/\Theta$ notation in algorithm analysis. See the
> [timeline](../timeline.md#theory-and-cryptography). Previous:
> [how code runs](how_a_computer_understands_code.md). Next chapter:
> [operating systems](../3_operating_systems/system_calls.md).

## Why a programmer needs it

Two programs can give the same answer, one in a millisecond and one in a week.
Complexity measures how the **cost** (time, memory, messages) **grows with the input size
$n$**, independently of the machine and the language. It tells you, before
running anything, whether an approach can survive $10^{6}$ or $10^{9}$ items.

Cost model: count **elementary operations** (compare, add, memory access). Real time is
$T=N_{\text{ops}}\times(\text{time per op})$ (see
[execution time](../1_hardware/cpu_and_memory.md#execution-time)); complexity captures
$N_{\text{ops}}(n)$, the machine only changes the constant.

## Asymptotic notation

For $f,g:\mathbb{N}\to\mathbb{R}_{>0}$ (think $f$ = real cost, $g$ = simple reference function):

$$f\in O(g)\iff \exists\,c>0,\ n_0:\ \forall n\ge n_0,\quad f(n)\le c\,g(n)$$

"$f$ grows **at most** like $g$" (upper bound). Symmetrically:

| Notation | Meaning | Definition |
|----------|---------|------------|
| $f\in O(g)$ | at most $g$ (upper bound) | $f\le c\,g$ eventually |
| $f\in\Omega(g)$ | at least $g$ (lower bound) | $f\ge c\,g$ eventually |
| $f\in\Theta(g)$ | exactly the order of $g$ | $f\in O(g)\cap\Omega(g)$ |

Limit test: if $\lim_{n\to\infty} f(n)/g(n)=L$ with $0<L<\infty$, then $f\in\Theta(g)$.

Rules that make it easy:

- **Drop constants and lower terms**: $3n^2+50n+7\in\Theta(n^2)$.
- **Sequence adds, nesting multiplies**: two loops one after another $O(n)+O(n)=O(n)$;
  a loop inside a loop $O(n)\times O(n)=O(n^2)$.
- **Dominant term wins**: $O(n+n\log n)=O(n\log n)$.
- Logarithm base is irrelevant: $\log_a n=\log_b n/\log_b a$ (a constant factor).

Misconception: $O$ is *not* "the worst case". "Worst case", "average case" and "best
case" describe **which inputs** you analyse; $O/\Omega/\Theta$ describe **how tight**
the bound on that function is. (You can say "the worst case is $\Theta(n^2)$".)

## The common classes

| Class | Name | Example | $n=10^3$ | $n=10^6$ | $n=10^9$ |
|-------|------|---------|---------:|---------:|---------:|
| $O(1)$ | constant | array index, hash lookup | 1 ns | 1 ns | 1 ns |
| $O(\log n)$ | logarithmic | binary search, B-tree | 10 ns | 20 ns | 30 ns |
| $O(n)$ | linear | scan a list | 1 µs | 1 ms | 1 s |
| $O(n\log n)$ | linearithmic | good sorting | 10 µs | 20 ms | 30 s |
| $O(n^2)$ | quadratic | nested loops, naive pairs | 1 ms | 17 min | 32 years |
| $O(n^3)$ | cubic | naive matrix product | 1 s | 32 years | no |
| $O(2^n)$ | exponential | all subsets, brute force | $10^{292}$ s | no | no |

(Time at $10^9$ operations per second, one per nanosecond.) Read it this way:

- Up to $O(n\log n)$ you can process very large inputs.
- $O(n^2)$ is fine for $n\le10^4$, dead at $10^6$.
- $O(2^n)$ is hopeless beyond $n\approx 40$-$50$. With $n=64$ it is the
  [$2^{64}$ steps $\approx585$ years](../1_hardware/cpu_and_memory.md#integers-and-overflow)
  already met. A faster computer changes the constant: $100\times$ more speed adds only
  $\log_2 100\approx 7$ to the feasible $n$ for $2^n$, but multiplies it by $10$ for $n^2$.

**Rule of thumb**: with about $10^{8}$-$10^{9}$ simple operations per second, a
solution is acceptable when $N_{\text{ops}}(n)\lesssim10^{9}$ for your largest $n$.

## Analysing code

```python
def f(a):                   # n = len(a)
    s = 0
    for x in a:             # n iterations
        s += x              #   O(1)       -> O(n)
    for x in a:             # n iterations
        for y in a:         #   n iterations
            s += x * y      #     O(1)     -> O(n^2)
    return s                # total: O(n) + O(n^2) = O(n^2)

def g(n):                   # halving loop
    while n > 1:
        n //= 2             # n -> n/2 -> n/4 ... -> 1: log2(n) iterations -> O(log n)
```

Pattern: a loop that **divides** the problem by a constant factor each step runs
$\log n$ times; one that visits each element once is $n$.

### Recurrences and divide and conquer

A divide-and-conquer algorithm splits the input into $a$ subproblems of size $n/b$ and
does $f(n)$ extra work:

$$T(n)=a\,T(n/b)+f(n)$$

Unrolled, the recursion tree has $\log_b n$ levels. When $f(n)=\Theta(n)$ and $a=b$
(each level costs $n$ in total): $T(n)=\Theta(n\log n)$.

- **Merge sort**: $T(n)=2T(n/2)+n\Rightarrow\Theta(n\log n)$.
- **Binary search**: $T(n)=T(n/2)+1\Rightarrow\Theta(\log n)$.
- **Naive Fibonacci**: $T(n)=T(n-1)+T(n-2)\Rightarrow\Theta(\varphi^{n})$ (exponential); with
  memoization each value is computed once, $\Theta(n)$. Same function, an exponential
  gap: it is **dynamic programming**.

### Amortized analysis

Some operations are usually cheap and occasionally expensive. The **amortized** cost is the
average over a worst-case *sequence*. Python's `list.append` doubles the capacity when
full: for $n$ appends the copies cost $1+2+4+\dots+n<2n$, plus $n$ writes, so the total is
$<3n$, i.e. $O(1)$ amortized per append although a single append can cost $O(n)$.

### Lower bounds

Sorting by comparisons needs $\Omega(n\log n)$: a decision tree distinguishing the $n!$
orderings has at least $n!$ leaves, so height $\ge\log_2(n!)=\Theta(n\log n)$. No cleverness
beats it; only non-comparison sorts (counting, radix) escape it.

## Space complexity

Memory also grows with $n$: a list of $n$ ints is $\Theta(n)$, a recursion of depth $d$
uses $\Theta(d)$ stack. Time and space often trade against each other: a **hash
table** or a cache spends $O(n)$ memory to turn $O(n)$ lookups into $O(1)$
([memoization](#recurrences-and-divide-and-conquer), indexes, CDNs).

## Python cheat sheet

| Operation | Cost | Remark |
|-----------|------|--------|
| `lst[i]`, `len(lst)` | $O(1)$ | |
| `lst.append(x)` | $O(1)$ amortized | |
| `lst.insert(0, x)`, `lst.pop(0)` | $O(n)$ | shifts everything; use `collections.deque` |
| `x in lst` | $O(n)$ | linear scan |
| `x in set` / `d[k]` | $O(1)$ average | hash; worst case $O(n)$ |
| `lst.sort()`, `sorted` | $O(n\log n)$ | Timsort, $O(n)$ if almost sorted |
| `heapq.heappush/pop` | $O(\log n)$ | priority queue |
| `bisect.bisect` | $O(\log n)$ | on a sorted list |
| `s += t` in a loop | $O(n^2)$ overall | build with `"".join(parts)` |
| `lst[a:b]` | $O(b-a)$ | copies |

The classic fix: replace a membership test in a list inside a loop by a set.

```python
import timeit
for n in (10**3, 10**4, 10**5):
    lst = list(range(n)); st = set(lst)
    t_list = timeit.timeit(lambda: (n - 1) in lst, number=200)
    t_set  = timeit.timeit(lambda: (n - 1) in st,  number=200)
    print(n, f"list {t_list:.5f}s  set {t_set:.6f}s")   # list x10 per step, set flat
```

## Complexity in this folder

The same reasoning explains many design choices already met:

| Topic | Cost | Source |
|-------|------|--------|
| Page table walk | 4 levels $=O(\text{levels})$, $O(1)$ per access with a TLB | [virtual memory](../3_operating_systems/virtual_memory.md#multi-level-page-tables) |
| `select`/`poll` vs `epoll` | $O(n)$ vs $O(\text{ready})$ per call | [sockets](../4_networking/sockets.md#serving-many-clients) |
| Linux scheduler (red-black tree) | pick next in $O(\log n)$ | [scheduling](../3_operating_systems/scheduling.md#linux-cfs-in-one-idea) |
| TCP slow start | cwnd doubles per RTT: reaching a window of $W$ segments takes $\log_2(W/10)$ RTT (BDP 6.25 MB $\approx4300$ segments $\Rightarrow\approx9$ RTT) | [TCP](../4_networking/tcp_and_udp.md#congestion-control) |
| Longest-prefix routing | trie lookup $O(\text{address bits})$, independent of table size | [routing](../4_networking/ip_and_routing.md#routing) |
| Offset pagination | $O(\text{offset}+\text{limit})$ vs cursor $O(\log N)$ | [pagination](../5_apis_and_web_services/rate_limiting_and_pagination.md#pagination) |
| GraphQL resolvers | N+1 queries: $O(n)$ vs batched $O(1)$ round trips | [GraphQL](../5_apis_and_web_services/graphql_and_grpc.md#resolvers-and-the-n1-problem) |
| Consistent hashing | $\approx1/(n+1)$ of keys move vs $n/(n+1)$ | [load balancing](../4_networking/cdn_and_load_balancers.md#consistent-hashing) |
| Brute-forcing a $k$-bit key | $O(2^{k})$ | [key sizes](../4_networking/tls.md#key-sizes-and-brute-force) |

## Beyond the notation: what really matters

- **Constants and cache.** $\Theta(n)$ over a contiguous array can beat a
  $\Theta(\log n)$ pointer structure for realistic $n$, because of the
  [memory hierarchy](../1_hardware/cpu_and_memory.md#the-memory-hierarchy)
  ($\sim100\times$ between cache and RAM). Complexity is about the *trend*; measure for
  your $n$.
- **Small $n$.** If $n\le100$, even $O(n^2)$ is fine; clarity first. Python's Timsort uses
  insertion sort ($O(n^2)$) on small runs for exactly this reason.
- **I/O and network dominate** most programs: one network round trip
  ($\sim10^{-1}$ s) equals $\sim10^{8}$ CPU operations. Reducing round trips is a
  higher-order optimization than any loop micro-tuning (see the
  [capstone budget](../life_of_a_web_request.md#time-budget)).
- **Parallelism** divides the constant, not the class
  ([Amdahl](../3_operating_systems/processes_and_threads.md#concurrency-vs-parallelism)).
- **Measure**: `python -m timeit`, `cProfile`, `time`, then optimize the bottleneck.

## Tractable vs intractable

Convention: **polynomial** time $O(n^k)$ is *tractable*, super-polynomial (like $2^n$)
is not.

- **P**: decidable in polynomial time (sorting, shortest path, matrix product).
- **NP**: a proposed solution can be **verified** in polynomial time (a TSP tour of
  length $\le L$, a satisfying assignment, a factorization). $P\subseteq NP$.
- **NP-complete**: the hardest problems of NP (SAT, subset sum, graph colouring,
  decision TSP): if one has a polynomial algorithm, all do. Whether $P=NP$ is open
  (Cook 1971; Clay prize).
- Practical response to an NP-hard problem: heuristics, approximation, special cases,
  small $n$ with exact solvers.

Cryptography **relies on** assumed hardness: finding $a$ from $g^a\bmod p$ (discrete
logarithm) or factoring $n=pq$ has no known polynomial algorithm, while the legitimate
operations (modular exponentiation, multiplication) are polynomial. Security comes
from this gap ([Diffie-Hellman](../4_networking/tls.md#diffie-hellman-key-exchange)).
*Computable* (an algorithm exists) is weaker than *feasible* (it finishes in your lifetime).

## Things to remember

- $f\in O(g)$: $f\le c\,g$ for large $n$; $\Theta$ is the tight bound; drop constants and lower
  terms.
- Memorize the ladder: $1<\log n<n<n\log n<n^2<n^3<2^n<n!$.
- At about $10^{9}$ operations per second, $n^2$ allows $n\sim10^{4}$-$10^5$, $n\log n$ allows
  $n\sim10^{7}$-$10^{8}$, $2^n$ allows $n\sim30$.
- Halving a problem gives $\log n$; divide and conquer gives $n\log n$; memoization
  turns exponential recursion into polynomial.
- Choose data structures for the dominant operation: set for membership, deque for both
  ends, heap for the minimum, sorted array plus binary search for range queries.
- Real performance also depends on constants, caches and I/O: measure.

## Exercises

1. Give the complexity of: (a) two nested loops where the inner one runs `i` times;
   (b) a loop doubling `i` from 1 to `n`; (c) `for x in a: if x in b` with `b` a list, then a set.
2. Time `fib(35)` naive vs with `functools.lru_cache`; explain the gap with $\varphi^n$.
3. Use `timeit` to confirm `lst.insert(0, x)` is $O(n)$ and `deque.appendleft` is $O(1)$.
4. Show that $\log_2(n!)\ge\frac{n}{2}\log_2\frac{n}{2}$ (hint: keep the top $n/2$ factors).
5. You must deduplicate $10^{7}$ records. Compare sort-then-scan $O(n\log n)$ with a hash
   set $O(n)$ in time **and memory**.
6. For which $n$ does $100\,n\log_2 n$ beat $n^2$?

## Going further

- *Introduction to Algorithms* (CLRS), ch. 1-4. Sedgewick and Wayne, *Algorithms*, ch. 1.4.
- *Algorithm Design* (Kleinberg, Tardos) for NP-completeness. `bigocheatsheet.com`.
- Python's wiki page "TimeComplexity".
