# Layers: how networks are organized

> **History:** ARPANET (1969) pioneered **packet switching**; TCP/IP (designed
> 1974, adopted 1983) let different networks interconnect; the OSI model (1984)
> is the teaching reference, TCP/IP is what actually runs. See the
> [networking timeline](../timeline.md#networking). Previous chapter:
> [operating systems](../3_operating_systems/system_calls.md). Next:
> [IP and routing](ip_and_routing.md).

## The problem

Two programs on different machines must exchange bytes over a chain of unreliable
links (cables, Wi-Fi, routers) built by different vendors. The solution is
**layering**: each layer offers a service to the one above and uses the one below,
knowing nothing of the rest.

## The stack

| TCP/IP layer | OSI layers | Role | Examples | Unit |
|--------------|-----------|------|----------|------|
| Application | 5-7 | what programs say | HTTP, DNS, TLS, SSH, SMTP | message |
| Transport | 4 | process-to-process delivery | TCP, UDP, QUIC | segment / datagram |
| Internet | 3 | host-to-host across networks | IP, ICMP | packet |
| Link | 1-2 | one hop on one network | Ethernet, Wi-Fi, ARP | frame |

Each layer has its own **address**: MAC (link), IP (internet), port (transport),
name or URL (application).

## Encapsulation

Going down, each layer wraps the data from above with its own **header** $H$:

$$\text{frame} = H_{\text{eth}} \,\|\, H_{\text{IP}} \,\|\, H_{\text{TCP}} \,\|\, \underbrace{\text{HTTP data}}_{\text{payload}}$$

($\|$ = concatenation). Each router or switch reads only the headers of its own
layer, so routers do not parse TCP, and HTTP does not know about Wi-Fi.
Going up, headers are stripped (**decapsulation**).

Overhead example (Ethernet MTU 1500 B, IPv4 and TCP headers 20 B each): at most
$1500-40 = 1460$ B of application data per packet. On the wire, add Ethernet
header+FCS (18 B), preamble (8 B) and inter-frame gap (12 B):

$$\text{efficiency} = \frac{1460}{1500+38}\approx 94.9\%$$

## Delay: where time goes

The delay on one link is the sum of four terms:

$$d = d_{\text{proc}} + d_{\text{queue}} + \underbrace{\frac{L}{R}}_{\text{transmission}} + \underbrace{\frac{D}{s}}_{\text{propagation}}$$

with $L$ packet size (bits), $R$ link rate (bit/s), $D$ distance and
$s\approx 2\times10^{8}$ m/s the speed of light in fibre (about $\frac{2}{3}c$).

- Sending 1500 B ($12\,000$ bits) at 1 Gbit/s: $L/R = 12\,\mu s$.
- Paris-New York ($\approx 5800$ km): $D/s \approx 29$ ms one way, so the **round-trip
  time** (RTT) is at least $\approx 58$ ms. No protocol can beat physics; this is why
  [CDNs](cdn_and_load_balancers.md) exist.

The **bandwidth-delay product** is the amount of data "in flight" on a path:

$$\text{BDP} = R \times \text{RTT}$$

Example: 1 Gbit/s $\times$ 50 ms $=6.25$ MB. A sender must keep that much unacknowledged
data in flight to fill the pipe (see [TCP](tcp_and_udp.md#window-and-throughput)).

## Packet switching and the end-to-end principle

- **Circuit switching** (old telephone): reserve a path for the whole call.
- **Packet switching** (Internet): cut data into packets, each routed
  independently, links shared statistically. Efficient for bursty traffic, but packets may be
  delayed, lost, duplicated or reordered.
- **End-to-end principle** (Saltzer, Reed, Clark, 1984): keep the network core
  simple and "best effort"; put reliability and intelligence at the edges (TCP in
  the hosts). It explains the Internet's ability to grow.

## The link layer in brief

- **MAC address**: 48-bit hardware address, unique on the local network
  (`aa:bb:cc:dd:ee:ff`).
- A **switch** forwards frames between ports using MAC addresses; a **router**
  forwards packets between networks using IP addresses.
- **ARP** resolves "who has IP 192.168.1.1?" into a MAC address on the local network.

## Tools

```bash
ip addr; ip route          # interfaces, addresses, routing table
ping -c 3 example.com      # RTT through ICMP
traceroute example.com     # path, hop by hop
sudo tcpdump -i any -n port 80    # see raw packets (or Wireshark)
```

## Things to remember

- Four TCP/IP layers, each with its own address and header; data is encapsulated
  going down.
- $d = d_{\text{proc}}+d_{\text{queue}}+L/R+D/s$; $\text{BDP}=R\cdot\text{RTT}$.
- The core is best-effort; reliability is added at the edges.

## Exercises

1. `ping` a nearby and a far server; compare RTT to $2D/s$.
2. `sudo tcpdump -i any -nn -c 10` while loading a page; identify the layers.
3. `ip neigh` shows the ARP table; what is your gateway's MAC address?
4. Compute the time to send a 1 GB file at 100 Mbit/s: transmission vs a 100 ms RTT.

## Going further

- *Computer Networking: A Top-Down Approach* (Kurose, Ross), ch. 1.
- *High Performance Browser Networking* (Grigorik, free online).
