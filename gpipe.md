TITLE: Gpipe
LINK: https://arxiv.org/abs/1811.06965v5
DATE: 2026-10-16

## 1. What is the paper about as a whole?

The paper proposes an algorithm for using multiple GPUs to train a single model. This is a way for better pipeline parallelism - when the model's layers are split across GPUs. The mini-batch is split into micro-batches and micro-batches pass through the GPU pipeline, allowing simultaneous work. 

## 2. What is being said in detail, and how?

Splitting a training job across GPUs is done on a per-layer basis - meaning each GPU is responsible for a set of layers. Doing this naively incurs idle waste due to the dependency in the backward pass. GPipe divides a minibatch into microbatches to keep GPUs busy. Gradients are accumulated and applied once, when all micro-batches are processed.

The microbatch's activations are passed to the next GPU. GPipe stores activations between two layers - and intermediate ones are recomputed during the backward pass. This reduces memory usage at the cost of compute - which reduces total time as memory and bandwidth are the real bottelnecks.

For the Transformer, GPipe achieves almost linear speedup - 32 microbatches on 4 GPUs is 3.4x. Going from 2 to 4 GPUs is 1.8x.

A limitation of GPipe is than batch-level operations (like BatchNorm) require intermediate operations.

## 3. Is the paper true, in whole or part?

The paper is foundational in terms of pipeline parallelism - and it seems like the main concept is still relevant - micro-batching is very widely used, 8 years after the paper has come out. Moreover, that's one more reason to use LayerNorm instead of BatchNorm. 

## 4. What of it?

I should train a single model on my two GPUs. Pipeline parallelism is worth experimenting with - and I need more hands-on experience on GPU idle time.

