TITLE: Speculative Speculative Decoding
LINK: https://arxiv.org/abs/2603.03251
DATE: 2026-05-13

# 1. What is the paper about as a whole?
An optimization on speculative decoding. The authors identify that the draft model is sitting idle while waiting for verification and propose that it could use the available resources to generate solutions based on what predicted (speculated) verification result.

# 2. What is being said in detail, and how?
We have a draft and a backup draft (D and B). Let the verifier be V.

D is working on dedicated hardware and can thus generate a lot more solutions and is busy at all times. While V is busy accepting/rejecting tokens, D generates and caches scenarios based on likely acceptances/rejections. This effectively speeds up the process.

There is a tradeoff between cache quality and first draft quality. We can effectively adjust our prediciton power to account for cache hits. Intuitively, if change our sampling, we can let D focus more on generating stronger tokens further down the speculation chain (say tokens 3 and 4 rather than 1 and 2). This slack is expected to be picked up by the cache.

Results show substantial improvement on LLama3.1-70B - double-digit percent for all batches up to 16. Higher the batch, lower the improvement, ~20% measured over proprietery implementation of speculative decoding at batch=16, and 30% on average.

When V returns and there is a cache miss, there is also an extra token (as is the standard for speculative decoding). Meaning that D is not prepared for this scenario and something has to be returned or V is stalled, greatly bottlenecking the whole thing. Moreover, just 1 cache miss is enough for this bottleneck to happen - we can't pass the result unless it's fully in the cache. The problem is especially prominent in larger batch sizes - as the likelihood grows. This is where B comes in - for small batch sizes, we can use D as B. However, for large batch sizes, we can return random tokens on that cache miss and expect them to be rejected by the verifier - so that only the sequence(s) with cache miss are affected negatively.

# 3. Is the paper true, in whole or part?
It seems like that higher batch sizes are starting to show less and less improvement and it's hard to say if batch size of 16 is really cutting considering that we are talking about GPU rack. Also, the exact parameters of the draft model matter a lot and what works for older models like llama3.1 and qwen3 is not inherently universal.

# 4. What of it?
This is a bit of a departure from the original conception of speculative decoding which was to utilize the available compute of bandwidth-constrained GPU. The paper seems to be focusing at the scale where a draft model is in a rack, occupying a GPU rather than sharing compute with larger model. Because of that, it's unlikely to be used in local AI. However, there is potential to work around the problems introduced by the batching and this work can probably be further explored on for large-system inference.
