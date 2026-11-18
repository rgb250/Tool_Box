# Infrastructure

Mental models of how a computer, its software, the Internet and APIs work, from
transistors up to a JSON response. Each chapter builds on the previous one.

The guiding question of the whole folder: **what really happens when I run
`requests.get("https://api.example.com/users")`?**

See [`timeline.md`](timeline.md) for a one-page history of each layer, linked to the notes.

## Roadmap

| # | Folder | Question answered | Status |
|---|--------|-------------------|--------|
| 1 | `1_hardware/` | What is a computer physically made of and how does it execute code? | [`cpu_and_memory.md`](1_hardware/cpu_and_memory.md) written |
| 2 | `2_from_code_to_execution/` | How does a computer understand code and commands (compiling, interpreting, shell), and how does its cost grow? | [`how_a_computer_understands_code.md`](2_from_code_to_execution/how_a_computer_understands_code.md), [`complexity.md`](2_from_code_to_execution/complexity.md) written |
| 3 | `3_operating_systems/` | How do processes, memory, files and system calls work? | [`system_calls`](3_operating_systems/system_calls.md), [`processes_and_threads`](3_operating_systems/processes_and_threads.md), [`scheduling`](3_operating_systems/scheduling.md), [`virtual_memory`](3_operating_systems/virtual_memory.md), [`file_systems`](3_operating_systems/file_systems.md) written |
| 4 | `4_networking/` | How do two machines talk (IP, TCP, DNS, TLS, HTTP)? | [`layers_osi_tcpip`](4_networking/layers_osi_tcpip.md), [`ip_and_routing`](4_networking/ip_and_routing.md), [`tcp_and_udp`](4_networking/tcp_and_udp.md), [`dns`](4_networking/dns.md), [`tls`](4_networking/tls.md), [`http`](4_networking/http.md), [`sockets`](4_networking/sockets.md), [`cdn_and_load_balancers`](4_networking/cdn_and_load_balancers.md) written |
| 5 | `5_apis_and_web_services/` | How do programs expose and consume services (REST, auth, gRPC)? | [`what_is_an_api`](5_apis_and_web_services/what_is_an_api.md), [`rest`](5_apis_and_web_services/rest.md), [`authentication`](5_apis_and_web_services/authentication.md), [`graphql_and_grpc`](5_apis_and_web_services/graphql_and_grpc.md), [`rate_limiting_and_pagination`](5_apis_and_web_services/rate_limiting_and_pagination.md), [`webhooks`](5_apis_and_web_services/webhooks.md) written |

## Planned notes

1. **Hardware**: `cpu_and_memory`, `storage`, `gpu_and_accelerators`, `buses_and_io`, `boot_process`
2. **From code to execution**: `how_a_computer_understands_code` and `complexity` (done), `python_execution_model`, `build_systems_and_packages` (todo)
3. **Operating systems** (done): `system_calls`, `processes_and_threads`, `scheduling`, `virtual_memory`, `file_systems`
4. **Networking** (done): `layers_osi_tcpip`, `ip_and_routing`, `tcp_and_udp`, `dns`, `tls`, `http`, `sockets`, `cdn_and_load_balancers`
5. **APIs** (done): `what_is_an_api`, `rest`, `authentication` (API keys, OAuth2, JWT), `graphql_and_grpc`, `rate_limiting_and_pagination`, `webhooks` (HTTP methods and status codes are in `4_networking/http.md`)
6. **Capstone** (done): [`life_of_a_web_request.md`](life_of_a_web_request.md), tracing one request through every layer with a time budget.

## Related notes in this repository

- `Computer/notes.md`: memory, addresses and types
- `Linux/`: shell, Ubuntu, file system hierarchy
- `Virtualization/docker/`: containers
