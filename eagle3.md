TITLE: EAGLE-3
LINK: https://arxiv.org/abs/2503.01840

# 1. What is the paper about as a whole?
An improved version of an existing speculative decoding algorithm - EAGLE-3. 

# 2. What is being said in detail, and how?
EAGLE is a family of speculative models that reuse hidden features from the target model for training a draft model.

EAGLE-1 and 2 are trained to predict the last feature layer of the target model. They effectively skip all other layers and predict the one just before the head of the target model. The target model's LM head is reused.

EAGLE-3 is a new and improved version that also trains a model based off the target. However, it predicts tokens directly and does not reuse the head. The idea is to simplify the loss - so it focuses on draft tokens only, instead on draft tokens AND feature reconstruction. 

For each token, EAGLE-3 uses 3 hidden feature layers (instead of only the last one). Those features get compacted in FC layer and fed into a transformer-decoder that predicts the next token. The above scenario describes the features when token features come from the target model. To support drafting more than a single token, the EAGLE-3 pipeline includes draft tokens features in the sequences; meaning that the same architecture can be fed in both draft and target tokens.

Results show improvements across-the-board - 20% to 75% compared to EAGLE-2 for single inference. This is also empirically shown in batching scenarios. A key difference is that EAGLE would degrade performance past batch size of 16 - and EAGLE-3 shows 40% improvement for batch size of 64. For vLLM, improvement is also around 40% and starts to degrade at batch size of 56.

# 3. Is the paper true, in whole or part?
The paper seems to be strictly improving on the previous version. Moreover, the architecture is widely used in all major open source inference libraries - vLLM, SGLang, llamacpp. 

However, as with all EAGLE models, there is an additional step of training the draft - meaning that it's not always supported without someone working to implement it.

# 4. What of it?
Training an EAGLE-3 draft and benchmarking it sounds like a great project to contribute to OSS.
