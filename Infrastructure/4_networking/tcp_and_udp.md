# Transport: TCP and UDP

> **History:** TCP (1974-81, RFC 793) gave reliable streams; UDP (1980, RFC 768)
> kept datagrams simple. After the 1986 "congestion collapse", **Van Jacobson**
> added congestion control (1988). QUIC (Google 2012, standard RFC 9000 in 2021)
> rebuilds TCP's features on UDP. See the [timeline](../timeline.md#networking).
> Previous: [IP and routing](ip_and_routing.md). Next: [DNS](dns.md).

## Role of the transport layer

IP delivers packets **host to host**, unreliably. The transport layer delivers
data **process to process** using **ports** (16-bit, $0$-$65535$). A connection
is identified by a 5-tuple:

$$(\text{protocol},\; \text{src ip},\; \text{src port},\; \text{dst ip},\; \text{dst port})$$

A server listens on a well-known port (80 HTTP, 443 HTTPS, 22 SSH, 53 DNS); the client
gets a random **ephemeral** port. That is how one server port serves thousands of clients.

## UDP

A header of 8 bytes: ports, length, checksum. That is all: no connection, no
retransmission, no ordering. Each `sendto` is one independent datagram.

Use when low latency matters more than perfection, or when the application
handles loss itself: DNS, video calls, games, QUIC.

## TCP

A **reliable, ordered, byte stream** over unreliable IP. Mechanisms:

| Problem | Mechanism |
|---------|-----------|
| Connection setup | 3-way handshake |
| Loss | sequence numbers, ACKs, retransmission on timeout or 3 duplicate ACKs |
| Reordering, duplicates | sequence numbers, receiver buffer |
| Corruption | checksum |
| Slow receiver | flow control (receive window) |
| Congested network | congestion control (congestion window) |

### Handshake

```text
 Client                         Server
   | ---- SYN, seq=x -------->  |
   | <--- SYN+ACK, seq=y, ack=x+1 |
   | ---- ACK, ack=y+1 ------>  |   (data can flow; client may send with this ACK)
```

Cost: **1 RTT** before the client can send data. Closing uses `FIN`/`ACK`
in each direction; the side that closes first stays in `TIME_WAIT` (about 60 s) to
absorb late packets.

### Reliable delivery

The sender numbers each byte. The receiver replies with a cumulative
$\text{ACK}(n)$: "I have everything up to byte $n-1$". If an ACK does not arrive
within the **retransmission timeout**, the segment is sent again. The timeout
adapts to measured RTT: $\text{RTO}\approx \text{SRTT}+4\,\text{RTTVAR}$.

### Window and throughput

The sender may have at most $W$ unacknowledged bytes in flight, with
$W=\min(\text{rwnd},\text{cwnd})$ (receiver's advertised window, congestion window). Sending $W$ bytes
per round trip gives

$$\text{throughput} \le \frac{W}{\text{RTT}}$$

Example: $W=64$ KiB, RTT $=100$ ms: $\frac{65536\times 8}{0.1}\approx 5.2$ Mbit/s, whatever the
link speed. To fill a 1 Gbit/s $\times$ 50 ms link, $W$ must reach the
[BDP](layers_osi_tcpip.md#delay-where-time-goes) of 6.25 MB (hence **window scaling**).

### Congestion control

A sender cannot see the network but can infer congestion from losses or delay.
Classic scheme (Reno), with $\text{cwnd}$ in segments:

1. **Slow start**: $\text{cwnd}$ starts small (10 segments today) and **doubles
   each RTT** (exponential) until a threshold or a loss.
2. **Congestion avoidance**: $\text{cwnd}\mathrel{+}=1$ per RTT (additive increase).
3. On loss: $\text{cwnd}\leftarrow\text{cwnd}/2$ (multiplicative decrease).

This **AIMD** rule makes competing flows converge to a fair share. The steady-state
throughput of a long flow with loss probability $p$ follows the Mathis formula:

$$\text{throughput}\approx \frac{\text{MSS}}{\text{RTT}}\cdot\frac{1.22}{\sqrt{p}}$$

Example: MSS $=1460$ B, RTT $=50$ ms, $p=10^{-4}$: $\approx 28$ Mbit/s. Longer RTT or more losses
mean less throughput, independent of the link capacity. Modern variants: CUBIC
(Linux default), BBR (models bandwidth and RTT).

Practical effect: a new connection starts slow, so **short transfers are
latency-bound, not bandwidth-bound**. Reusing connections matters.

### Head-of-line blocking

TCP delivers bytes in order: one lost segment blocks everything behind it, even
unrelated data multiplexed in the stream. QUIC fixes this with independent streams.

## TCP vs UDP

| | TCP | UDP |
|---|-----|-----|
| Connection | yes | no |
| Reliability, order | yes | no |
| Boundaries | byte stream (no message boundaries) | datagrams |
| Overhead | 20+ B header, handshake | 8 B header |
| Typical use | web, SSH, email, databases | DNS, streaming, games, QUIC |

## Tools

```bash
ss -tan                     # TCP sockets and their states
ss -tin dst example.com     # cwnd, rtt, retransmissions
nc -v example.com 80        # open a raw TCP connection
iperf3 -c server            # measure throughput
```

## Things to remember

- A connection is a 5-tuple; ports select the process.
- TCP: handshake (1 RTT), ACKs and retransmission, flow and congestion control.
- $\text{throughput}\le W/\text{RTT}$; $\text{BDP}=R\cdot\text{RTT}$; AIMD shares the link fairly.
- New connections ramp up slowly (slow start).

## Exercises

1. `ss -tan | awk '{print $1}' | sort | uniq -c`: count the states.
2. `sudo tcpdump -nn 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0'` during `curl`; spot the handshake.
3. Compute the max throughput for $W=256$ KiB and RTT $=20$ ms.
4. Echo server over UDP vs TCP in Python (see [sockets](sockets.md)); drop packets with `tc netem`.

## Going further

- Kurose and Ross, ch. 3. RFC 9293 (TCP), Jacobson's "Congestion Avoidance and Control" (1988).
