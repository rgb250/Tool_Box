# TLS: secure connections

> **History:** early HTTP was plaintext. Netscape's **SSL** (1995) added encryption
> for e-commerce; TLS 1.0 (1999), 1.2 (2008), **TLS 1.3** (2018, RFC 8446: faster
> and safer). Let's Encrypt (2015) made certificates free; HTTPS is now the norm.
> See the [timeline](../timeline.md#networking). Previous: [DNS](dns.md).
> Next: [HTTP](http.md).

## What TLS guarantees

On top of a TCP connection, TLS gives:

| Property | Meaning | Tool |
|----------|---------|------|
| **Confidentiality** | an eavesdropper sees only ciphertext | symmetric encryption |
| **Integrity** | modifications are detected | message authentication (MAC / AEAD) |
| **Authentication** | you talk to the real `example.com` | certificates, signatures |

It does **not** hide who you talk to (IP address, often the name via SNI) nor
the amount and timing of data.

## Building blocks

- **Symmetric encryption** (AES, ChaCha20): one shared key $k$; fast.
  $c=E_k(m),\; m=D_k(c)$. Problem: how do two strangers share $k$?
- **Asymmetric** (public-key) cryptography: a key pair $(pk, sk)$. Slow, but
  solves key exchange and signatures:
  - signature: $\sigma=\text{Sign}_{sk}(m)$, anyone checks $\text{Verify}_{pk}(m,\sigma)$;
  - key agreement: Diffie-Hellman.
- **Hash** (SHA-256): fixed-size fingerprint, collision-resistant.

TLS uses asymmetric crypto only to **agree on a key and authenticate**, then
symmetric crypto for the data. Best of both.

### Diffie-Hellman key exchange

Public: a prime $p$ and a generator $g$. Alice picks secret $a$, Bob secret $b$:

$$A=g^{a}\bmod p,\qquad B=g^{b}\bmod p,\qquad
K = B^{a}\bmod p = A^{b}\bmod p = g^{ab}\bmod p$$

They exchange $A$ and $B$ in clear and both obtain $K$; an eavesdropper would
have to solve the **discrete logarithm** problem ($a$ from $g^a \bmod p$), which is infeasible
for large $p$. Toy example: $p=23$, $g=5$, $a=6$, $b=15$:
$A=5^6\bmod23=8$, $B=5^{15}\bmod23=19$, $K=19^6\bmod23=8^{15}\bmod23=2$.
Real TLS uses elliptic-curve DH (X25519).

Because fresh secrets are used per connection, past traffic stays safe even if the
server's long-term key leaks later: **forward secrecy**.

## Key sizes and brute force

A $k$-bit secret key has $2^k$ possible values. An attacker with no better method must
try them (**brute force**), on average half of them, so the cost grows as $O(2^k)$
([complexity](../2_from_code_to_execution/complexity.md#tractable-vs-intractable)):

$$T_{\text{brute force}}\approx\frac{2^{k-1}}{\text{guesses per second}}$$

Time to search the whole space at $10^9$ guesses/s (one core) and at $10^{18}$/s (a huge
cluster, beyond any known machine):

| Key bits $k$ | Keys $2^k$ | One core ($10^9$/s) | $10^{18}$/s |
|-------------:|-----------:|--------------------:|------------:|
| 40 | $1.1\times10^{12}$ | 18 min | instant |
| 56 (DES) | $7.2\times10^{16}$ | 2.3 years | 72 ms |
| 64 | $1.8\times10^{19}$ | 585 years | 18 s |
| 80 | $1.2\times10^{24}$ | $3.8\times10^{7}$ years | 14 days |
| 128 (AES-128) | $3.4\times10^{38}$ | $1.1\times10^{22}$ years | $1.1\times10^{13}$ years |
| 256 (AES-256) | $1.2\times10^{77}$ | $\approx10^{60}$ years | $\approx10^{51}$ years |

The age of the universe is $1.4\times10^{10}$ years, so 128 bits is out of reach even for
the cluster: a $\sim800\times$ margin for AES-128, and AES-256 is not a concern at all.
Adding **one bit doubles** the work, so security grows exponentially in the key length
while the cost of encrypting grows only linearly: the defender's advantage.

Historic lesson: DES (56 bits) was designed in the 1970s; in 1998 a machine built by the EFF
(Deep Crack) found a key in 56 hours, and DES was retired.

Important nuances:

- **Key length is not security level.** Public-key algorithms are attacked by
  better-than-brute-force methods (factoring, discrete logarithm), so they need longer keys
  for the same strength: RSA-2048 $\approx112$ bits of security, RSA-3072 $\approx128$,
  an elliptic-curve key of 256 bits (X25519, P-256) $\approx128$. This is why TLS
  prefers elliptic curves.
- **Hashes** of $h$ bits resist collisions only up to about $2^{h/2}$ trials (the
  *birthday bound*): SHA-256 gives $\approx2^{128}$.
- **Quantum computers**: Grover's algorithm square-roots a brute-force search
  ($2^{k}\to2^{k/2}$), so AES-256 is the conservative choice; Shor's algorithm would break
  RSA and elliptic curves entirely, hence the move to **post-quantum** key exchange
  (hybrid X25519 + ML-KEM is already deployed in browsers).
- **Humans are the weak part**: a password with 40 bits of entropy is attacked far
  below $2^{128}$, which is why servers store slow salted hashes
  ([authentication](../5_apis_and_web_services/authentication.md#passwords-store-hashes)).
- **Random keys** need a cryptographic random source (`secrets`, `/dev/urandom`),
  never `random`: a predictable key has fewer effective bits than its length.

## Certificates and trust

DH alone does not prove *who* you are talking to (a man in the middle could run DH
with both sides). The server proves its identity with a **certificate**: a statement
"public key $pk$ belongs to `example.com`", **signed** by a **certificate
authority** (CA).

$$\text{cert} = (\text{name}, pk, \text{validity}, \dots,\ \text{Sign}_{sk_{\text{CA}}}(\cdot))$$

Your OS/browser ships with about 150 trusted **root CA** public keys. Verification
follows a **chain**: root $\to$ intermediate $\to$ server certificate, each
signature checked, plus name and expiry. If any check fails you get the browser
warning.

## The TLS 1.3 handshake

```text
 Client                                            Server
   | ClientHello: versions, ciphers, DH share A, SNI  ->|
   |<- ServerHello: DH share B                          |
   |   {Certificate, signature over transcript, Finished}  (already encrypted with K)
   | {Finished} ---------------------------------------->|
   | ===== application data (encrypted) ================  |
```

Both derive session keys from the DH secret and the **transcript** (hash of all
handshake messages):
$k = \text{KDF}(K,\ \text{hash(transcript)})$. The server's signature over the transcript
proves it holds the private key matching its certificate.

**Latency**: TCP handshake 1 RTT + TLS 1.3 handshake 1 RTT $=2$ RTT before the
first request byte (TLS 1.2 needed 3). **Session resumption** and 0-RTT reduce it
for returning clients.

Data is then sent in **records**, each encrypted and authenticated with AEAD
(AES-GCM or ChaCha20-Poly1305): any tampering makes decryption fail.

## Related ideas

- **HTTPS** $=$ HTTP over TLS (port 443).
- **SNI**: the client sends the hostname in the ClientHello so one IP can serve
  many certificates.
- **mTLS** (mutual TLS): the client also presents a certificate; common between
  services.
- **SSH** uses the same ideas (key exchange, host keys).
- Certificates expire (Let's Encrypt: 90 days), hence automation (ACME).

## Tools

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null
curl -vI https://example.com        # shows handshake, cipher, certificate
openssl x509 -in cert.pem -noout -text
```

## Things to remember

- TLS $=$ authenticate (certificate chain) $+$ agree on a key (DH) $+$ encrypt with
  symmetric AEAD.
- $K=g^{ab}\bmod p$ is computed by both sides but never sent.
- A certificate binds a name to a public key through a CA signature.
- Setup cost with TCP: 2 RTT (TLS 1.3).

## Exercises

1. `openssl s_client` on a site; read the chain, the protocol and cipher.
2. Python: implement the toy DH with `pow(g, a, p)`.
3. `curl -v https://expired.badssl.com`; what failed?
4. Compute the time to first byte for a 40 ms RTT with TLS 1.2 vs TLS 1.3.

## Going further

- *Serious Cryptography* (Aumasson). RFC 8446 (TLS 1.3). "The Illustrated TLS 1.3 Connection".
