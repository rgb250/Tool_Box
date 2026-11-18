# Life of a web request

> **Capstone.** One line of Python crosses every layer of this folder. This note
> follows it from the keyboard to the response, with a time budget in milliseconds,
> and links each step to the note that explains it. Hardware ([1](1_hardware/cpu_and_memory.md)),
> code ([2](2_from_code_to_execution/how_a_computer_understands_code.md)), operating
> system ([3](3_operating_systems/system_calls.md)), network ([4](4_networking/layers_osi_tcpip.md)),
> APIs ([5](5_apis_and_web_services/what_is_an_api.md)). For the dates behind each layer see the
> [timeline](timeline.md).

## The scenario

```python
import requests
r = requests.get(
    "https://api.example.com/users/42",
    headers={"Authorization": "Bearer eyJ..."},
    timeout=5,
)
print(r.json()["name"])        # Ada
```

Assumptions for the numbers below: the client is in Paris on Wi-Fi/fibre, the API
runs in a US-East datacenter, **RTT $=80$ ms** to it (the physical floor is about
$2\times 5900\text{ km}/2\times10^{5}\text{ km/s}\approx 59$ ms), the response is about 1 KB.

## Overview

```text
 Python process (user mode)                                  api.example.com
 ┌──────────────┐                                      ┌─────────────────────────┐
 │ requests     │ 1 DNS   ───► resolver ──► root/TLD/authoritative              │
 │ urllib3      │ 2 TCP   ───────────── SYN / SYN-ACK / ACK ────────►│ load      │
 │ ssl          │ 3 TLS   ───────────── handshake (certificate) ────►│ balancer  │
 │ socket       │ 4 HTTP  ───────────── GET /users/42 ──────────────►│ ──► app   │
 └──────┬───────┘                                       │ auth, limit, DB, JSON   │
        │ system calls                                  └──────────┬──────────────┘
 ┌──────▼───────┐ 5 response ◄──── 200 OK + JSON ─────────────────┘
 │ kernel: TCP/IP, routing, NIC driver │
 └─────────────────────────────────────┘
```

Formally the total latency is

$$T = T_{\text{DNS}} + k\cdot\text{RTT} + T_{\text{server}} + T_{\text{transfer}}$$

where $k$ counts the round trips before the answer arrives ($k=3$ on a cold
connection: TCP, TLS 1.3, request; $k=1$ on a reused one). With a 1 KB response,
$T_{\text{transfer}}\approx 1\text{ KB}/100\text{ Mbit/s}<0.1$ ms: negligible.

## Step by step

### 0. Inside the process (about 0.1 ms)

