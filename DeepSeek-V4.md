TITLE: DeepSeek-V4
LINK: https://arxiv.org/pdf/2606.19348
DATE: 2026-09-04

# 1. What is the paper about as a whole?

Technical report about the training and inference of DeepSeek-V4. Includes information about the whole stack - infrastructure, architecture, pre-training, post-training and evaluations. The main goal is to achieve a1 million context window while retaining reasoning and agentic capabilities

# 2. What is being said in detail, and how?

Architectural decisions:

- mHC - the residuals are expanded to 4 streams of hidden layers. There is a constraint (Sinkhorn-Knopp normalization) that uses a doubly stochastic matrix (random positive values, columns/row to sum to 1). This prevents gradient instabilities.
- CSA (Compressed Sparse Attention) and HCA (Heavily Compressed Attention). The KV cache is compressed in chunks and then attention is applied sparsely to the chunks. A hidden layer decides which other chunks it attends to through softmax (top-k). HCA works similarly but compresses chunks by a much larger factor and attends over all the chunks. The two are concatenated with a sliding window of the recent tokens which always make it into attention
- Muon optimizer - this eliminates the need to keep some of the state for each weight and substitutes it for orthogonal matmul which ends up being more efficient, compared to Adam

Infrastructural decisions:

- In MoE, a lot of time is wasted on communication to and from the experts. DeepSeek have fused communication and computation with custom kernels that reduce this communication bottleneck
- They use TileLang - new-ish DSL for kernel development. DeepSeek has implemented some optimizations on top of it - so that type checks, algebraic checks or precision happen in the kernel host
- Implementing own kernels for much of the model and more deterministic batching during training for easier debugging
- They implement their own KV caching mechanism that has sliding window path and sparse path. The sliding window path is configurable and has various modes of caching, depending on how heavy the usage is

Pre-training

- There is focus on longer documents
- Vocabulary is 128k tokens
- 43 transformer layers, 284B/A13B for Flash, 61 layers and 1.6T/A49B for Pro
- Embeddings, prediction head and RMSNorm use AdamW, everything else Muon
- The length gradually scales up with training. Sparse attention is introduced after 1T tokens (32T total)
- Routing to experts introduces instability, so it is decoupled by routing several steps ahead

Post-training

- The actor and reward model are unified
- <think></think> tags are explicit and retained across user turns
- Auxiliary tasks (such as title generation) execute in parallel to the response
- They RL train models (teachers) for different tasks and merge them on the full logit with weight
- Use FP4 Quantization-Aware Training
- They cache the teacher final layer state and regenerate the logits to optimize bandwidth on all the logits - as opposed to moving the logits themselves
- Token-level WAL for fault tolerance

Evaluation

- Benchmarks are competitive with Opus-4.6 and Gemini-3.1 on agentic workflows, knowledge, and reasoning - within a couple of points.
- DeepSeek-V4-Pro still trails the top model
- As a coding agent, DeepSeek-V4-Pro is almost at Opus 4.5-level
- At full context, Pro has 27% of the FLOps and 10% the KV cache size compared to DeepSeek-V3.2

# 3. Is the paper true, in whole or part?

The paper gives a good overview of the architecture and the decisions behind it. It's quite detailed. 

A large portion of the improvements in the paper are still closed. The data recipe for post and pretraining, RL setup and rewards are only mentioned in passing. 

DeepSeek has achieved 1 million context length - and that's notable for open weight. However, it's not clear how well CSA and HCA handle long context - only that they achieved long context.

# 4. What of it?

I think the model puts into perspective how difficult it is to achieve 1 million context - and all the tradeoffs that need to be made. The attention mechanism is degraded compared to quadratic attention - so I have to be mindful when approaching long context. It's likely that the closed labs also do similar tradeoffs to achieve 1 million context.

I learnt how much of the training process depends on low-level custom kernels - it really is pervasive throughout the whole stack.

Tilelang seems like something I should look into - and write a few kernels with it for my GPU as the paper establishes how much easier it is to experiment compared to CUDA.

