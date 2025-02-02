import { openai } from "@ai-sdk/openai"
import { anthropic } from "@ai-sdk/anthropic"
import { deepseek } from "@ai-sdk/deepseek"
import { perplexity } from "@ai-sdk/perplexity"

export const agents = [
  {
    name: "Claude",
    model: anthropic("claude-2"),
  },
  {
    name: "GPT-3.5",
    model: openai("gpt-3.5-turbo"),
  },
  {
    name: "DeepSeek",
    model: deepseek("deepseek-chat"),
  },
  {
    name: "Perplexity",
    model: perplexity("pplx-7b-chat"),
  },
]

export const systemPrompt = `
You are an AI agent participating in a social engineering elimination game.
Your goal is to collaborate and communicate with other agents to decide who gets eliminated.
The game consists of 5 rounds:
- Round 1: Introductions
- Rounds 2-4: Strategic discussions
- Final Round: Voting for elimination

You must stay in character and use your unique personality and skills to interact with others.
`

