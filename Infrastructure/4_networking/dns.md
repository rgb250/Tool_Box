# DNS: the Internet's phone book

> **History:** until 1983 a single file, `HOSTS.TXT`, mapped every name to an
> address and was copied around. **DNS** (Mockapetris, 1983) replaced it with a
> distributed hierarchical database. DNSSEC (signatures) came in the 2000s and
> encrypted DNS (DoH, DoT) in the late 2010s. See the
> [timeline](../timeline.md#networking). Previous: [TCP and UDP](tcp_and_udp.md).
> Next: [TLS](tls.md).

## Purpose

Machines route by IP address; humans use names. DNS is a global, distributed
**partial function**:

$$\text{DNS} : (\text{name}, \text{type}) \rightharpoonup \text{set of records}$$

e.g. $(\texttt{www.example.com}, A)\mapsto\{93.184.216.34\}$. It is queried before almost every connection.

## Hierarchy

Names read right to left along a tree; each dot is a level, and each level is
managed by a different party (delegation):

```text
                  .  (root, 13 server identities, hundreds of anycast instances)
        ┌─────────┼─────────┐
       com       org       fr            top-level domains (TLD)
        |
     example                             second level (registered by you)
        |
       www                               subdomain, defined in your zone
```

`www.example.com.` $=$ host `www` in the zone `example.com`, in TLD `com`, in the root.
A **zone** is the part of the tree one authoritative server answers for.

## Resolution

Your program calls `getaddrinfo("www.example.com")`. The OS asks a **recursive
resolver** (your ISP's, or `1.1.1.1`, `8.8.8.8`; set in `/etc/resolv.conf`),
which walks the tree:

```text
 app -> stub resolver (OS) -> recursive resolver
                                  |-- root server:        "ask the .com servers"
                                  |-- .com TLD server:    "ask ns1.example.com"
                                  |-- authoritative ns:   "www = 93.184.216.34"
                              <---+ answer cached, returned to the app
```

- **Iterative** from the resolver's point of view (follow referrals); **recursive**
  from the client's (it asks once, gets the final answer).
- Transport: mostly **UDP port 53** (one packet each way), TCP for large answers,
  DoT/DoH for encryption.

### Caching and TTL

Every record has a **TTL** (seconds). Caches (OS, browser, resolver) keep an answer
until it expires. If the cache hit rate is $h$:

$$\mathbb{E}[\text{lookup time}] = h\, t_{\text{cache}} + (1-h)\, t_{\text{full}}$$

With $t_{\text{cache}}\approx 0.1$ ms, $t_{\text{full}}\approx 100$ ms and $h=95\%$:
$\approx 5.1$ ms. Trade-off: a long TTL means fewer queries and less latency, but changes
propagate slowly (why you lower the TTL before a migration).

## Record types

| Type | Maps | Example |
|------|------|---------|
| `A` | name $\to$ IPv4 | `example.com. A 93.184.216.34` |
| `AAAA` | name $\to$ IPv6 | |
| `CNAME` | alias $\to$ canonical name | `www CNAME example.com.` |
| `NS` | zone $\to$ its name servers | |
| `MX` | domain $\to$ mail servers | |
| `TXT` | arbitrary text | SPF, domain verification |
| `PTR` | IP $\to$ name (reverse lookup) | |

## Tools

```bash
dig example.com A +short
dig example.com +trace          # watch the walk from the root
dig @1.1.1.1 example.com MX     # query a specific resolver
resolvectl status ; cat /etc/resolv.conf
cat /etc/hosts                  # local overrides, checked before DNS
```

## Beyond lookup

- **Load balancing and CDNs** answer with different IPs depending on the
  client's location or server load (see [CDN](cdn_and_load_balancers.md)).
- **Security**: classic DNS is unauthenticated, so it can be spoofed (cache
  poisoning). **DNSSEC** signs records; **DoH/DoT** encrypt queries.
- DNS outages look like "the Internet is down" because every connection starts here.

## Things to remember

- DNS maps $(\text{name},\text{type})$ to records via a delegated hierarchy
  (root, TLD, zone).
- A resolver walks the tree once, then **caches** according to TTL.
- It usually uses UDP port 53; check with `dig +trace`.

## Exercises

1. `dig +trace github.com`; list the servers contacted in order.
2. `dig example.com` twice; watch the TTL decrease in the second answer.
3. `dig -x 8.8.8.8` (reverse lookup).
4. Python: `socket.getaddrinfo("example.com", 443)`; why do you get several results?

## Going further

- RFC 1034/1035 (DNS). Kurose and Ross, ch. 2.4.
