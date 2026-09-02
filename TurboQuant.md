TITLE: TurboQuant
LINK: https://arxiv.org/abs/2504.19874
DATE: 2026-04-28

# 1. What is the paper about as a whole?
A quantization method that provably achieves near-optimum lower-bound error rate - very close to the provable lower bound. They propose a 2-step method that utilizes a conventional MSE quantization followed by 1-bit quantization on the residual.

# 2. What is being said in detail, and how?
The paper leverages several concepts:

1. If we multiply an input matrix by a rotation matrix, we can "spread" the information across the dimensions so that they are effectively independent
2. If the information is truly "spread" in dxd dimensions, the MSE error is bounded by the size of d and the number of bits. 
3. The MSE error is typically biased; meaning that it tends to cluster around certain values
4. We can effectively debias those values using a single bit and the same idea as above (spreading the information with rotation)

This is the theory behind TurboQuant. Here's the flow:

input: X (d-dimensional)
random rotation matrix: P (dxd-dimensional)
desired bits: b

0. Create rotation matrix S (with some distribution). Create centroids by minimizing MSE with desired bits over the distribution of S

1. Apply rotation S to input - S * X = y
2. y * Qmse = y^ (save index of nearest centroids)
3. Calculate the residual r = y^ - y
4. Apply rotation to r and extract sign (one-bit): sign(r * S) = q
5. We get the norm of residual, gamma

We now have idx, q. This is our quantization.

To dequantize:
1. idx(Qmse) = x^ -> retrieve the centroid given indices
2.  S(transposed) * q * scaling * gamma = x^q
3. return x^ + x^q

Empirically, this achieves much better compression compared to alternatives at 4-bits - with less quantization error and better benchmarks.

# 3. Is the paper true, in whole or part?
The paper seems to be promising in terms of achieved quantization. It should be noted that the extra mat-mul with dxd random matrix makes this quantization impractical for large d; i.e. model weights. However, the KV cache reduction is significant for inference at scale but it's hard to evaluate at what point the extra steps in quant/dequant become more trouble than they are worth.

# 4. What of it?
The paper has attracked substantial interest and is promising meaningful reduction of the KV cache at minimum performance hit. Moreover, the quant/dequant process can be accelerated using a GPU; effectively meaning that this or a similar method is likely to be commonplace for large-context LLM inference. The fact that it's data-agnostic is also a major plus.

