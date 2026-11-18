# Authentication and authorization

> **History:** passwords and HTTP Basic auth (1990s); cookies and server sessions;
> **OAuth 1.0** (2007) and **OAuth 2.0** (2012, RFC 6749) for delegated access;
> **OpenID Connect** (2014) adds login on top; **JWT** (RFC 7519) and **PKCE**
> (RFC 7636) arrive in 2015. See the [timeline](../timeline.md#apis). Previous:
> [REST](rest.md). Next: [GraphQL and gRPC](graphql_and_grpc.md).

## Two questions

- **Authentication (authn)**: *who are you?* $\to$ an identity.
- **Authorization (authz)**: *what may you do?* $\to$ a permission check
  $\text{allowed}(\text{identity}, \text{action}, \text{resource})\in\{\text{true},\text{false}\}$.

HTTP codes: `401 Unauthorized` really means "not authenticated"; `403 Forbidden`
means "authenticated but not allowed".

**Every credential must travel over [TLS](../4_networking/tls.md)**; otherwise anyone on
the path reads it.

## Common mechanisms

| Mechanism | How | Typical use |
|-----------|-----|-------------|
| **API key** | secret string in a header (`X-API-Key`) or `Authorization` | server-to-server, simple identification of an app |
| **HTTP Basic** | `Authorization: Basic base64(user:password)` | quick tools; base64 is *not* encryption |
| **Session cookie** | server stores session, browser sends `Cookie: sid=...` | classic web apps |
| **Bearer token** | `Authorization: Bearer <token>` (opaque or JWT) | modern APIs, mobile |
| **OAuth 2.0** | user grants an app limited access to their data | "Sign in with Google", third-party apps |
| **mTLS** | both sides present certificates | service-to-service |

API-key hygiene: never commit them (use environment variables or a secret manager),
scope them narrowly, rotate them, store only a **hash** server-side.

## Passwords: store hashes

Servers must never store passwords; they store a slow salted hash
$h=\text{KDF}(\text{salt}, \text{password})$ (bcrypt, scrypt, argon2) and compare
on login. A *salt* defeats precomputed tables, slowness multiplies the cost of each guess
in the [brute-force](../4_networking/tls.md#key-sizes-and-brute-force) search. (Plain
SHA-256 is far too fast for this.)

## Tokens and JWT

A **JSON Web Token** is a self-contained signed token:

```text
 base64url(header) . base64url(payload) . signature
 {"alg":"HS256"}      {"sub":"42","scope":"read","exp":1767225600}
```

Signature with a shared secret $k$ (HMAC) or a private key (RSA/ECDSA):

$$\sigma = \text{HMAC}_k\big(\text{header}\,\|\,\text{payload}\big)$$

The server recomputes $\sigma$ and compares; if equal, the payload is authentic
and unmodified. The payload is **only encoded, not encrypted**: do not put secrets in it.

| Pros | Cons |
|------|------|
| **Stateless**: no database lookup, any server can verify with the key | hard to **revoke** before `exp` (keep lifetimes short, use refresh tokens) |
| Carries claims (`sub`, `scope`, `exp`) | larger than an opaque id |

Pitfalls: always verify the signature **and** `exp`, `iss`, `aud`; fix the accepted
algorithm (reject `alg: none`); store tokens safely (`HttpOnly` cookies against XSS).

A common pattern: short-lived **access token** (minutes) plus long-lived **refresh
token** to obtain new ones.

## OAuth 2.0: delegated authorization

Problem: the app *Calendar-Sync* wants to read your Google Calendar. Giving it your
Google password is dangerous (full access, can't revoke). OAuth lets you grant
**limited, revocable** access instead.

Roles: **resource owner** (you), **client** (the app), **authorization server**
(Google's login/consent), **resource server** (the Calendar API).

### Authorization code flow with PKCE

```text
 Client app                 User's browser              Auth server           Resource API
    | 1. redirect to /authorize?client_id&scope&redirect_uri&state&code_challenge
    | -------------------------> |  -------------------->  |
    |                            | 2. user logs in, consents|
    | <------- redirect to redirect_uri?code=XYZ&state ----  |
    | 3. POST /token {code, code_verifier} ----------------->|
    | <------------- access_token (+ refresh_token) ---------|
    | 4. GET /events  Authorization: Bearer access_token ------------------------>|
```

- **Scopes** limit what the token can do (`calendar.readonly`).
- `state` is a random value checked on return to prevent CSRF.
- **PKCE** protects the code from interception: the client invents a random
  `code_verifier`, sends only its hash first, and reveals the verifier at step 3:

$$\text{code\_challenge} = \text{base64url}\big(\text{SHA-256}(\text{code\_verifier})\big)$$

  An attacker who steals the code cannot redeem it without the verifier.
- The user's password is only ever typed at the authorization server.
- Server-to-server (no user): **client credentials** grant. The legacy *implicit* and
  *password* grants are deprecated.

**OpenID Connect (OIDC)** adds an **ID token** (a JWT with the user's identity) on
top of OAuth 2.0, which turns it from "access delegation" into "login". OAuth alone is
authorization; OIDC provides authentication.

## Authorization models

- **RBAC** (role-based): user $\to$ roles $\to$ permissions; `admin`, `editor`.
- **ABAC** (attribute-based): rules over attributes (owner, department, time).
- Always check **object-level** access: `GET /orders/42` must verify that order 42
  belongs to the caller (the top API vulnerability, *BOLA/IDOR*).

## Tools

```bash
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/me
echo 'eyJ...' | cut -d. -f2 | base64 -d      # peek at a JWT payload (just encoded)
openssl rand -base64 32                       # generate a secret
```

```python
import hmac, hashlib
sig = hmac.new(b"secret", b"payload", hashlib.sha256).hexdigest()
hmac.compare_digest(sig, received_sig)        # constant-time comparison
```

## Things to remember

- Authn = who; authz = what; `401` vs `403`.
- Always TLS; hash stored passwords; keep secrets out of code.
- JWT $=$ signed, not encrypted; short life $+$ refresh token; verify everything.
- OAuth 2.0 (code flow $+$ PKCE) delegates limited access; OIDC adds identity.
- Check object-level permissions on every request.

## Exercises

1. Decode a JWT payload (e.g. from `jwt.io`) with `base64 -d`; find `exp`.
2. Use the `pyjwt` library to sign and verify a token; change one character and watch
   verification fail.
3. Register a GitHub OAuth app and perform the authorization code flow by hand with `curl`.
4. Compute `code_challenge` in Python for a random verifier (`hashlib.sha256`, `base64.urlsafe_b64encode`).

## Going further

- OAuth 2.0 Simplified (Parecki). RFC 6749, 7519, 7636. OWASP API Security Top 10.
