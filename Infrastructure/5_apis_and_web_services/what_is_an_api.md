# What is an API?

> **History:** subroutine libraries (1950s) $\to$ system calls (Unix, 1969) $\to$
> remote procedure calls (Sun RPC, 1984) $\to$ web services (SOAP, 1998-2000)
> $\to$ REST over HTTP and JSON (2000s) $\to$ cloud APIs (AWS, 2006) $\to$ GraphQL
> and gRPC (2015). See the [timeline](../timeline.md#apis). Previous chapter:
> [networking](../4_networking/http.md). Next: [REST](rest.md).

## Definition

An **API** (application programming interface) is a **contract** that lets one
program use another without knowing its internals. Formally, an API exposes a set of
operations, each with a signature and a promise:

$$\text{op} : A \to B \cup \{\text{error}\}, \qquad \text{pre}(a) \Rightarrow \text{post}(\text{op}(a))$$

The caller must respect the preconditions and may rely on the postconditions;
everything else is hidden (**abstraction**), so the provider can change its
implementation freely.

APIs exist at every layer you have seen in this folder:

| Level | Example | Called through |
|-------|---------|----------------|
| Hardware/OS | [system calls](../3_operating_systems/system_calls.md) (`open`, `read`) | `syscall` instruction |
| Library | `numpy.dot`, `pandas.read_csv` | function call in the same process |
| Process to process, same machine | Unix socket, D-Bus | [sockets](../4_networking/sockets.md) |
| **Web API** | `GET https://api.github.com/users/octocat` | [HTTP](../4_networking/http.md) over the network |

This chapter concerns **web APIs**: a server exposes operations over HTTP, a client
(script, mobile app, another service) calls them.

## The anatomy of a web API call

What `requests.get("https://api.example.com/users/42")` does (each step is a
chapter of this folder):

1. DNS resolves `api.example.com` ([DNS](../4_networking/dns.md)).
2. TCP and TLS handshakes ([TCP](../4_networking/tcp_and_udp.md), [TLS](../4_networking/tls.md)).
3. An HTTP request is sent ([HTTP](../4_networking/http.md)); a [load balancer](../4_networking/cdn_and_load_balancers.md)
   routes it to an application server.
4. The server checks **who you are** ([authentication](authentication.md)) and
   **whether you may** do it, applies [rate limits](rate_limiting_and_pagination.md),
   executes the logic, queries a database.
5. It **serializes** the result (JSON) and answers with a status code.

## Serialization: data on the wire

Memory structures hold pointers and machine-specific layouts, so they cannot be sent
as is. **Serialization** converts an object to bytes (and **deserialization**
back): $\text{decode}(\text{encode}(x)) = x$.

| Format | Kind | Notes |
|--------|------|-------|
| **JSON** | text | universal, human-readable, no comments, no binary type, numbers are doubles |
| XML | text | older, verbose, schemas and namespaces |
| **Protocol Buffers** | binary | compact, fast, needs a schema (see [gRPC](graphql_and_grpc.md#protocol-buffers)) |
| MessagePack, Avro, CBOR | binary | JSON-like or schema-based |
| CSV, Parquet | tabular | bulk data |

```python
import json
s = json.dumps({"id": 42, "name": "Ada", "tags": ["a", "b"]})   # object -> text
obj = json.loads(s)                                              # text -> object
```

Trade-off: text formats are debuggable (`curl` shows everything), binary formats are
$3$-$10\times$ smaller and faster to parse.

## Choosing a style

| Style | Idea | Strength | Chapter note |
|-------|------|----------|--------------|
| **REST** | resources identified by URLs, manipulated with HTTP methods | simple, cacheable, ubiquitous | [rest](rest.md) |
| **RPC / gRPC** | call remote functions with typed messages | fast, typed, streaming, service to service | [graphql_and_grpc](graphql_and_grpc.md) |
| **GraphQL** | client describes the exact data shape in one query | no over/under-fetching | [graphql_and_grpc](graphql_and_grpc.md) |
| **Webhooks** | server calls *you* when an event occurs | no polling | [webhooks](webhooks.md) |
| WebSocket / SSE | long-lived connection, server push | real-time | [webhooks](webhooks.md#related-push-mechanisms) |

## Qualities of a good API

- **Consistent**: same naming, error format and conventions everywhere.
- **Documented with a machine-readable spec**: **OpenAPI** (formerly Swagger) describes
  paths, parameters and schemas in YAML/JSON; tools generate docs, clients and
  validation. gRPC uses `.proto` files, GraphQL its schema.
- **Versioned**: breaking changes go to `/v2/...` (or a header) so old clients
  keep working. Adding optional fields is backward-compatible; removing or renaming one is not.
- **Secure and bounded**: authentication, authorization, input validation, rate
  limits.
- **Idempotent where possible** so clients can safely retry (see [REST](rest.md#idempotency-and-retries)).
- **Observable**: request ids, logs, metrics.

## Things to remember

- An API is a contract $\text{pre}\Rightarrow\text{post}$ hiding the implementation.
- A web API call is the whole networking stack plus authentication, logic and serialization.
- Pick the style by use case: REST (default), gRPC (internal, fast), GraphQL
  (flexible clients), webhooks (events).

## Exercises

1. `curl -s https://api.github.com/users/octocat | python3 -m json.tool`; identify
   the fields. Repeat with `-i` for headers.
2. Compare the size of the JSON of a list of 1000 numbers and `struct.pack` of the same list.
3. Open an OpenAPI spec (e.g. `https://petstore3.swagger.io/api/v3/openapi.json`) and find one
   path, its parameters and responses.
4. List three breaking and three non-breaking changes for an API returning `{"name": ...}`.

## Going further

- *Designing Web APIs* (Jin, Sahni, Shevat). OpenAPI specification (`spec.openapis.org`).
