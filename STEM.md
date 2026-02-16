LINK: https://arxiv.org/pdf/2601.10639

# 1. What is the paper about as a whole?
Efficiency gain in MoE/transformer.

# 2. What is being said in detail, and how?
A part of the FFN (up-projection) can be replaced with lookup embedding table. This is about ~30% speedup in the FFN layer and reduced VRAM usage as the embedding table can be kept in RAM and loaded in CPU. Each token has a representation in the table. This also has the potential of replacing tokens to steer the model into an answer

# 3. Is the paper true, in whole or part?
Performance gain seems true as CPU offloading is always great. The paper is vague on the other claims.

# 4. What of it?
That can reduce the VRAM usage of local models so I could potentially use larger models trained with STEM locally. 

