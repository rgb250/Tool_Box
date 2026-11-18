# Timeline

Each layer was invented to hide the complexity of the one below. Reading the dates
in order shows *why* each concept exists. The last column links to the note that
explains the concept (*italic* = planned note, not written yet).

Notes: [CPU](1_hardware/cpu_and_memory.md) ·
[Code to execution](2_from_code_to_execution/how_a_computer_understands_code.md) ·
[Complexity](2_from_code_to_execution/complexity.md) ·
[System calls](3_operating_systems/system_calls.md) ·
[Processes](3_operating_systems/processes_and_threads.md) ·
[Scheduling](3_operating_systems/scheduling.md) ·
[Virtual memory](3_operating_systems/virtual_memory.md) ·
[File systems](3_operating_systems/file_systems.md) ·
[Layers](4_networking/layers_osi_tcpip.md) ·
[IP](4_networking/ip_and_routing.md) ·
[TCP/UDP](4_networking/tcp_and_udp.md) ·
[DNS](4_networking/dns.md) ·
[TLS](4_networking/tls.md) ·
[HTTP](4_networking/http.md) ·
[Sockets](4_networking/sockets.md) ·
[CDN and load balancers](4_networking/cdn_and_load_balancers.md) ·
[What is an API](5_apis_and_web_services/what_is_an_api.md) ·
[REST](5_apis_and_web_services/rest.md) ·
[Authentication](5_apis_and_web_services/authentication.md) ·
[GraphQL and gRPC](5_apis_and_web_services/graphql_and_grpc.md) ·
[Rate limiting and pagination](5_apis_and_web_services/rate_limiting_and_pagination.md) ·
[Webhooks](5_apis_and_web_services/webhooks.md) ·
[Capstone: life of a web request](life_of_a_web_request.md)

## Hardware

