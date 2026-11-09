# Attention Is All You Need

## Some recalls

### Why do we use an attention mechanism?

In an encoder-decoder translation model (RNN-based), the whole source sentence is
encoded into a **single fixed-size vector**. This is a bottleneck:

- information is lost, especially for long sentences;
- the decoder cannot "look back" at specific source words when producing each target word.

Attention removes this bottleneck. Instead of one summary vector, the model keeps a
representation for **every** input word and, at each output step, computes a weighted
combination of them. The weights say which input words matter most for the current
output word (a soft alignment between source and target).

### How does it work?

1. **Reading**: convert each word into a distributed representation (an embedding),
   i.e. a list of vectors where each vector describes one word and its position in the
   input.
2. **Memorizing**: store this list of vectors, which is a matrix of shape
   `(sequence_length, d_model)`. It acts as a memory that can be queried.
3. **Exploiting**: for a given query (e.g. the current decoder state), compute a score
   against each stored vector, normalize the scores with a softmax to get weights, then
   use these weights to take a weighted sum of the vectors.

In short: $output = \sum_{i} \sigma(scores_{i}) \cdot v_{i}$.

### What are `q`, `k` and `v`?

They are **vectors** (size `d_k`, e.g. 64), one triplet per token, not sentences.

1. Split the sentence into tokens: `"the cat sat"` → `[the, cat, sat]`.
2. Embed each token: $x_i \in \mathbb{R}^{d_{model}}$.
3. Project with learned matrices: $q_i = W^Q x_i$, $k_i = W^K x_i$, $v_i = W^V x_i$.

- **query** `q_i`: what token $i$ is looking for.
- **key** `k_i`: what token $i$ offers (a label to be matched against).
- **value** `v_i`: the content actually passed on when token $i$ is selected.

Analogy: search request (query) vs. book labels (keys) vs. book contents (values).

Example: to update `sat`, compute $q_{sat}^\top k_{the}$, $q_{sat}^\top k_{cat}$,
$q_{sat}^\top k_{sat}$ (3 numbers), softmax them, and take the weighted sum of
$v_{the}, v_{cat}, v_{sat}$.

- Self-attention: `Q`, `K`, `V` all come from the same sequence (rows = tokens).
- Encoder-decoder attention: `Q` from the decoder, `K` and `V` from the encoder output.

### How are the `scores` computed?

A score measures how well a query `q` matches a key `k_i`. The query comes from the
"asking" position (e.g. the current decoder state), the keys come from the memory
(one per input word). Several scoring functions exist:

| Name | Formula | Used in |
|------|---------|---------|
| Additive (MLP) | $score(q, k_i) = w^\top \tanh(W_q q + W_k k_i)$ | Bahdanau et al. 2014 |
| Dot product | $score(q, k_i) = q^\top k_i$ | Luong et al. 2015 |
| Scaled dot product | $score(q, k_i) = \dfrac{q^\top k_i}{\sqrt{d_k}}$ | *Attention Is All You Need* |

Then:

$$\alpha_i = \sigma(scores)_i = \frac{\exp(score_i)}{\sum_j \exp(score_j)}, \qquad output = \sum_i \alpha_i v_i$$

In the Transformer, `q`, `k_i` and `v_i` are learned linear projections of the token
embeddings $x$:

$$q = W^Q x_{query}, \qquad k_i = W^K x_i, \qquad v_i = W^V x_i$$

Stacking all queries/keys in matrices gives all scores at once:
$scores = Q K^\top / \sqrt{d_k}$, a matrix of shape `(n_queries, n_keys)`
where entry $(t, i)$ is the score of query $t$ for key $i$.

Why divide by $\sqrt{d_k}$? If the components of `q` and `k` have mean 0 and variance 1,
$q^\top k$ has variance $d_k$. Large scores push the softmax into regions with tiny
gradients, so we rescale to keep the variance around 1.

### Scaled dot-product attention (the version used in the paper)

Each token is projected into a query `Q`, a key `K` and a value `V`:

```
Attention(Q, K, V) = softmax(Q Kᵀ / √d_k) V
```

- `Q Kᵀ`: similarity between every query and every key.
- `√d_k`: scaling to keep the softmax from saturating when `d_k` is large.
- Multiplying by `V`: weighted sum of the values.

**Self-attention** means `Q`, `K` and `V` all come from the same sequence, so each token
can gather information from every other token in a single step (no recurrence).

### TODO

- [ ] Multi-head attention: why several heads in parallel?
- [ ] Positional encoding: needed because attention itself ignores token order.
- [ ] Encoder / decoder structure, masking in the decoder.

# Formal algorithms for transformers
