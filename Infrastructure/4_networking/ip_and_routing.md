# IP addressing and routing

> **History:** IPv4 (1981, RFC 791) with 32-bit addresses; classless CIDR (1993)
> and NAT (mid-1990s) delayed address exhaustion; IPv6 (1998 spec) has 128 bits;
> BGP (1989) glues the Internet's independent networks. See the
> [timeline](../timeline.md#networking). Previous:
> [layers](layers_osi_tcpip.md). Next: [TCP and UDP](tcp_and_udp.md).

## IP addresses

An IPv4 address is a 32-bit integer written as four bytes: `192.168.1.10`.
The space is $2^{32}\approx 4.3\times10^{9}$ addresses, fewer than people, hence
the problems below. IPv6 uses 128 bits: $2^{128}\approx3.4\times10^{38}$.

### Subnets and CIDR

An address is split into a **network prefix** and a **host part**. `a.b.c.d/n`
(CIDR notation) says the first $n$ bits are the network. The **mask** $m$ has $n$
ones followed by zeros, and:

$$x \in N/n \iff (x \,\&\, m) = N, \qquad \#\text{hosts} = 2^{32-n}-2$$

(the $-2$ removes the network address and the broadcast address).

| CIDR | Mask | Hosts |
|------|------|-------|
| `/8` | 255.0.0.0 | 16 777 214 |
| `/16` | 255.255.0.0 | 65 534 |
| `/24` | 255.255.255.0 | 254 |
| `/32` | one host | 1 |

Example: `192.168.1.77/24`; network $=192.168.1.0$, range $.1$-$.254$, broadcast $.255$.
Is `192.168.2.5` in it? $(192.168.2.5\,\&\,255.255.255.0)=192.168.2.0\neq192.168.1.0$: no.

### Special ranges

- **Private** (not routable on the Internet): `10.0.0.0/8`, `172.16.0.0/12`,
  `192.168.0.0/16`.
- **Loopback**: `127.0.0.1` (`localhost`), traffic never leaves the machine.
- `0.0.0.0` means "all interfaces" when binding a server.

### NAT

A home or company router has one public address and many private hosts. **NAT**
rewrites the source address and port of outgoing packets and remembers the mapping

$$(\text{ip}_{\text{priv}}, \text{port}_{\text{priv}}) \leftrightarrow (\text{ip}_{\text{pub}}, \text{port}_{\text{pub}})$$

to translate replies back. Consequence: hosts behind NAT are not directly
reachable from outside (hence port forwarding, and the push for IPv6).

### DHCP

A machine joining a network asks via **DHCP** for an address, mask, default
gateway and DNS server, and gets a time-limited lease.

## Routing

A **router** has several interfaces and a **routing table**: a list of
$(\text{prefix}, \text{next hop}, \text{interface})$. For a destination $x$ it
chooses the **longest matching prefix**:

$$\text{route}(x) = \arg\max_{(P/n)\,:\, x\in P/n} n$$

Example table:

| Prefix | Next hop |
|--------|----------|
| `10.0.0.0/8` | R1 |
| `10.1.0.0/16` | R2 |
| `0.0.0.0/0` (default route) | ISP |

A packet to `10.1.5.9` matches `/8` and `/16`: the `/16` wins (R2). To `8.8.8.8`: only the default route.

Each router decides **independently, hop by hop**; the packet header has a
**TTL** decremented at every hop and the packet is dropped at 0 (with an ICMP
message back), which prevents loops. `traceroute` exploits this by sending
packets with TTL $=1,2,3,\dots$ and collecting the replies.

### Routing between networks

The Internet is a graph of about $10^5$ **autonomous systems** (AS: ISPs, clouds,
universities), each identified by an AS number.

- Inside an AS: protocols like OSPF compute shortest paths on the graph
  (Dijkstra, minimizing a cost).
- Between ASes: **BGP** exchanges "I can reach prefix $P$ via this AS path"
  announcements, and picks routes by **policy** (commercial agreements), not just
  distance. A faulty BGP announcement can redirect or take down a part of the
  Internet.

## ICMP

IP's control protocol: `ping` (echo request/reply), "destination unreachable",
"time exceeded". Not a transport; it reports network conditions.

## Fragmentation and MTU

Each link has a **maximum transmission unit** (1500 B for Ethernet). An oversized IPv4 packet
is fragmented (IPv6 forbids it in routers); modern hosts use **path MTU
discovery** to size packets correctly. Mismatches cause "works for pings, hangs on large transfers".

## IPv6

128-bit addresses (`2001:db8::1`), no NAT needed, no header checksum, simpler
header, built-in autoconfiguration. Adoption is gradual (around half of users
reach big sites over IPv6); dual-stack hosts speak both.

## Things to remember

- $\#\text{hosts}=2^{32-n}-2$ for a `/n`; membership is a bitwise AND.
- Routers forward by longest-prefix match, hop by hop, with a TTL.
- NAT multiplexes private hosts behind one public address using ports.
- BGP routes by policy between autonomous systems.

## Exercises

1. `ip addr`, `ip route`: what is your default gateway and your subnet?
2. Python: `import ipaddress; ipaddress.ip_network('10.1.0.0/16').num_addresses`; test
   membership with `ip_address('10.1.5.9') in net`.
3. `traceroute -n 1.1.1.1`; how many hops? Are some private addresses?
4. `curl ifconfig.me` vs `ip addr`: why do they differ?
5. Split `192.168.10.0/24` into 4 equal subnets; give prefixes and host counts.

## Going further

- Kurose and Ross, ch. 4-5. RFC 791 (IP), RFC 4632 (CIDR), RFC 4271 (BGP).
