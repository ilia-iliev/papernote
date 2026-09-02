TITLE: DualPath
LINK: https://arxiv.org/html/2602.21548v2
DATE: 2026-04-01

# 1. What is the paper about as a whole?
The paper considers the contraints of current LLM inference in GPU clusters; specifically focusing on bandwidth bottlenecks. Suggests tricks of how to distribute the available resources more appropriately for the real workloads.

# 2. What is being said in detail, and how?
The current state of large-scale LLM inference is inefficient. The paper says that we have two types of GPUs - designated for decode (DE) and for prefill (PE) and balancing the two is a tricky business; current empirical usage proves that often happens that PE is bottlenecked by bandwidth while DE is staying idle and isn't utilizing its resources. The paper proposes that DE can 'chip in' and utilize its available bandwidth by using the CNIC (compute NIC) to help wil prefill. The key is that both read from SNIC instead of just one. Current implementations use that CNIC for PE->DE KV loading as well as compute and the paper introduces a DE->PE path. This introduces challenges - i.e. how to manage the traffic to PE which now comes from two sources. Another challenge is to ensure KV doesn't interfere with the compute as this can be a severe bottleneck for some operations.

Traffic is managed by direct RDMA, meaning that the GPUs can access each other directly, without having to go to CPU. This makes it faster and there is priority for the model computations over KV. 1% of the traffic is round-robin without priority management to ensure nothing gets starved. It should be noted that the authors do a 'detour hack' by using CNIC as scheduler to ensure the priority gets applied.

GPUs are grouped based on their role - each group is either PE only or DE only and one GPU per group interacts with the scheduler (load balancer, based on CNIC) - based on requests and tokens per request per GPU. The scheduler is basically in charge of realizing which dual path makes more sense given the load.

Also, in the forward prefill pass, the long requests (with loads of tokens) are chunked to fill to ensure there is no bottleneck due to module parallelism.

The experiment showed substantial improvement compared to SGLang or other solutions, in the range of ~90%.

# 3. Is the paper true, in whole or part?
The paper is probably battle-tested in real production as DeepSeek is a serious provider. However, a lot of the decisions seem to make sense only for GPU racks and it's not intuitive for my understanding.

# 4. What of it?
It's a great resource of understanding the constraints of modern GPU clusters during inference. I improved my understanding of what happens. Moreover, it shows that for such scale bandwidth is the real bottleneck. 

As for implementation, I'm not sure this paper changes anything for small-scale or local inference, which is primarily what I'm currently interested in.

I found useful some terminilogy:

CNIC and SNIC - compute/storage NIC - this is the hardware that interfaces the data to and out of the GPU.
InfiniBand - this is the cabling and the switches
RDMA - this is the concept of direct memory transfer without going to the CPU
Node - A collection of GPUs - typically 8. They have a shared SNIC (CNIC is per GPU) and talk between nodes using InfiniBand
LayerWise prefill - KV cache can be loaded independently per layer (a layer-cache block, effectively). This enables the communication between DE -> PE as each GPU is responsible for a set of layer-cache blocks.
