LINK: https://arxiv.org/pdf/2403.03507

# 1. What is the paper about as a whole?
A new method that reduces the memory required for fine-tuning.

# 2. What is being said in detail, and how?
GaLore is a method that makes an analysis that the gradient is typically low-rank. So we can calculate the SVD of the gradient and use a compressed version to update the weights instead of storing the full gradient in memory. This greatly reduced the required memory.

# 3. Is the paper true, in whole or part?
Seems to reduce memory used at a cost of more compute since now we have to compute SVD.

# 4. What of it?
That's an amazing way for using smaller, consumer GPUs for fine-tuning multi-billion model. It's not as useful if you can store the full weights already.