| Year | Event | Problem it solved | Note |
|------|-------|-------------------|------|
| 1936 | Turing machine | What is computable? | [state machine](1_hardware/cpu_and_memory.md#formal-model) |
| 1945 | von Neumann architecture (program and data in the same memory) | Reprogram without rewiring | [memory as a function](1_hardware/cpu_and_memory.md#formal-model) |
| 1947 | Transistor (Bell Labs) | Replace fragile, hot vacuum tubes | [CPU](1_hardware/cpu_and_memory.md#the-cpu) |
| 1958 | Integrated circuit | Put many transistors on one chip | [CPU](1_hardware/cpu_and_memory.md#the-cpu) |
| 1965 | Moore's law (transistor count doubles about every 2 years) | Exponential growth, now slowing | [why CPUs are fast](1_hardware/cpu_and_memory.md#why-modern-cpus-are-fast) |
| 1971 | Intel 4004, first microprocessor | CPU on a single chip | [fetch-decode-execute](1_hardware/cpu_and_memory.md#fetch-decode-execute-cycle) |
| 1978 | x86 (Intel 8086) | Still the PC/server ISA today | [ISA](1_hardware/cpu_and_memory.md#fetch-decode-execute-cycle), [machine code](2_from_code_to_execution/how_a_computer_understands_code.md#1-what-machine-code-looks-like) |
| 1985 | ARM1 | Low-power RISC, now phones and Apple M-series | [ISA](1_hardware/cpu_and_memory.md#fetch-decode-execute-cycle) |
| 2005 | Multicore mainstream | Clock speed hit the power wall | [execution time](1_hardware/cpu_and_memory.md#execution-time), [threads and Amdahl](3_operating_systems/processes_and_threads.md#threads) |
| 2007 | CUDA | GPUs usable for general computation (deep learning) | *gpu_and_accelerators* |

## Theory and cryptography

| Year | Event | Problem it solved | Note |
|------|-------|-------------------|------|
| 1965 | Hartmanis and Stearns: computational complexity | Measure the time and memory cost of computation | [complexity](2_from_code_to_execution/complexity.md) |
| 1971 | Cook: NP-completeness, the P vs NP question | Which problems are intractable? | [tractable vs intractable](2_from_code_to_execution/complexity.md#tractable-vs-intractable) |
| 1976 | Diffie-Hellman key exchange; Knuth popularizes big-O | Share a secret in public; compare algorithms | [DH](4_networking/tls.md#diffie-hellman-key-exchange), [asymptotic notation](2_from_code_to_execution/complexity.md#asymptotic-notation) |
| 1977 | RSA | Public-key encryption and signatures | [TLS](4_networking/tls.md#building-blocks) |
| 1996 | Ariane 5: integer overflow | Lesson: fixed-width arithmetic wraps | [overflow](1_hardware/cpu_and_memory.md#integers-and-overflow) |
| 1998 | DES broken in 56 h (EFF Deep Crack) | Showed 56-bit keys are too short | [key sizes](4_networking/tls.md#key-sizes-and-brute-force) |

## Languages

| Year | Event | Problem it solved | Note |
|------|-------|-------------------|------|
| 1957 | FORTRAN, first widely used compiler | Write math, not machine code | [compilation pipeline](2_from_code_to_execution/how_a_computer_understands_code.md#2-the-compilation-pipeline-c-as-the-reference) |
| 1972 | C (Ritchie) | Portable systems language, Unix rewritten in it | [compilation pipeline](2_from_code_to_execution/how_a_computer_understands_code.md#2-the-compilation-pipeline-c-as-the-reference) |
| 1991 | Python | Readable, interpreted, productive | [interpreters and bytecode](2_from_code_to_execution/how_a_computer_understands_code.md#4-interpreters-and-bytecode-python) |
| 1995 | Java (JVM, JIT), JavaScript | Write once run anywhere, code in the browser | [JIT](2_from_code_to_execution/how_a_computer_understands_code.md#4-interpreters-and-bytecode-python) |
| 2009-15 | Go (2009), Rust 1.0 (2015) | Concurrency, memory safety without GC | [compilation pipeline](2_from_code_to_execution/how_a_computer_understands_code.md#2-the-compilation-pipeline-c-as-the-reference) |

## Operating systems

| Year | Event | Problem it solved | Note |
|------|-------|-------------------|------|
| 1962 | Atlas: virtual memory and paging | Programs larger than RAM, isolation | [virtual memory](3_operating_systems/virtual_memory.md) |
| 1969 | Unix (Thompson, Ritchie) | Simple, portable, everything is a file | [loader](2_from_code_to_execution/how_a_computer_understands_code.md#3-running-a-program-the-loader), [system calls](3_operating_systems/system_calls.md), [everything is a file](3_operating_systems/file_systems.md#everything-is-a-file) |
| 1978 | Bourne shell; Bash in 1989 | Scripting and composing programs with pipes | [shell commands](2_from_code_to_execution/how_a_computer_understands_code.md#5-how-a-shell-command-is-understood), [file descriptors](3_operating_systems/system_calls.md#file-descriptors) |
| 1991 | Linux (Torvalds) | Free Unix-like kernel | [processes](3_operating_systems/processes_and_threads.md), [scheduling](3_operating_systems/scheduling.md), [file systems](3_operating_systems/file_systems.md) |
| 2013 | Docker | Package and isolate apps with kernel features | [namespaces and cgroups](3_operating_systems/processes_and_threads.md#isolation-namespaces-and-cgroups), `Virtualization/docker/notes.md` |

## Networking

| Year | Event | Problem it solved | Note |
|------|-------|-------------------|------|
| 1969 | ARPANET | Connect distant computers (packet switching) | [layers](4_networking/layers_osi_tcpip.md), [delay and BDP](4_networking/layers_osi_tcpip.md#delay-where-time-goes) |
| 1974-83 | TCP/IP (Cerf, Kahn), adopted by ARPANET in 1983 | Interconnect different networks: the Internet | [IP and routing](4_networking/ip_and_routing.md), [TCP and UDP](4_networking/tcp_and_udp.md) |
| 1983 | BSD sockets (4.2BSD) | Use the network through file descriptors | [sockets](4_networking/sockets.md) |
| 1988 | TCP congestion control (Jacobson) | Escape the 1986 congestion collapse | [congestion control](4_networking/tcp_and_udp.md#congestion-control) |
| 1983 | DNS (Mockapetris) | Names instead of numeric addresses | [DNS](4_networking/dns.md) |
| 1989-91 | World Wide Web: HTTP, HTML, URL (Berners-Lee) | Share linked documents | [HTTP](4_networking/http.md) |
| 1995 | SSL (Netscape), later TLS | Encrypted, authenticated connections | [TLS](4_networking/tls.md) |
| 1997 | HTTP/1.1 | Persistent connections | [HTTP versions](4_networking/http.md#latency-of-a-request) |
| 2015 / 2022 | HTTP/2, HTTP/3 (over QUIC/UDP) | Multiplexing, lower latency | [HTTP versions](4_networking/http.md#latency-of-a-request), [QUIC](4_networking/tcp_and_udp.md#head-of-line-blocking) |
| 1998 | Akamai, first major CDN | Content near users, absorb load | [CDN](4_networking/cdn_and_load_balancers.md) |
| 1999-2004 | C10K problem, epoll (2002), nginx (2004) | Serve $10^4$+ connections per machine | [event loops](4_networking/sockets.md#serving-many-clients) |

## APIs

| Year | Event | Problem it solved | Note |
|------|-------|-------------------|------|
| 1984 | Sun RPC | Call a function on another machine | [what is an API](5_apis_and_web_services/what_is_an_api.md), [RPC](5_apis_and_web_services/graphql_and_grpc.md) |
| 1998-2000 | XML-RPC, SOAP | Standardised, verbose web services | [API styles](5_apis_and_web_services/what_is_an_api.md#choosing-a-style) |
| 2001 | JSON (Crockford), RFC 8259 in 2017 | Light text format replacing XML | [serialization](5_apis_and_web_services/what_is_an_api.md#serialization-data-on-the-wire) |
| 2000 | REST (Fielding's thesis) | Use HTTP itself as the API model | [REST](5_apis_and_web_services/rest.md) |
| 2006 | AWS | Infrastructure as an API | [REST](5_apis_and_web_services/rest.md), [rate limiting](5_apis_and_web_services/rate_limiting_and_pagination.md) |
| 2007 | Webhooks (term coined by Lindsay) | Push events instead of polling | [webhooks](5_apis_and_web_services/webhooks.md) |
| 2012 | OAuth 2.0 (RFC 6749) | Delegated authorisation without sharing passwords | [OAuth 2.0](5_apis_and_web_services/authentication.md#oauth-20-delegated-authorization) |
| 2015 | GraphQL (public), gRPC (open source) | Flexible queries, fast typed RPC | [GraphQL and gRPC](5_apis_and_web_services/graphql_and_grpc.md), [JWT and PKCE](5_apis_and_web_services/authentication.md#tokens-and-jwt) |

**Pattern to remember:** hardware $\to$ language/compiler $\to$ OS $\to$ network
$\to$ web $\to$ APIs. Each step adds an abstraction layer $A_{k+1}=f(A_k)$ so
that the user of layer $k+1$ ignores the details of layer $k$.
