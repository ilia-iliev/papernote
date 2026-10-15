TITLE: Targeting Pivotal Decisions for Credit Assignment in Agentic Reinforcement Learning
LINK: https://arxiv.org/pdf/2609.36178
DATE: 2026-10-14

## 1. What is the paper about as a whole?

This is a method to find the 'important' token in RL rollouts. A well-known GRPO/PPO issue is that all tokens in a rollout are equally reinforced. There's no practical way to find the truly consequential ones - so tokens that have no bearing on the task completion still get a reward. The paper proposes to use an LLM agent to pick and propose a section of important tokens. This is externally verified through more rollouts - and proven segments are rewarded.

## 2. What is being said in detail, and how?

There is an agentic loop:
1. Passing and failing rollouts are fed into an agent that can identify candidates. There are two tools available - `search_trajectory(query, top_k)` (fuzzy search) and `get_segment(traj_id, start_turn, end_turn)` - gets a segment of agent turns
2. The agent identifies segments that can explain the pass/fail difference
3. The segment advantage is verified empirically - by rolling out with and without the segment and measuring the reward difference
4. All the successful tokens get rewarded. The tokens in the segment get an additional reward, if the verifier shows improvement

This shows improvement across three benchmarks using a 2B and 4B Qwen models. This is compared to:
- GRPO
- GRPO with matched rollout budget
- SPO-chain: fixed segments (not LLM-judged)
- SPO-tree: tree-structured rollouts that reuse prefixes and assign advantages to branches
- GiGPO: assings step-level credit by comparing actions from repeated states
- CriticSearch: uses the LLM to directly provide credit, no verifier

ProVer shows the biggest improvement. Also, it's more compute-efficient compared to other reward policies like SPO.

## 3. Is the paper true, in whole or part?

The paper does a small-scale experiment with small models and a small critic. It's hard to evaluate how well this translates to bigger models and more complicated rollouts. It would have been helpful to see some chosen segments. I suspect that the task of identifying segments is easier when using smaller models - and it's not possible to evaluate how well the proposed segments translate to harder tasks.

The method still uses GRPO rewards - just some tokens get additional reward. So the proposed method still struggles from rewarding inconsequential tokens.

## 4. What of it?

It's fascinating that RL experimentation can be done at such a small scale. That would be useful for me to get some intuition on how RL works in practice by trying to build on top of this paper with small LLMs.

