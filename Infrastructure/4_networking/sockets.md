# Sockets: programming the network

> **History:** the **Berkeley sockets API** (4.2BSD, 1983) gave programs a way
> to use TCP/IP through ordinary file descriptors; it is still the interface of every
> OS and language. The **C10K problem** (1999) pushed event-driven servers
> (`epoll` in Linux 2.6, 2002; nginx 2004; Node.js 2009). See the
> [timeline](../timeline.md#networking). Previous: [HTTP](http.md).
> Next: [CDNs and load balancers](cdn_and_load_balancers.md).

## A socket is a file descriptor

A **socket** is the kernel object behind one endpoint of a connection. It is
referenced by a [file descriptor](../3_operating_systems/system_calls.md#file-descriptors),
so `read`, `write` and `close` work on it, and the kernel handles the TCP state,
buffers and retransmissions ([TCP](tcp_and_udp.md)).

```text
 your code     socket(), connect(), send(), recv()      <- system calls
 kernel        TCP state machine, send/recv buffers, routing
 NIC driver    frames out/in
```

## The TCP server/client protocol

| Step | Server | Client |
|------|--------|--------|
| 1 | `socket()` create | `socket()` create |
| 2 | `bind(addr, port)` claim a local port | |
| 3 | `listen(backlog)` mark it passive | |
| 4 | `accept()` blocks, returns a **new** socket per client | `connect(addr, port)` handshake |
| 5 | `recv` / `send` | `send` / `recv` |
| 6 | `close` | `close` |

The listening socket and each accepted socket are different objects: one server port
serves many clients, distinguished by the [5-tuple](tcp_and_udp.md#role-of-the-transport-layer).

```python
# server.py
import socket
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:   # IPv4, TCP
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 9000))
    s.listen()
    conn, addr = s.accept()
    with conn:
        data = conn.recv(1024)
        conn.sendall(data.upper())

# client.py
import socket
with socket.create_connection(("127.0.0.1", 9000)) as c:
    c.sendall(b"hello")
    print(c.recv(1024))      # b'HELLO'
```

Important details:

- TCP is a **byte stream**: one `send` of 100 bytes may arrive as two `recv`s
  (50 + 50), and two `send`s may merge. Protocols must delimit messages
  (length prefix, newline, HTTP `Content-Length`).
- `recv` may return fewer bytes than requested; `sendall` loops until done.
- `SOCK_DGRAM` is UDP: `sendto`/`recvfrom`, message boundaries preserved.
- A hostname is resolved with [DNS](dns.md) first (`getaddrinfo`).
- Binding `127.0.0.1` accepts local clients only; `0.0.0.0` accepts all interfaces.
- **Unix domain sockets** (`AF_UNIX`, a path as address) are the local,
  faster variant used by Docker, databases, Nginx.

## Serving many clients

`accept` and `recv` **block** the thread until something happens. Strategies:

| Model | Idea | Limit |
|-------|------|-------|
| One client at a time | simplest | one slow client blocks all |
| **Thread / process per connection** | each blocks independently | memory (stacks) and [context switches](../3_operating_systems/scheduling.md#context-switch-overhead); thousands max |
| **Event loop** (non-blocking + `epoll`/`kqueue`) | one thread watches many sockets, handles those that are ready | scales to $10^5$+ connections; code must never block |

The kernel interface for waiting on many descriptors:

$$\text{poll} : \{fd_1,\dots,fd_n\} \to \{fd_i \mid fd_i \text{ ready}\}$$

`select` and `poll` cost $O(n)$ per call; **`epoll`** (Linux) returns only the
ready ones, $O(\text{ready})$. Python's `asyncio`, Node.js, nginx, and Go's runtime
all build on it, with `async/await` hiding the callbacks.

```python
import asyncio
async def handle(reader, writer):
    data = await reader.read(1024)       # yields to the loop while waiting
    writer.write(data.upper()); await writer.drain(); writer.close()

async def main():
    server = await asyncio.start_server(handle, "127.0.0.1", 9000)
    async with server: await server.serve_forever()
asyncio.run(main())
```

### How many connections?

[Little's law](../3_operating_systems/scheduling.md#littles-law-a-useful-bridge-to-servers)
$L=\lambda W$: a server receiving $\lambda=10\,000$ req/s with $W=100$ ms latency holds
$L=1000$ requests in flight. Each costs a descriptor plus kernel buffers, so
limits (`ulimit -n`, memory, ephemeral ports $\approx 28\,000$ per
client-IP/server-IP/port triple) are real constraints.

## Everything above is HTTP's foundation

A web server is a socket server that parses the text of
[HTTP](http.md) from `recv` and writes a response; `requests.get(url)` in Python:
resolve DNS, `socket()`, `connect()`, TLS handshake, `send` the request text,
`recv` the response. Try it by hand:

```python
import socket, ssl
ctx = ssl.create_default_context()
with socket.create_connection(("example.com", 443)) as raw:
    with ctx.wrap_socket(raw, server_hostname="example.com") as s:
        s.sendall(b"GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n")
        print(s.recv(300).decode())
```

## Tools

```bash
ss -ltnp                 # listening sockets and their processes
lsof -i :9000            # who uses this port
nc -l 9000               # a quick listening server;  nc localhost 9000 to connect
strace -e trace=network python3 client.py
```

## Things to remember

- A socket is an fd; the server uses `bind`, `listen`, `accept`, the client `connect`.
- TCP is a stream: you must frame messages and loop over partial reads/writes.
- Scale with an event loop on `epoll` instead of a thread per connection.
- $L=\lambda W$ gives the number of simultaneous connections.

## Exercises

1. Run the Python server and client, and watch with `ss -tan` and `strace`.
2. Send `"ab"` then `"cd"` quickly; does the server `recv` once or twice?
3. Open the 443 example by hand (above) and read the HTTP response.
4. Write a UDP echo server with `SOCK_DGRAM`.
5. With `asyncio`, serve 1000 concurrent clients; check `ls /proc/<pid>/fd | wc -l`.

## Going further

- *Beej's Guide to Network Programming* (free). `man 7 socket`, `man 7 epoll`.
- Kegel, "The C10K problem".
