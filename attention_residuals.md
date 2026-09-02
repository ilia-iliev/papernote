TITLE: Attention Residuals
LINK: https://arxiv.org/pdf/2603.15031
DATE: 2026-04-23

# 1. What is the paper about as a whole?
The paper proposes an attention mechanism for the residual stream and talks about several practical techniques about achieving this without severe tradeoffs.

# 2. What is being said in detail, and how?
The "traditional" way of residual stream has an inherent problem, similar to that of RNNs - each layer n dilutes some of the residual information in n-1. Meaning that information really struggles to propagate in the distance, i.e. n-10 to n is less relevant than n-1 to n.

Given this consideration, the paper proposes the residual stream to go through attention mechanism - effectively meaning that each layer has a way to "attend" to a layer much further back directly. This is aThis introduces practical difficulties:

1. The layers are no longer in sequence and we can't shard the model on several GPUs effectively. The sharded model now has to pass the calculated residuals between the GPUs
2. The residual gradients require a lot more memory and bandwidth. The authors suggest applying "block" attention (similar to chunked attention) - we group several residuals and they apply attention between in-group and between-group. 
3. We have to apply some kind of normalization since the residuals have different scales - this being residual->RMSNorm->softmax->attention 

The block attention applies a two-phase algorithm that (1) calculates the attention in-block(s) in parallel and (2) applies the attention recursively with running softmax. 

An important consideration is that each layer uses a learned pseudo-query (1); meaning it always uses the same query vector, independent of the input. Effectively, we have K and V cached for each forward pass and Q is fixed.

Results show across-the-board improvement over baseline and even mHC.

# 3. Is the paper true, in whole or part?
The paper seems like a true improvement in deep transformer networks and I like that the authors compare to mHC - this seems like another approach to the same problem. However, it seems like the block approach is absolutely vital or the bandwith constraints become too much.

# 4. What of it?
This is yet another step architectural improvement of the transformer. It involves several tricks and is somewhat complicated to reason about for a small, albeit noticeable improvement. Nevertheless, it's good to know how it works as it can start appearing in open-weight models.

