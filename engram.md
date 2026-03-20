LINK: https://github.com/deepseek-ai/Engram/blob/main/Engram_paper.pdf

# 1. What is the paper about as a whole?
It's about integrating knowledge retrieval with the network weights.

The authors show that dynamically fetching N-grams of the tokens and adding them to the hidden state improve performance in iso-metrics (i.e. compute or total number of weights being equal).

# 2. What is being said in detail, and how?
The paper makes a hypothesis that knowledge retrieval is a trivial type of compute and there is potential free attention resources. They use heuristic-type n-grams to create a hash table of weights that can be loaded in the network before attention by addition. Basically:

mem = concat( hashlookup(2grams) , hashlookup(3grams) )
h(out) = h(in) + conv( h(in) . ( gate(h(in) * mem) * mem) ) 

The weight update happens in the mHC residual stream. A gating mechanism ensures that only relevant weights get added and the others get pushed to zero.

The engram is applied in parallel heads (the mHC streams) to avoid hash collisions. Also, there is some optimization by merging some of the semantically similar tokens.

They make several studies - comparing results to MoE-architecture with same or more parameters. Results show, that Engram architecture is more efficient in terms of parameters.

Moreover, there is an added benefit that this hash-table is fixed and can be pre-fetched the moment we know our tokens.

# 3. Is the paper true, in whole or part?
The paper relies on prior DeepSeek-specific architectures and advancements. It's hard to say if the approach would generalize to more traditional forms of transformer; mHC is a fairly recent concept and has not been properly battle tested

# 4. What of it?
It seems like a promising way to build on top of DeepSeek's prior architecture - namely mHC. DeepSeek are advancing the field and a more comprehensive look at their pipeline is worth it. They seem to be packing more in less parameters.

The hypothesis that knowledge retrieval is interspersed with attention compute is fascinating. There is probably a better way to fetch knowledge than weights based on n-grams but it's a promising direction and they show results.
