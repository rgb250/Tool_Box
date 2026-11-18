# REST

> **History:** Roy Fielding described **REST** (REpresentational State Transfer) in
> his 2000 PhD thesis as the architectural style that made the Web scale; JSON
> APIs of Flickr, Twitter and Amazon (2004-2006) popularized "RESTful" designs;
> OpenAPI (2015) standardized their description. See the
> [timeline](../timeline.md#apis). Previous: [what is an API](what_is_an_api.md).
> Next: [authentication](authentication.md).

## The idea

Model the system as **resources** (users, orders, files), each identified by a
**URL**. A client manipulates a resource by exchanging **representations** of it
(usually JSON) with a small, uniform set of HTTP methods.

$$\text{resource } r \xrightarrow{\ \text{representation}\ } \text{JSON}, \qquad
\text{state change} = \text{HTTP method applied to a URL}$$

REST is about **nouns in URLs, verbs in methods**: not `POST /createUser`, but
`POST /users`.

## Fielding's constraints

| Constraint | Meaning | Benefit |
|------------|---------|---------|
| Client-server | separate UI from data | independent evolution |
| **Stateless** | each request carries everything needed; the server stores no session between requests | any server can answer: horizontal scaling behind a [load balancer](../4_networking/cdn_and_load_balancers.md) |
| **Cacheable** | responses say if they may be cached | CDNs and browsers reduce load and latency |
| **Uniform interface** | same methods, URLs, status codes for all resources | easy to learn and tool |
| Layered system | proxies, gateways transparent to clients | CDN, security, balancing |
| (Hypermedia, HATEOAS) | responses contain links to next actions | rarely implemented fully |

## Designing resources

Collections and items:

| Operation | Request | Success |
|-----------|---------|---------|
| List | `GET /users?role=admin&limit=20` | `200` + array |
| Read | `GET /users/42` | `200` + object |
| Create | `POST /users` + body | `201 Created` + `Location: /users/43` |
| Replace | `PUT /users/42` + full body | `200` / `204` |
| Update part | `PATCH /users/42` + partial body | `200` |
| Delete | `DELETE /users/42` | `204 No Content` |
| Sub-resource | `GET /users/42/orders` | `200` |

This is **CRUD** (create, read, update, delete) mapped onto
`POST`, `GET`, `PUT/PATCH`, `DELETE`. Conventions: plural nouns, lowercase, hyphens,
no verbs, nesting for ownership (`/users/42/orders`), filters and sorting in
the query string (`?status=open&sort=-created_at`).
Method semantics (safe, idempotent) and status codes were covered in
[HTTP](../4_networking/http.md#methods).

Use the right status code: `400` malformed, `401` not authenticated, `403` not
allowed, `404` unknown, `409` conflict, `422` validation failed, `429` rate limited,
`5xx` server fault.

## Idempotency and retries

Networks fail: a client that gets a timeout does not know whether the server
executed the request. It is safe to retry when the operation is **idempotent**:

$$f(f(x)) = f(x)$$

`GET`, `PUT`, `DELETE` are idempotent by definition (set the state to a value;
deleting twice leaves it deleted). `POST` is not: retrying "create payment" may charge
twice. The standard fix is an **idempotency key**: the client sends a unique
`Idempotency-Key: <uuid>` header; the server stores the first result under that key and
returns the same result for repeats. Combined with retries and
[backoff](rate_limiting_and_pagination.md#client-side-retries-with-backoff) it
gives *effectively exactly-once* semantics.

## Errors

Return a consistent JSON body with the status code, e.g. the standard
**Problem Details** (RFC 9457):

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation failed",
  "status": 422,
  "detail": "`email` is not a valid address",
  "errors": [{"field": "email", "message": "invalid format"}]
}
```

## Versioning and evolution

- In the URL (`/v1/users`) is the most visible and common; or in a header
  (`Accept: application/vnd.example.v2+json`).
- Prefer **additive** changes (new optional fields); clients must ignore unknown fields
  (**tolerant reader**). Announce deprecations (`Sunset` header) with time to migrate.

## Minimal server and client

```python
# server.py   (pip install fastapi uvicorn;  uvicorn server:app)
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()
users: dict[int, dict] = {}

class User(BaseModel):
    name: str
    email: str

@app.post("/users", status_code=201)
def create(u: User):
    uid = len(users) + 1
    users[uid] = u.model_dump()
    return {"id": uid, **users[uid]}

@app.get("/users/{uid}")
def read(uid: int):
    if uid not in users:
        raise HTTPException(404, "user not found")
    return {"id": uid, **users[uid]}
```

```python
# client.py
import requests
r = requests.post("http://127.0.0.1:8000/users",
                  json={"name": "Ada", "email": "ada@example.com"}, timeout=5)
r.raise_for_status()
print(r.status_code, r.json())          # 201 {...}
print(requests.get("http://127.0.0.1:8000/users/1", timeout=5).json())
```

FastAPI generates an OpenAPI spec and interactive docs at `/docs` automatically.
Always set a **timeout** on client calls: the default is to wait forever.

## Strengths and limits

- Strengths: simple, uses HTTP caching and tooling, easy to debug with `curl`.
- Limits: **over-fetching** (the full object when you need two fields),
  **under-fetching** (several requests to assemble one screen), no standard for
  complex queries or real-time updates. These motivate
  [GraphQL and gRPC](graphql_and_grpc.md) and [webhooks](webhooks.md).

## Things to remember

- Resources are nouns (URLs); HTTP methods are the verbs; CRUD $\leftrightarrow$
  `POST/GET/PUT-PATCH/DELETE`.
- Stateless and cacheable $\Rightarrow$ scalable.
- Idempotent methods are safely retryable; give `POST` an idempotency key.
- Consistent errors, versioning, timeouts.

## Exercises

1. Run the FastAPI example; open `/docs`; call it with `curl -v`.
2. Add `PUT /users/{uid}` and `DELETE`; check with two repeated calls that they
   are idempotent.
3. Implement an `Idempotency-Key` header on `POST /users`.
4. Use the GitHub or JSONPlaceholder API with `requests` and read the headers
   (`ETag`, `Cache-Control`).

## Going further

- Fielding's thesis, ch. 5. *RESTful Web APIs* (Richardson, Amundsen). Microsoft and Google API design guides.
