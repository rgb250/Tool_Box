# Webhooks and event delivery

> **History:** the term **webhook** was coined by Jeff Lindsay in 2007
> ("user-defined HTTP callbacks"). GitHub, Stripe, Slack and Twilio made them the
> standard way to push events to developers in the 2010s; WebSockets (2011) and
> Server-Sent Events handle browser push. See the [timeline](../timeline.md#apis).
> Previous: [rate limiting and pagination](rate_limiting_and_pagination.md).
> Next: the capstone, life of a web request.

## Polling vs pushing

You want to know when something happens on another system (a payment succeeds, a
commit is pushed). Two options:

- **Polling**: you repeatedly ask "anything new?" (`GET /events`).
- **Webhook**: you give the server a URL; **it** sends an HTTP `POST` to it when an
  event occurs (*"don't call us, we'll call you"*, the Hollywood principle).

Compare with a poll interval $T$ and an event rate $\lambda$ (events/day):

| | Polling | Webhook |
|---|---------|---------|
| Requests/day | $86400/T$ (constant) | $\lambda$ (only when needed) |
| Average added latency | $T/2$ | $\approx$ network latency (ms) |
| Useful fraction | $\approx\lambda T/86400$ | $\approx 1$ |

Example: poll every 10 s $\to$ 8640 requests/day and 5 s mean delay; with 5 events/day only
$\approx0.06\%$ of requests find something. Webhooks: 5 requests and milliseconds.
Polling remains useful when the receiver is not publicly reachable or events are very frequent
(batch them).

## How it works

```text
 1. You register: POST /webhooks {"url": "https://myapp.com/hook", "events": ["payment.succeeded"]}
    (server returns a shared signing secret)

 2. Event occurs at provider ───────────────► POST https://myapp.com/hook
                                               Content-Type: application/json
                                               X-Signature: t=1731900000,v1=ab12...
                                               {"id":"evt_9","type":"payment.succeeded","data":{...}}

 3. Your server verifies, enqueues, answers  ◄─ 200 OK  (within a few seconds)
```

The roles are reversed: **the provider is the HTTP client, you are the HTTP
server** (you need a public HTTPS endpoint; for development use a tunnel such as
`ngrok` or `cloudflared`, or the provider's CLI forwarder).

## Securing a webhook

Your endpoint is public: anyone can POST to it. Verify that the call is really from
the provider and not replayed.

1. **Signature**: the provider computes $\sigma=\text{HMAC}_{k}(\text{timestamp}\,\|\,\text{body})$
   with the secret $k$ and sends it in a header; you recompute it over the **raw
   body** and compare in constant time ([HMAC](authentication.md#tokens-and-jwt)).
2. **Timestamp check**: reject if $|\text{now}-t|>5$ minutes (stops replay of a captured request).
3. **HTTPS only**, optionally IP allow-list.
4. Never trust the payload blindly; for critical data, re-fetch the object through the authenticated API.

```python
import hmac, hashlib, time

def verify(secret: bytes, body: bytes, timestamp: str, signature: str) -> bool:
    if abs(time.time() - int(timestamp)) > 300:
        return False
    expected = hmac.new(secret, f"{timestamp}.".encode() + body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature)
```

## Delivery guarantees

The network can drop the request or your reply, so the provider cannot know whether
you processed the event. It **retries** (with exponential backoff over hours) until it
receives a `2xx`. This gives **at-least-once** delivery:

| Semantics | Meaning | Achieved by |
|-----------|---------|-------------|
| At-most-once | maybe lost, never duplicated | send once, no retry |
| **At-least-once** | never lost, maybe duplicated | retry until acknowledged |
| Exactly-once | processed once | at-least-once $+$ **idempotent** consumer |

Hence the consumer rule: **deduplicate by event id**.

```python
def handle(event):
    if seen_before(event["id"]):          # e.g. unique constraint in the database
        return                            # already processed: still answer 200
    process(event)
    mark_seen(event["id"])
```

Because $f(f(x))=f(x)$ for an idempotent handler, duplicates are harmless
([idempotency](rest.md#idempotency-and-retries)).

Other rules:

- **Answer fast** (`200` within seconds), do the heavy work **asynchronously**: put the
  event in a queue (Redis, SQS, RabbitMQ, Kafka) and process with workers. A slow
  endpoint triggers timeouts and retries.
- **Order is not guaranteed** (retries, parallel delivery): use timestamps or
  sequence numbers, or fetch the current state.
- Return `4xx` only for permanently bad requests; `5xx` or timeouts make the provider retry.
- Providers disable endpoints that keep failing; monitor failures and keep a
  replay/dead-letter mechanism.

## Related push mechanisms

| Mechanism | Direction | Use |
|-----------|-----------|-----|
| **Webhook** | server $\to$ your server (HTTP POST) | event notification between systems |
| **Long polling** | client holds a request open until data arrives | simple near-real-time |
| **Server-Sent Events** (SSE) | server $\to$ browser, one-way over HTTP | live feeds, progress |
| **WebSocket** | bidirectional, long-lived TCP after an HTTP upgrade | chat, games, collaborative apps |
| **Message queue / pub-sub** (Kafka, RabbitMQ) | producer $\to$ broker $\to$ consumers | internal decoupling, high volume |

WebSockets and SSE rely on a persistent [socket](../4_networking/sockets.md)
per client, so the [event-loop](../4_networking/sockets.md#serving-many-clients) designs
and connection limits matter.

## Things to remember

- Webhook $=$ the provider calls **your** endpoint; polling costs $86400/T$ requests
  per day and a delay of $T/2$.
- Verify the HMAC signature on the raw body and check the timestamp.
- Delivery is **at-least-once**: deduplicate by event id (idempotent handler).
- Acknowledge quickly, process asynchronously, don't rely on order.

## Exercises

1. Write a Flask/FastAPI endpoint that verifies an HMAC and prints the event; send
   test requests with `curl`.
2. Expose it with `ngrok http 8000` and register it in a GitHub repository's webhooks;
   push a commit and inspect the delivery log.
3. Send the same event twice and make the handler idempotent.
4. Compute the daily requests of polling every 30 s vs webhooks for 20 events/day.

## Going further

- Stripe, GitHub and Slack webhook documentation; "Standard Webhooks" specification.
- *Designing Data-Intensive Applications*, ch. 11 (stream processing, delivery semantics).
