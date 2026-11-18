# Rate limiting, retries and pagination

> **History:** public APIs (Twitter, Google Maps, 2006-2010) quickly met abusive or
> accidental overload and introduced quotas; token bucket (1980s networking) was
> adapted to HTTP; cursor-based pagination became standard with large feeds
> (Twitter, Facebook, 2010s); `429` was standardized in 2012 (RFC 6585). See the
> [timeline](../timeline.md#apis). Previous: [GraphQL and gRPC](graphql_and_grpc.md).
> Next: [webhooks](webhooks.md).

## Rate limiting

A server has finite capacity ([Little's law](../3_operating_systems/scheduling.md#littles-law-a-useful-bridge-to-servers):
$\lambda_{\max}=L_{\max}/W$). **Rate limiting** caps how many requests a client
(API key, user, IP) may send, to protect the service, share it fairly, and stop abuse
or runaway loops. Over the limit the server returns `429 Too Many Requests`, ideally with:

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 30
RateLimit-Limit: 100
RateLimit-Remaining: 0
RateLimit-Reset: 30
```

### Algorithms

Let $r$ be the allowed rate (requests/s) and $B$ the burst size.

| Algorithm | Idea | Property |
|-----------|------|----------|
| **Fixed window** | counter per interval (100 / minute), reset at each boundary | simple, but up to $2\times$ the limit at a boundary (100 at 12:00:59, 100 at 12:01:00) |
| **Sliding window** | count requests over the last $T$ seconds | smooth, more memory |
| **Token bucket** | bucket of capacity $B$ refilled at rate $r$; a request costs 1 token | allows bursts, enforces average rate |
| **Leaky bucket** | requests enter a queue drained at constant rate $r$ | smooths traffic to a fixed output |
| **Concurrency limit** | at most $L$ requests in flight | protects against slow requests |

**Token bucket** state: $(\text{tokens}, t_{\text{last}})$. On a request at time $t$:

$$\text{tokens}\leftarrow\min\big(B,\ \text{tokens}+r\,(t-t_{\text{last}})\big),\qquad
\text{allow iff tokens}\ge 1\ \Rightarrow\ \text{tokens}\mathrel{-}=1$$

The maximum number of requests accepted in any window of length $T$ is
$B + rT$. Example: $r=10$/s, $B=20$: 20 requests instantly, then 10 per second.

```python
import time
class TokenBucket:
    def __init__(self, rate, burst):
        self.rate, self.burst = rate, burst
        self.tokens, self.t = burst, time.monotonic()
    def allow(self):
        now = time.monotonic()
        self.tokens = min(self.burst, self.tokens + self.rate * (now - self.t))
        self.t = now
        if self.tokens >= 1:
            self.tokens -= 1
            return True
        return False
```

In production the counters live in a shared store (Redis, with atomic
increments and expiry), or at the gateway/[load balancer](../4_networking/cdn_and_load_balancers.md)
so that all servers agree.

## Client-side: retries with backoff

Clients must handle `429`, `503` and timeouts. Retrying immediately makes the
overload worse and synchronizes clients (**thundering herd**). Use **exponential
backoff with jitter**:

$$t_n = \text{random}\big(0,\ \min(t_{\max},\ t_0\cdot 2^{n})\big)$$

for the $n$-th retry: waits like up to 1 s, 2 s, 4 s, 8 s... capped, randomized so
clients spread out. Rules:

- Honour `Retry-After` when present.
- Retry only **idempotent** operations or those with an
  [idempotency key](rest.md#idempotency-and-retries); retry only transient errors
  (`429`, `502`, `503`, `504`, network timeouts), never `400` or `404`.
- Limit attempts and set an overall deadline.

```python
import random, time, requests
def get_with_retry(url, tries=5):
    for n in range(tries):
        r = requests.get(url, timeout=5)
        if r.status_code not in (429, 502, 503, 504):
            return r
        wait = float(r.headers.get("Retry-After", random.uniform(0, min(30, 2**n))))
        time.sleep(wait)
    r.raise_for_status()
```

## Pagination

A collection of $N$ items cannot be returned at once (memory, latency, bandwidth).
The server returns a **page** and a way to get the next one.

### Offset / limit

```text
GET /items?limit=20&offset=40        -> items 40..59
```

```sql
SELECT * FROM items ORDER BY id LIMIT 20 OFFSET 40;
```

Simple, supports jumping to page $k$, but:

- **Cost grows with the offset**: the database must skip `offset` rows, so
  $O(\text{offset}+\text{limit})$. `OFFSET 1000000` scans a million rows.
- **Inconsistency**: if a row is inserted or deleted while paging, items shift and
  you see duplicates or miss some.

### Cursor (keyset) pagination

The cursor identifies the **last item seen**; the next page is "items after it":

```text
GET /items?limit=20&after=eyJpZCI6IDU5fQ==      (opaque cursor = encoded last id)
```

```sql
SELECT * FROM items WHERE id > :last_id ORDER BY id LIMIT 20;
```

With an index on `id` this is $O(\log N + \text{limit})$ whatever the depth, and
stable under insertions. The cursor should be **opaque** to clients (the server may
change its content) and the sort key must be unique (add a tiebreaker such as
`(created_at, id)`). Drawback: no random access to "page 500".

| | Offset | Cursor |
|---|--------|--------|
| Cost at depth | grows linearly | constant |
| Stable under writes | no | yes |
| Jump to page $k$ | yes | no |
| Use | small admin tables | feeds, large or live data |

### Response shape

```json
{
  "data": [ ... 20 items ... ],
  "next_cursor": "eyJpZCI6IDc5fQ==",
  "has_more": true
}
```

or via headers: `Link: <https://api.example.com/items?after=...>; rel="next"`.
Clients loop until `has_more` is false, while respecting the rate limit.

## Things to remember

- Token bucket: $\text{tokens}\leftarrow\min(B, \text{tokens}+r\Delta t)$, at most $B+rT$
  requests per window $T$.
- Respond `429` with `Retry-After`; clients use exponential backoff **with jitter**
  and retry only safe operations.
- Prefer cursor pagination for large or changing collections: $O(\log N)$ instead of $O(\text{offset})$.

## Exercises

1. Run the token bucket above, hit it 50 times in a loop, then sleep and retry; plot
   accepted vs time.
2. Show the fixed-window double burst with a simulated counter.
3. In SQLite insert 1M rows; time `OFFSET 900000 LIMIT 20` vs `WHERE id > 900000 LIMIT 20`.
4. Page through the GitHub API (`per_page=100`, `Link` header) and read
   `X-RateLimit-Remaining`.

## Going further

- Stripe and GitHub API docs on rate limits and pagination; RFC 6585, IETF RateLimit headers draft.
- AWS Architecture Blog: "Exponential Backoff and Jitter".
