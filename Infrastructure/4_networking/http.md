# HTTP: the language of the Web

> **History:** Berners-Lee invented the Web at CERN (1989-91): URL, HTML, HTTP.
> HTTP/1.0 (1996) opened one connection per request; **HTTP/1.1** (1997) added persistent
> connections; **HTTP/2** (2015) multiplexes requests; **HTTP/3** (2022) runs over
> QUIC. See the [timeline](../timeline.md#networking). Previous: [TLS](tls.md).
> Next: [sockets](sockets.md).

## Model

HTTP is a **request-response** application protocol over a reliable transport. It
is **stateless**: each request is self-contained, the server keeps no memory
between two requests (state is added with cookies, tokens).

$$\text{server} : \text{Request} \to \text{Response}$$

## URL

```text
 https://user@www.example.com:443/path/page?q=tls&lang=fr#section
 \___/   \__/ \_____________/ \_/ \_________/ \__________/ \_____/
scheme  userinfo     host     port   path        query     fragment
```

The **fragment** never leaves the browser. The host is resolved by
[DNS](dns.md), the scheme chooses [TLS](tls.md) or not, the port defaults from the scheme.

## Anatomy of a message (HTTP/1.1, text)

Request:

```http
GET /users/42?fields=name HTTP/1.1
Host: api.example.com
Accept: application/json
Authorization: Bearer <token>
User-Agent: curl/8.5.0

```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 27
Cache-Control: max-age=60

{"id":42,"name":"Ada"}
```

Structure: **start line**, **headers** (`Name: value`), blank line, optional **body**.

### Methods

| Method | Meaning | Safe (no change) | Idempotent |
|--------|---------|------|-----------|
| `GET` | read a resource | yes | yes |
| `HEAD` | headers only | yes | yes |
| `POST` | create / submit | no | no |
| `PUT` | replace a resource | no | yes |
| `PATCH` | partial update | no | no |
| `DELETE` | remove | no | yes |

*Idempotent*: $f(f(x)) = f(x)$; repeating the request has the same effect as doing
it once (which is why a client can safely retry a `PUT` after a timeout).

### Status codes

| Class | Meaning | Examples |
|-------|---------|----------|
| `1xx` | informational | `101 Switching Protocols` |
| `2xx` | success | `200 OK`, `201 Created`, `204 No Content` |
| `3xx` | redirection | `301 Moved Permanently`, `302 Found`, `304 Not Modified` |
| `4xx` | client error | `400`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `429 Too Many Requests` |
| `5xx` | server error | `500`, `502 Bad Gateway`, `503 Unavailable`, `504 Gateway Timeout` |

### Useful headers

`Host` (which site, needed for virtual hosting), `Content-Type` /
`Accept` (formats), `Authorization`, `Cookie` / `Set-Cookie` (sessions),
`Cache-Control`, `ETag`, `Location` (redirect target), `User-Agent`.

## Caching

- `Cache-Control: max-age=60`: reuse the response for 60 s without asking.
- `ETag: "abc"` then the client sends `If-None-Match: "abc"`; if unchanged,
  server answers `304 Not Modified` with no body (saves bandwidth).

Caches exist in the browser, proxies and [CDNs](cdn_and_load_balancers.md).

## Latency of a request

Cost of fetching one object on a fresh connection, in round trips:

$$T \approx \underbrace{\text{DNS}}_{\ge 1\text{ RTT}} + \underbrace{1}_{\text{TCP}} + \underbrace{1}_{\text{TLS 1.3}} + \underbrace{1}_{\text{request}} + \frac{\text{size}}{\text{BW}}\ \text{(plus slow start)}$$

With RTT $=50$ ms that is about $4\times 50=200$ ms before the transfer.
Everything in HTTP's evolution reduces round trips:

| Version | Idea | Effect |
|---------|------|--------|
| 1.0 | one TCP connection per request | $\approx 2$ RTT (+TLS) per object |
| 1.1 | **keep-alive**: reuse the connection, pipelining (rarely used) | handshake paid once; but head-of-line blocking, so browsers open about 6 connections per host |
| 2 | binary framing, **multiplexed streams** on one connection, header compression | many parallel requests; still TCP head-of-line blocking |
| 3 | over **QUIC** (UDP): TLS built in, independent streams, 0/1-RTT setup | no TCP head-of-line blocking, faster handshakes, survives IP change |

The application semantics (methods, headers, status codes) are the same across versions.

## State on top of stateless HTTP

- **Cookies**: server sends `Set-Cookie: sid=abc; HttpOnly; Secure`; the browser
  returns `Cookie: sid=abc` on each request; the server maps `sid` to a session.
- **Tokens** (JWT, bearer tokens) in the `Authorization` header, popular for APIs.
- **CORS**: browsers restrict cross-origin requests from scripts; servers opt in
  with `Access-Control-Allow-Origin` headers.

## Tools

```bash
curl -v https://example.com                # request and response headers
curl -sI https://example.com               # only response headers
curl -X POST -H 'Content-Type: application/json' -d '{"a":1}' https://httpbin.org/post
curl --http2 -I https://example.com ; curl --http3 -I https://cloudflare.com
```

## Things to remember

- Request $\to$ response; stateless; text (1.1) or binary framing (2, 3).
- Methods and status codes carry the semantics; idempotence enables safe retries.
- Latency is dominated by round trips: DNS $+$ TCP $+$ TLS $+$ request.
- HTTP/1.1 $\to$ 2 $\to$ 3 is the story of removing round trips and blocking.

## Exercises

1. `curl -v` a site; count the steps (DNS, TCP, TLS, request) in the output.
2. Use `nc example.com 80` and type `GET / HTTP/1.1`, `Host: example.com`, blank line.
3. `curl -w '%{time_namelookup} %{time_connect} %{time_appconnect} %{time_total}\n' -o /dev/null -s https://example.com`.
4. Which status code does a missing page return? A wrong password? A rate limit?

## Going further

- MDN "HTTP" guide. RFC 9110 (semantics), 9112 (HTTP/1.1), 9113 (HTTP/2), 9114 (HTTP/3).
- The [API chapter](../5_apis_and_web_services/) builds on these semantics (REST).
