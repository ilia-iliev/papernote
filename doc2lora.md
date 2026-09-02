TITLE: Doc2LoRA
LINK: https://arxiv.org/pdf/2602.15902

# 1. What is the paper about as a whole?

About fitting large documents in context. More specifically, not using any context but instead generating a LoRA adapter on the fly. This is done through a pre-trained network that specifically generates LoRA adapter given any context. 

# 2. What is being said in detail, and how?

Current context learning is an unsolved problem - slow/expensive/doesn't work well. The authors propose using a hypernetwork that is specifically trained to generate LoRA adapters such that OG network and adapted network have little KL divergence.

An LLM is used to generate relevant questions given a context dressed in an instruction prompt. Those pairs are used to train the hypernetwork. It can work on variable-length context through perceiver. In short, it uses latent attention that forces Q vector to be fixed-size. This is more efficient than self-attention but it seems to be retaining information well enough. Also solves the issue of having variable-length input being mapped to fixed-size LoRA.

A trick of chunking large context and passing them indepedendently through the hypernetwork is applied. The results are concatenated to be applied as LoRA.

# 3. Is the paper true, in whole or part?

The paper seems like an optimization with some caveats.

Given a trained hypernetwork, it is fast, uses substantially less memory and benchmarks well. However, it does require training a specific hypernetwork. This is done on per-model basis - requires a new training pipeline and resources. Also, any amendments to the model such as quantizations probably require retrianing.

# 4. What of it?

It's a way to solve large context. I remain unconvinced on the practicality given the limitations of training a new network as it seems that this makes model portability even more brittle than it currently is. But it's an interesting concept and I should read about Perceiver and more attention optimizations.
