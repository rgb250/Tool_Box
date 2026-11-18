# CDNs, proxies and load balancers

> **History:** the 1990s web "world wide wait" led to **Akamai** (1998), the first
> big CDN; hardware load balancers (F5, 1990s) then software ones (nginx 2004,
> HAProxy 2001) and cloud ones (AWS ELB 2009); consistent hashing (Karger et al.,
> 1997) enabled elastic caches. See the [timeline](../timeline.md#networking).
> Previous: [sockets](sockets.md). Next chapter: [APIs](../5_apis_and_web_services/).

## Why: latency and scale

Two physical limits:

1. **Distance**: RTT $\ge 2D/s$ ([layers](layers_osi_tcpip.md#delay-where-time-goes)),
   about 1 ms per 100 km round trip. Serving a French user from California costs
   $\ge 90$ ms per round trip (about 140 ms on real routes), several times that for a page.
2. **Capacity**: one machine handles a bounded request rate $\mu$. More traffic
   needs several machines.

Solutions: **move content near users** (CDN) and **spread requests over machines**
(load balancing).

## Reverse proxy

A **proxy** forwards requests on behalf of someone else. A **reverse proxy**
sits in front of servers and is what clients actually talk to (`nginx`, `Envoy`,
`HAProxy`, Cloudflare):

```text
 clients ──HTTPS──> [ reverse proxy ] ──HTTP──> app server 1
                     TLS termination            app server 2
                     routing, caching           app server 3
                     compression, rate limiting
```

It terminates [TLS](tls.md), hides internal servers, caches, compresses, routes by
path or host (`/api` to one service, `/` to another), and balances load.

## Load balancing

### Layers

| Type | Works on | Sees | Typical use |
|------|----------|------|-------------|
| **L4** | transport (IP+port) | TCP connections | fast, protocol-agnostic |
| **L7** | application (HTTP) | URL, headers, cookies | smart routing, TLS termination |

### Algorithms

Choose server $i$ among $n$ for each request:

- **Round robin**: $i = k \bmod n$ for the $k$-th request. Simple, even if requests
  are similar.
- **Least connections**: pick $\arg\min_i c_i$, with $c_i$ the active connections. Handles
  uneven request durations.
- **Weighted** versions for heterogeneous machines.
- **Hash-based** ("sticky"): $i = h(\text{key}) \bmod n$ with key $=$ client IP,
  session cookie, or URL. Same client reaches the same server (useful for caches
  and sessions).

**Health checks** remove failed servers automatically (periodic probes, e.g. `GET /health`).

### Consistent hashing

With $i=h(\text{key})\bmod n$, adding one server changes $n\to n+1$ and about
$\frac{n}{n+1}$ of keys move (almost all), emptying caches. **Consistent hashing**
places servers and keys on a ring (hash space $[0,2^{32})$); each key belongs to the
next server clockwise. Adding or removing a server moves only about

$$\frac{1}{n+1}\ \text{of the keys}$$

(virtual nodes smooth the distribution). It underlies distributed caches, databases
(Cassandra, DynamoDB) and CDN request routing.

### Availability

If one server is up with probability $a$ and $n$ independent replicas are behind a
load balancer, the service is up unless all fail:

$$A = 1-(1-a)^{n}$$

Example: $a=0.99$: $n=1\to 99\%$, $n=2\to 99.99\%$, $n=3\to 99.9999\%$. In practice
failures are correlated (same rack, same bug, the balancer itself), so the real
figure is lower. Hence multi-zone and multi-region deployment.

### Capacity

By [Little's law](../3_operating_systems/scheduling.md#littles-law-a-useful-bridge-to-servers),
if each server handles at most $L_{\max}$ concurrent requests with latency $W$,
its throughput is $\lambda_{\max}=L_{\max}/W$, so $n$ servers sustain $n\lambda_{\max}$
(before the database or another shared resource becomes the bottleneck).

## CDN: a distributed cache

A **content delivery network** is thousands of caching reverse proxies
("edges", points of presence) around the world:

1. DNS or **anycast** routing sends the user to a nearby edge (many edges announce the
   same IP prefix via BGP, and routing picks the closest).
2. **Cache hit**: the edge answers directly. **Miss**: it fetches from the **origin**,
   stores the response (respecting `Cache-Control`, [HTTP caching](http.md#caching))
   and serves it.

Average latency with edge hit ratio $h$:

$$\bar t = h\,t_{\text{edge}} + (1-h)\,(t_{\text{edge}}+t_{\text{origin}})$$

Example: $t_{\text{edge}}=20$ ms, $t_{\text{origin}}=150$ ms, $h=90\%$: $\bar t=20+0.1\times150=35$ ms
(a miss costs 170 ms), and the origin sees only 10 % of the traffic.

Also: DDoS absorption, TLS termination close to users, image/video optimization,
edge compute. Best for static content (images, JS, video); dynamic and
personalized responses are harder to cache (key on URL + selected headers).

Invalidating a cache is hard: use versioned URLs (`app.3f9a1c.js`) or purge APIs.

## Putting it together

```text
 user -> DNS (nearest edge IP) -> CDN edge --miss--> load balancer -> app servers -> database
                                    | hit
                                    v
                                 response
```

## Things to remember

- Distance sets a latency floor; capacity needs replicas: CDN and load balancers answer these.
- L4 sees connections, L7 sees HTTP; reverse proxies terminate TLS.
- Consistent hashing moves $\approx 1/(n+1)$ of keys when scaling, versus $n/(n+1)$ for modulo.
- $A=1-(1-a)^n$ (optimistic); $\bar t = h\,t_{\text{edge}} + (1-h)(\dots)$.

## Exercises

1. `curl -sI https://example.com | grep -i 'server\|via\|cf-cache\|x-cache\|age'` to
   spot a CDN and its cache status.
2. `dig +short cloudflare.com` from different networks; compare to `traceroute`.
3. Configure nginx as a round-robin reverse proxy for two Python `http.server` instances.
4. Python: simulate consistent hashing with 5 servers, add a 6th and count moved keys.
5. Compute the availability of 3 replicas with $a=0.995$.

## Going further

- *Designing Data-Intensive Applications* (Kleppmann), ch. 5-6. nginx and HAProxy docs.
