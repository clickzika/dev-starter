# dev-ai-providers.md — Multi-Provider AI Support
# DevStarter — Provider Selection & Routing Runbook

## Model: Sonnet (`claude-sonnet-4-6`)

## How to Use

When a project uses AI features (LLMs, embeddings, image generation):
```
/new (select AI_PROVIDER in project setup)
/change add LiteLLM multi-provider support
```

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## ⚠️ CRITICAL RULES

### Rule 1 — Never Hardcode Provider SDK
Application code MUST import from a provider-agnostic layer.
Never: `import Anthropic from '@anthropic-ai/sdk'` directly in business logic.
Always: wrap in a service that reads `AI_PROVIDER` from config.

### Rule 2 — API Keys via Secrets Backend
AI provider API keys follow the same rules as all secrets:
- Stored in secrets backend (Phase 6 of devstarter-secrets.md)
- Never hardcoded, never committed to git
- Rotated on a schedule

### Rule 3 — Track Costs
Every production AI application MUST have usage logging.
Unexpected cost spikes = runaway loops or prompt injection attacks.
Set hard budget limits at the provider level (OpenAI usage limits, Anthropic spending limits).

---

## PHASE 1 — Provider Selection

Choose based on:

| Priority | Provider | When to Choose |
|----------|----------|---------------|
| Default | Claude (Anthropic) | Best reasoning, long context, multimodal |
| Cost-sensitive | Gemini 2.0 Flash | Cheapest smart model, high volume |
| Tooling/Functions | GPT-4o | Strongest function calling and JSON mode |
| Privacy / On-prem | Ollama (local) | No data leaves your environment |
| Multi-provider | LiteLLM proxy | Want to mix providers or need fallback |

**DevStarter default: Claude Sonnet 4.6 via Anthropic API.**

---

## PHASE 2 — LiteLLM Proxy Setup

For multi-provider projects, set up LiteLLM proxy:

```bash
# 1. Copy config template
cp ~/.claude/templates/litellm/litellm-config.yaml ./litellm-config.yaml

# 2. Customize: add/remove models, set routing strategy
# See: ~/.claude/templates/litellm/provider-setup.md

# 3. Set environment variables
echo "LITELLM_MASTER_KEY=$(openssl rand -base64 32)" >> .env
echo "AI_PROVIDER=litellm" >> .project.env
echo "LITELLM_BASE_URL=http://localhost:4000/v1" >> .env

# 4. Start proxy
litellm --config litellm-config.yaml --port 4000
# or
docker compose -f docker-compose.litellm.yml up -d
```

---

## PHASE 3 — Application AI Service Layer

Create a provider-agnostic AI service in your application:

### Node.js / TypeScript pattern

```typescript
// src/services/ai.service.ts
import OpenAI from 'openai';
import { env } from '../config/env';

const client = new OpenAI({
  apiKey: env.LITELLM_API_KEY ?? env.ANTHROPIC_API_KEY,
  baseURL: env.LITELLM_BASE_URL ?? 'https://api.anthropic.com/v1',
});

export interface ChatOptions {
  model?: string;
  maxTokens?: number;
  temperature?: number;
  systemPrompt?: string;
}

export async function chat(
  userMessage: string,
  options: ChatOptions = {}
): Promise<string> {
  const {
    model = env.DEFAULT_AI_MODEL ?? 'claude-sonnet',
    maxTokens = 1024,
    temperature = 0.7,
    systemPrompt,
  } = options;

  const messages: OpenAI.Chat.ChatCompletionMessageParam[] = [];
  if (systemPrompt) messages.push({ role: 'system', content: systemPrompt });
  messages.push({ role: 'user', content: userMessage });

  const response = await client.chat.completions.create({
    model,
    messages,
    max_tokens: maxTokens,
    temperature,
  });

  return response.choices[0].message.content ?? '';
}

export async function embed(text: string): Promise<number[]> {
  const response = await client.embeddings.create({
    model: env.DEFAULT_EMBED_MODEL ?? 'text-embedding-3-small',
    input: text,
  });
  return response.data[0].embedding;
}
```

### Python pattern

```python
# src/services/ai_service.py
from openai import OpenAI
import os
from dataclasses import dataclass
from typing import Optional

@dataclass
class ChatOptions:
    model: str = None
    max_tokens: int = 1024
    temperature: float = 0.7
    system_prompt: Optional[str] = None

class AIService:
    def __init__(self):
        self.client = OpenAI(
            api_key=os.environ.get("LITELLM_API_KEY") or os.environ["ANTHROPIC_API_KEY"],
            base_url=os.environ.get("LITELLM_BASE_URL", "https://api.anthropic.com/v1")
        )
        self.default_model = os.environ.get("DEFAULT_AI_MODEL", "claude-sonnet")

    def chat(self, message: str, options: ChatOptions = None) -> str:
        opts = options or ChatOptions()
        model = opts.model or self.default_model

        messages = []
        if opts.system_prompt:
            messages.append({"role": "system", "content": opts.system_prompt})
        messages.append({"role": "user", "content": message})

        response = self.client.chat.completions.create(
            model=model,
            messages=messages,
            max_tokens=opts.max_tokens,
            temperature=opts.temperature
        )
        return response.choices[0].message.content

ai = AIService()
```

---

## PHASE 4 — Switching Providers

To switch provider for a specific project:

```bash
# Option A: Switch to OpenAI
# In .project.env:
AI_PROVIDER=openai
# In .env:
OPENAI_API_KEY=sk-...
DEFAULT_AI_MODEL=gpt-4o

# Option B: Switch to local Ollama (no API cost, privacy)
# Install Ollama: https://ollama.ai
ollama pull llama3.2
# In .project.env:
AI_PROVIDER=litellm
LITELLM_BASE_URL=http://localhost:11434/v1
DEFAULT_AI_MODEL=llama3.2

# Option C: Switch to Google Gemini
AI_PROVIDER=gemini
GOOGLE_API_KEY=...
DEFAULT_AI_MODEL=gemini-pro

# No application code changes needed — only .env / .project.env updates
```

---

## PHASE 5 — Cost Controls

### Set provider-level spending limits

```bash
# Anthropic: set via Console → Settings → Limits
# OpenAI: set via Platform → Usage limits
# Both support email alerts at threshold percentages

# LiteLLM proxy: add budget per API key
curl -X POST http://localhost:4000/key/generate \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -d '{"max_budget": 10.0, "budget_duration": "30d", "key_alias": "app-prod"}'
```

### Rate limit protection in application

```typescript
// src/services/ai.service.ts — add rate limit wrapper
import Bottleneck from 'bottleneck';

const limiter = new Bottleneck({
  maxConcurrent: 5,           // max concurrent AI requests
  minTime: 100,               // min 100ms between requests
  reservoir: 100,             // tokens per window
  reservoirRefreshAmount: 100,
  reservoirRefreshInterval: 60 * 1000, // refill every 60s
});

export const chat = limiter.wrap(_chat);
```

---

## PHASE 6 — Provider Update Checklist

When rotating/changing AI provider:

```
AI PROVIDER ROTATION CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ ] New provider API key stored in secrets backend (not .env committed to git)
[ ] LiteLLM config updated with new model alias
[ ] Application-level model aliases unchanged (app uses "claude-sonnet", not "claude-sonnet-4-6")
[ ] Tested: new provider returns expected response format
[ ] Tested: fallback routes work (primary → secondary provider)
[ ] Cost alerts configured at new provider console
[ ] Usage logging verified (LiteLLM logs show new provider)
[ ] Old API key revoked at old provider console
```
