# LiteLLM Multi-Provider Setup Guide
# DevStarter — Multi-Provider AI Support

## What is LiteLLM?

LiteLLM is a proxy that gives your application a single OpenAI-compatible API
while routing requests to any AI provider: Anthropic, OpenAI, Google, Azure,
AWS Bedrock, local Ollama, and 100+ others.

**Why use it:**
- Remove Claude/OpenAI lock-in from your application code
- Cost optimization: route to cheapest model per request type
- Fallback: automatically retry on a different provider if one fails
- Rate limit management across providers
- Single usage dashboard across all providers

---

## Quick Start

### Option A: Local CLI (development)

```bash
# Install
pip install litellm

# Copy config
cp ~/.claude/templates/litellm/litellm-config.yaml ./litellm-config.yaml

# Set API keys
export ANTHROPIC_API_KEY=sk-ant-...
export OPENAI_API_KEY=sk-...
export LITELLM_MASTER_KEY=sk-my-proxy-key   # Your own access key for the proxy

# Start proxy
litellm --config litellm-config.yaml --port 4000

# Test
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-my-proxy-key" \
  -H "Content-Type: application/json" \
  -d '{"model": "claude-sonnet", "messages": [{"role": "user", "content": "Hello"}]}'
```

### Option B: Docker Compose (staging / production)

```yaml
# docker-compose.litellm.yml
services:
  litellm:
    image: ghcr.io/berriai/litellm:main
    ports:
      - "4000:4000"
    volumes:
      - ./litellm-config.yaml:/app/config.yaml
    environment:
      ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY}
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      LITELLM_MASTER_KEY: ${LITELLM_MASTER_KEY}
      DATABASE_URL: ${DATABASE_URL}   # optional: PostgreSQL for usage logging
    command: ["--config", "/app/config.yaml", "--port", "4000"]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/health"]
      interval: 30s
      retries: 3
```

```bash
docker compose -f docker-compose.litellm.yml up -d
```

---

## Application Integration

### Node.js / TypeScript — drop-in OpenAI SDK replacement

```typescript
import OpenAI from 'openai';  // Same SDK, different baseURL

const client = new OpenAI({
  apiKey: process.env.LITELLM_API_KEY,
  baseURL: process.env.LITELLM_BASE_URL ?? 'http://localhost:4000/v1',
});

async function chat(prompt: string, model = 'claude-sonnet'): Promise<string> {
  const response = await client.chat.completions.create({
    model,  // Maps to your litellm model alias
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1024,
  });
  return response.choices[0].message.content ?? '';
}

// Switch providers by changing model name only:
await chat('Hello', 'claude-sonnet');  // → Anthropic
await chat('Hello', 'gpt-4o');         // → OpenAI
await chat('Hello', 'gemini-pro');     // → Google
await chat('Hello', 'default');        // → cheapest available
```

### Python — using OpenAI SDK

```python
from openai import OpenAI
import os

client = OpenAI(
    api_key=os.environ["LITELLM_API_KEY"],
    base_url=os.environ.get("LITELLM_BASE_URL", "http://localhost:4000/v1")
)

def chat(prompt: str, model: str = "claude-sonnet") -> str:
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content
```

### Python — using LiteLLM SDK directly (no proxy needed)

```python
from litellm import completion
import os

os.environ["ANTHROPIC_API_KEY"] = "sk-ant-..."
os.environ["OPENAI_API_KEY"] = "sk-..."

# Unified interface — same code, any provider
response = completion(
    model="claude-sonnet-4-6",    # or "gpt-4o", "gemini/gemini-2.0-flash"
    messages=[{"role": "user", "content": "Hello"}]
)
print(response.choices[0].message.content)
```

---

## .env Configuration

Add to your project `.env`:

```bash
# AI Provider (via LiteLLM proxy)
AI_PROVIDER=litellm
LITELLM_BASE_URL=http://localhost:4000/v1   # or your hosted proxy URL
LITELLM_API_KEY=sk-my-proxy-key             # the master_key from litellm-config.yaml

# Direct API keys (for LiteLLM proxy or SDK)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...

# Default model alias (from litellm-config.yaml model_list)
DEFAULT_AI_MODEL=claude-sonnet
```

---

## Provider Comparison

| Provider | Best For | Cost (input/1M tokens) | Notes |
|----------|----------|------------------------|-------|
| Claude Sonnet 4.6 | Complex reasoning, long context | ~$3 | Default for DevStarter |
| Claude Haiku 4.5 | Fast, cheap, simple tasks | ~$0.25 | Great for classification |
| GPT-4o | Tool use, structured output | ~$2.50 | Strong function calling |
| GPT-4o-mini | Simple tasks, high volume | ~$0.15 | Cost-optimized |
| Gemini 2.0 Flash | Fast, multimodal | ~$0.075 | Cheapest smart model |
| Llama 3.2 (Ollama) | Privacy, no API cost | Free | Self-hosted, no data sharing |

---

## Cost Optimization Patterns

### 1. Model Routing by Task Type

```typescript
// Route cheap tasks to cheap models, complex to powerful
async function intelligentChat(prompt: string, taskType: 'simple' | 'complex') {
  const model = taskType === 'simple' ? 'claude-haiku' : 'claude-sonnet';
  return chat(prompt, model);
}
```

### 2. Caching (reduce API calls)

```yaml
# Add to litellm-config.yaml
litellm_settings:
  cache: true
  cache_params:
    type: redis
    host: localhost
    port: 6379
    ttl: 3600   # Cache identical prompts for 1 hour
```

### 3. Fallback on Rate Limit

Already configured in `litellm-config.yaml` under `router_settings.fallbacks`.
LiteLLM automatically retries on a fallback model when primary is rate-limited.

---

## Usage Logging to PostgreSQL

```yaml
# litellm-config.yaml
general_settings:
  database_url: postgresql://user:password@localhost:5432/litellm_logs
```

Query usage:
```sql
SELECT model, SUM(total_tokens), SUM(spend), COUNT(*) as requests
FROM litellm_spendlogs
WHERE startTime > NOW() - INTERVAL '7 days'
GROUP BY model
ORDER BY spend DESC;
```

---

## GitHub Actions Integration

```yaml
# .github/workflows/deploy.yml
env:
  LITELLM_BASE_URL: ${{ secrets.LITELLM_BASE_URL }}
  LITELLM_API_KEY: ${{ secrets.LITELLM_API_KEY }}
  DEFAULT_AI_MODEL: claude-sonnet
```
