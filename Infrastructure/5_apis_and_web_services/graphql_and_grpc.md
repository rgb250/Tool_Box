# GraphQL and gRPC

> **History:** **RPC** (call a remote function as if it were local) dates from Sun
> RPC (1984), then CORBA and SOAP (1998-2000), judged heavy. Google used
> **Protocol Buffers** internally from about 2001 (open-sourced 2008) and its RPC system
> **Stubby**, which became **gRPC** (open source 2015). Facebook created
> **GraphQL** for its mobile apps (2012, public 2015) to fix over- and under-fetching.
> See the [timeline](../timeline.md#apis). Previous: [authentication](authentication.md).
> Next: [rate limiting and pagination](rate_limiting_and_pagination.md).

## Two answers to the limits of REST

[REST](rest.md#strengths-and-limits) is resource-oriented and text-based. Two
alternatives optimize different things:

| | REST | **gRPC** | **GraphQL** |
|---|------|----------|-------------|
| Model | resources + methods | remote procedures | a typed graph, queried by the client |
| Transport | HTTP/1.1+ | **HTTP/2** | HTTP (usually one `POST /graphql`) |
| Payload | JSON | **Protobuf** (binary) | JSON |
| Contract | OpenAPI (optional) | `.proto` (mandatory) | schema (mandatory) |
| Strength | simple, cacheable | speed, streaming, code generation | the client picks exactly the fields |
| Typical use | public APIs | service to service | front-end/mobile to backend |

## gRPC

You define the service and messages in a `.proto` file; the compiler generates
**client stubs and server skeletons** in many languages, so a remote call looks like a
local function:

```proto
syntax = "proto3";

service UserService {
  rpc GetUser (GetUserRequest) returns (User);            // unary
  rpc ListUsers (ListRequest) returns (stream User);      // server streaming
}
message GetUserRequest { int64 id = 1; }
message User { int64 id = 1; string name = 2; string email = 3; }
```

```python
# generated code: stub.GetUser(GetUserRequest(id=42)) -> User(...)
```

The numbers (`= 1`, `= 2`) are **field tags** identifying fields on the wire,
which allows evolving the schema safely: add new tags, never reuse or renumber old ones.

### Protocol Buffers

Binary encoding: each field is `(tag, wire type)` then its value. Integers are
**varints**: 7 bits per byte, least significant group first, the high bit says "more
bytes follow".

Example: `message M { int32 a = 1; }` with `a = 150`:

- key $=(\text{field}\ll3)\,|\,\text{wire type}=(1\ll3)|0=\texttt{0x08}$;
- $150=\underbrace{0000001}_{}\,\underbrace{0010110}_{}$ in 7-bit groups, so bytes
  $\texttt{0x96}$ (continuation bit set, low group) and $\texttt{0x01}$.

The message is `08 96 01`: **3 bytes**, versus 9 for the JSON `{"a":150}` (no field names are
sent). Small and fast to parse, but not human-readable.

### Why it is fast

- **HTTP/2**: one TCP connection, many multiplexed streams
  ([HTTP versions](../4_networking/http.md#latency-of-a-request)).
- Compact binary messages, generated parsers.
- **Four call types**: unary, server streaming, client streaming, bidirectional
  streaming (chat, telemetry).
- Built-in **deadlines** (timeouts propagated across services), cancellation,
  metadata (headers), and status codes (`OK`, `NOT_FOUND`, `UNAVAILABLE`...).

Limits: browsers cannot call it natively (need gRPC-Web), harder to debug by hand
(`grpcurl`), no free HTTP caching.

## GraphQL

A single endpoint and a **schema** describing types and relations; the client sends a
**query** shaped like the response it wants:

```graphql
query {
  user(id: 42) {
    name
    posts(first: 3) { title }
  }
}
```

```json
{ "data": { "user": { "name": "Ada", "posts": [ {"title": "A"}, {"title": "B"} ] } } }
```

The response mirrors the query: exactly the requested fields.

Operation kinds: **query** (read), **mutation** (write), **subscription** (push
updates over WebSocket).

### Over-fetching and under-fetching, quantified

Screen needing a user's name and 3 post titles:

| | Requests | Data |
|---|----------|------|
| REST | $1+1=2$ (`/users/42`, `/users/42/posts`) in sequence, so $\ge 2$ RTT | full user and post objects |
| GraphQL | $1$ | only the 4 fields |

Latency $\approx k\cdot\text{RTT}+\text{size}/\text{BW}$ for $k$ dependent requests
([HTTP latency](../4_networking/http.md#latency-of-a-request)); on mobile networks
(RTT $\sim 100$ ms) cutting $k$ and size matters.

### Resolvers and the N+1 problem

The server resolves each field with a **resolver** function. Naively, listing
$n$ users with their posts runs 1 query for the users plus $n$ queries for the posts:

$$\text{queries} = 1 + n \quad(\text{N+1})$$

The fix is **batching** (e.g. DataLoader: collect the $n$ ids and run one
`WHERE user_id IN (...)`): $1+1=2$ queries.

### Trade-offs

- Pros: one round trip, no versioning (add fields, deprecate old ones), strong typing,
  introspection and auto-generated docs.
- Cons: HTTP caching is hard (everything is `POST` to one URL), **query cost
  control** is needed (a client can ask for a huge nested graph: limit depth and
  complexity), authorization per field, more server complexity.

## Which to choose

- Public, simple, cache-friendly API $\to$ **REST**.
- Internal microservices, low latency, streaming $\to$ **gRPC**.
- Many clients with different data needs (web, iOS, Android) $\to$ **GraphQL**.
- They coexist: GraphQL gateway in front, gRPC between services, REST for partners.

## Things to remember

- gRPC $=$ Protobuf $+$ HTTP/2 $+$ generated stubs; 4 streaming modes; compact
  (varint: 150 $\to$ `96 01`).
- GraphQL $=$ one endpoint, client-shaped queries; fixes over/under-fetching;
  beware the N+1 problem and expensive queries.
- Field tags (Protobuf) and additive schema changes (GraphQL) make evolution safe.

## Exercises

1. Write a `.proto`, generate Python code with `python -m grpc_tools.protoc`, and implement
   a unary call.
2. Encode `{"a":150}` with JSON and with `protobuf` in Python; compare byte lengths.
3. Query the public GraphQL API at `https://countries.trevorblades.com/` with `curl`.
4. Reproduce an N+1 with SQLite (loop of queries) and fix it with a single `IN` query; time both.

## Going further

- grpc.io documentation; *Production Ready GraphQL* (Marc-André Giroux); graphql.org learn.