`requests.get` is Python code, compiled to bytecode and executed by the CPython
interpreter, itself a compiled C program
([interpreters](2_from_code_to_execution/how_a_computer_understands_code.md#4-interpreters-and-bytecode-python)).
`requests` builds a request object and delegates to `urllib3`, then to `socket`
and `ssl`, which wrap C library calls and finally
[system calls](3_operating_systems/system_calls.md#system-calls). Every Python
object lives in the process's heap, in
[virtual memory](3_operating_systems/virtual_memory.md); the CPU
[fetches, decodes, executes](1_hardware/cpu_and_memory.md#fetch-decode-execute-cycle)
the interpreter's machine code all along. The CPU work is microseconds: the rest of
this note is waiting.

### 1. Resolve the name (about 30 ms cold, 0-5 ms cached)

The URL is parsed into scheme `https`, host `api.example.com`, port 443 (default),
path `/users/42` ([URL anatomy](4_networking/http.md#url)). To connect, the program needs
an IP: `getaddrinfo` checks `/etc/hosts` and the OS cache, then sends a **UDP** query to the
configured recursive resolver. On a cache miss, the resolver
[walks the tree](4_networking/dns.md#resolution): root $\to$ `.com` $\to$ authoritative server.
Result: `api.example.com. A 203.0.113.10` with a TTL.

### 2. Open the TCP connection (1 RTT $=80$ ms)

`socket()` and `connect()` are system calls: the kernel allocates a
[socket](4_networking/sockets.md) (a file descriptor), picks an **ephemeral port**
(say 51234), and sends a `SYN`. The connection is identified by the
[5-tuple](4_networking/tcp_and_udp.md#role-of-the-transport-layer)
$(\text{TCP}, \text{client ip}, 51234, 203.0.113.10, 443)$. Its path:

- The kernel looks up the route by [longest prefix](4_networking/ip_and_routing.md#routing);
  the destination is not local, so it goes to the **default gateway**, whose MAC address
  it knows from ARP.
- Your home router applies [NAT](4_networking/ip_and_routing.md#nat) (private $\to$ public address
  and port).
- Packets hop through ISP routers, each forwarding by prefix and decrementing the TTL, across
  autonomous systems chosen by BGP, then the Atlantic cable.
- `SYN-ACK` returns; the client answers `ACK`. The
  [handshake](4_networking/tcp_and_udp.md#handshake) costs one full round trip.

### 3. Secure it (1 RTT $=80$ ms, plus about 1-2 ms of CPU)

`ssl` runs the [TLS 1.3 handshake](4_networking/tls.md#the-tls-13-handshake): the
`ClientHello` carries the hostname (SNI) and a Diffie-Hellman share; the server
replies with its share, its **certificate chain** and a signature. The client
verifies the chain against the OS's trusted roots, checks name and expiry, and
both sides derive $k=\text{KDF}(g^{ab}, \text{transcript})$. Everything afterwards is
encrypted and authenticated. The cryptography is a few milliseconds of CPU; the 80 ms
is again the round trip.

### 4. Send the HTTP request (the request half of 1 RTT)

`urllib3` writes the [HTTP text](4_networking/http.md#anatomy-of-a-message-http11-text):

```http
GET /users/42 HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJ...
Accept: application/json
```

(or binary frames if HTTP/2 is negotiated). TLS encrypts it into a record, `send()`
passes it to the kernel, which
[encapsulates](4_networking/layers_osi_tcpip.md#encapsulation) it: TCP segment $\to$ IP
packet $\to$ Ethernet/Wi-Fi frame, and the NIC driver transmits. About 300 bytes fit in one
packet, and TCP's initial window of 10 segments ([slow
start](4_networking/tcp_and_udp.md#congestion-control)) is far from limiting.

### 5. The server side (about 10 ms, in the budget below)

1. **Edge and load balancer.** The packet reaches a [reverse
   proxy](4_networking/cdn_and_load_balancers.md#reverse-proxy), which may terminate
   TLS, check its cache, and choose a backend with a
   [balancing algorithm](4_networking/cdn_and_load_balancers.md#algorithms)
   (least connections, health-checked).
2. **Application server.** Its process is blocked in `epoll`
   ([event loop](4_networking/sockets.md#serving-many-clients)); the kernel wakes it,
   the [scheduler](3_operating_systems/scheduling.md) gives it a CPU, `accept` / `recv`
   delivers the bytes. The framework parses the request and routes it to the handler
   for `GET /users/{id}` ([REST](5_apis_and_web_services/rest.md)).
3. **Authentication and limits.** Verify the JWT signature, `exp` and scopes
   ([JWT](5_apis_and_web_services/authentication.md#tokens-and-jwt)); check that this
   caller may read user 42 (object-level authorization); consult the
   [token bucket](5_apis_and_web_services/rate_limiting_and_pagination.md#algorithms)
   in Redis (about 0.5 ms). Failure here means `401`, `403` or `429`.
4. **Business logic and database.** A SQL query on an indexed key: the database reads
   pages through the [page cache](3_operating_systems/file_systems.md#page-cache)
   (RAM hit $\approx$ 100 ns) or from the SSD on a miss (about 100 µs), over its own
   TCP or Unix socket. About 2-5 ms including the network hop inside the datacenter (0.5 ms).
5. **Serialization.** The row becomes JSON
   ([serialization](5_apis_and_web_services/what_is_an_api.md#serialization-data-on-the-wire)):
   `{"id":42,"name":"Ada"}` with status `200 OK`.

### 6. The response returns (the other half of the RTT)

The same path in reverse: TLS record $\to$ TCP segments $\to$ IP $\to$ frames. The
client's kernel acknowledges them, reassembles the byte stream in order, wakes the blocked
Python thread (the `recv` returns, see [processes](3_operating_systems/processes_and_threads.md)),
and `ssl` decrypts. `urllib3` parses the status line and headers, `requests` builds a
`Response`, and `r.json()` runs `json.loads`, creating Python objects on the heap.
`print` ends with a `write(1, ...)` system call to your terminal.

### 7. Afterwards

The connection stays open in the `Session` pool (HTTP **keep-alive**) for later
requests, or is closed with `FIN` and lingers in `TIME_WAIT`
([teardown](4_networking/tcp_and_udp.md#handshake)). Caches may keep the answer
according to `Cache-Control`.

## Time budget

| Step | Cold | Warm `Session` | Edge, cold, uncached | Edge cache hit |
|------|-----:|---------------:|---------------------:|---------------:|
| DNS | 30 | 0 | 30 | 30 |
| TCP handshake | 80 | 0 | 10 | 10 |
| TLS 1.3 handshake | 80 | 0 | 10 | 10 |
| Request $\to$ response (network) | 80 | 80 | 90 | 10 |
| Server work | 10 | 10 | 10 | 0 |
| **Total (ms)** | **280** | **90** | **150** | **60** |

Columns:

- **Cold**: first call, straight to the origin (RTT 80 ms).
- **Warm**: second call on the same `requests.Session()`: connection and TLS reused.
- **Edge, cold, uncached**: a [CDN](4_networking/cdn_and_load_balancers.md#cdn-a-distributed-cache)
  node 10 ms away terminates TCP and TLS, and forwards over an already open connection to
  the origin ($10+80=90$ ms).
- **Edge cache hit**: the CDN answers itself.

What the table shows:

- Network round trips dominate: in the cold case $3\times80=240$ of 280 ms (86 %).
  CPU work (Python, TLS crypto, parsing) is a few milliseconds at most, which is why
  the [latency hierarchy](1_hardware/cpu_and_memory.md#the-memory-hierarchy) ends with
  "the Internet is another $1000\times$ slower".
- Every optimization removes a round trip or shortens it:

| Optimization | Mechanism | Saves (from cold 280 ms) |
|--------------|-----------|---------------------------|
| Reuse connection (`Session`, keep-alive) | skip TCP and TLS | $-190$ ms (DNS, TCP, TLS) |
| CDN / edge termination | shorter RTT for handshakes | $-130$ ms |
| Edge cache | no origin trip | $-220$ ms |
| HTTP/3 (QUIC) | transport and crypto in one handshake | $-80$ ms |
| Cache DNS locally | skip resolution | $-30$ ms |
| TLS 1.2 instead of 1.3 (worse) | 2 handshake RTTs | $+80$ ms |

## Why each layer exists

| Layer | Problem it solves | Chapter |
|-------|-------------------|---------|
| Transistors, CPU, memory | execute instructions on data | [1](1_hardware/cpu_and_memory.md) |
| Compiler, interpreter | humans write `requests.get`, the CPU runs machine code | [2](2_from_code_to_execution/how_a_computer_understands_code.md) |
| Kernel: processes, syscalls, virtual memory, files | share hardware safely, expose sockets as file descriptors | [3](3_operating_systems/system_calls.md) |
| IP, routing, NAT, BGP | find a path across independent networks | [4](4_networking/ip_and_routing.md) |
| TCP | turn lossy packets into a reliable ordered stream | [4](4_networking/tcp_and_udp.md) |
| DNS | names instead of numbers | [4](4_networking/dns.md) |
| TLS | confidentiality, integrity, server identity | [4](4_networking/tls.md) |
| HTTP, REST, JSON | a common vocabulary for requesting and describing resources | [4](4_networking/http.md), [5](5_apis_and_web_services/rest.md) |
| Auth, rate limits | who may call, and how often | [5](5_apis_and_web_services/authentication.md) |
| CDN, load balancers | latency (physics) and capacity | [4](4_networking/cdn_and_load_balancers.md) |

Each layer sees the one above as data and the one below as a service:
$A_{k+1}=f(A_k)$, the pattern from the [timeline](timeline.md#apis).

## Debugging: find the layer

The error message tells you which layer failed:

| Symptom | Layer | First tool |
|---------|-------|------------|
| `Name or service not known` | DNS | `dig api.example.com` |
| Hangs on connect, then timeout | routing, firewall, packet loss | `ping`, `traceroute`, `nc -vz host 443` |
| `Connection refused` | nothing listens on that port | `ss -ltnp` (on the server) |
| `CERTIFICATE_VERIFY_FAILED` | TLS: chain, name or expiry | `openssl s_client -connect host:443 -servername host` |
| `401` / `403` | authentication / authorization | check token, scope, expiry |
| `404`, `422` | API contract | read the spec, check URL and body |
| `429` | rate limit | honour `Retry-After`, back off |
| `502` / `503` / `504` | proxy or backend down or slow | load balancer health, server logs |
| `ReadTimeout` | server too slow after connecting | trace server work, DB |
| Slow but fine | find the slow phase | `curl -w` timings below |

```bash
curl -s -o /dev/null https://api.example.com/users/42 -w \
 'dns %{time_namelookup}  tcp %{time_connect}  tls %{time_appconnect}  first-byte %{time_starttransfer}  total %{time_total}\n'
```

The values are **cumulative** (seconds since the start): subtract successive ones to
get each phase and compare with the table above.

## Things to remember

- A web request $=$ DNS $+$ TCP $+$ TLS $+$ HTTP $+$ server work: $T = T_{\text{DNS}}+k\,\text{RTT}+T_{\text{server}}$.
- Cold: $k=3$ round trips; reuse brings it to $1$. Distance sets the floor
  ($\text{RTT}\ge2D/s$); CDNs and connection reuse are the levers.
- Everything on your machine is system calls, sockets and virtual memory; everything between machines is packets that
  are routed, acknowledged, encrypted and cached.
- When it fails, locate the layer first, then use that layer's tool.

## Exercises

1. Run the `curl -w` command on three sites (one nearby, one far, one behind a CDN) and
   fill a table like the one above with your real numbers.
2. `strace -f -e trace=network,connect,sendto,recvfrom,write python3 -c "import requests; requests.get('https://example.com')" 2>&1 | head -60`:
   find `socket`, `connect`, the DNS `sendto` and the TLS records.
3. Time 20 calls with `requests.get` and 20 with a `Session`; compare the means with the
   $280$ vs $90$ ms prediction (scaled to your RTT).
4. `sudo tcpdump -nn -i any host example.com` during one `curl`; label each packet:
   SYN, ClientHello, request, response, FIN.
5. Write your own mini HTTP client with raw `socket` and `ssl` (see
   [sockets](4_networking/sockets.md#everything-above-is-https-foundation)), then add a
   timer around each phase.

## Going further

- *High Performance Browser Networking* (Grigorik), a book-length version of this note.
- "What happens when you type google.com into your browser" (a classic interview question).
- Kurose and Ross, *Computer Networking*; Bryant and O'Hallaron, *CS:APP*, ch. 11.
