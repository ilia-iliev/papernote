TITLE: DeepSeek-V4.1-Flash
LINK: https://arxiv.org/html/2609.19969v1
DATE: 2026-10-06

# 1. What is the paper about as a whole?

The improvements that lead to better benchmark results and performance in DeepSeek-V4.1-Flash. The paper explains architectural decisions, challenges, and the post-training recipe in more detail.   

# 2. What is being said in detail, and how?

The improvements are in the following aspects:

Architecture:
- Added image encoder followed by MLP for image tokens
- Image encoder is a ViT with 2D-RoPE, trained from scratch
- MoE has routing bias term for image or text to balance experts
- 552B model parameters + 196B Engram
- Two-fold attention: sliding window attention and compressed sparse attention 2
- Quantization-aware training to global KV
- Faster mHC that reuses the coefficient from previous block
- 196B Engram. Uses hash lookup during inference


KV cache:

- Parameters: 8B during prefill, 16B during decode
- Causal encoder-decoder: half the layers generate the global KV cache. Encoder uses as-is, decoder reads it through a projection
- Sliding window reconstructs KV from the last window, approximating the real state for performance reasons
- CSA2 - KV is chunked and compressed. Top-k indexer uses softmax to choose entries for attention. The indexer can be reused:
  1. Full - compute KV and Q in full
  2. Reindex - share KV and indexer from the previous layer. Compute Q pass through the indexer for top-K
  3. Reuse - top-k indices from the previous layer
- FP4 KV cache
- 890 bytes/token for global cache, 1/8th compared to V4-flash

Training
- Contrastive communication for the vision encoder is overlapped with the text forward/backward pass to avoid idle time
- Load balancing for image preprocessing
- CSA2 sends additional attention metadata for pipeline parallelism
- SWA KV cache is short-lived as the window moves and is saved in RAM

Post-Training
- Tasks and environments improvement, no algorithm changes
- Tasks are grouped and deduplicated
- Synthetic task generation:
  - gathered from past interactions with mocked tools
  - scraped from public GitHub
- Environments are constructed with an agentic workflow - create tasks, verify quality, build container and prove empirical difficulty
- Custom orchestrator trades consistency for better scalability
- Reasoning level varies from the system prompt. Training applies length penalty
- To prevent long-tail stalling during rollouts: 
  - trigger training on a minimum number of rollouts
  - resume the non-completed ones with the new policy
  - randomly discard short rollouts

Evaluation
- Base version is roughly between DeepSeek-V4 pro and flash
- Post-trained version is much better on agentic and reasoning benchmarks 
- They have started work on multi-agent

# 3. Is the paper true, in whole or part?

The architectural changes do target better hardware utilization. It's hard to evaluate the intelligence tradeoff - as DeepSeek makes loads of them and we have a single point of comparison. The base version is roughly in line with the previous version, with the added benefit of having an image encoder.

The model explicitly targets agentic workflows - which is the reason for the considerations of prefill improvements. Some numbers to understand why prefill is more troublesome from actual users would have been helpful to evaluate. 

# 4. What of it?

The paper shows that incremental architectural performance tradeoffs can substantially decrease the compute and memory footprint. The freed compute seems to be utilized for improved post-training RL and the results on agentic benchmarks are significantly better. 

The trend is in the direction of linear attention. The scheme that DeepSeek uses has close to constant compute/memory per new token. SWA + CSA2 is a combination worth knowing about. 

As a consequence, I should experiment with the model and evaluate it on my own terms - probably not through the official API, as I don't want my traces to make it into the next iteration - they are open about it.

