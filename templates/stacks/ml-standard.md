# ML Standard Stack
# DevStarter — AI/ML Project Template
# Use for: Production ML systems, team projects, continuous retraining, SLA-bound serving

---

## Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | Python 3.11+ | ML standard |
| Package manager | uv | Fast, reproducible installs |
| ML frameworks | PyTorch / scikit-learn / HuggingFace | Training |
| Experiment tracking | MLflow (remote) or W&B | Track all runs |
| Data versioning | DVC + S3/GCS/Azure | Version datasets + models |
| Orchestration | Prefect 2 or Airflow 2 | Pipeline scheduling |
| Feature store | Feast | Feature sharing across services |
| Serving | BentoML or Triton | Production model serving |
| Monitoring | Evidently + Prometheus + Grafana | Drift + performance |
| Vector DB | Qdrant (for RAG/embedding workloads) | Semantic search |
| Container | Docker | Reproducible environments |
| CI/CD | GitHub Actions | Automated train + deploy |
| Secrets | Per project.env SECRETS_BACKEND | See secrets templates |

---

## LLM / RAG Extension

Add these when building LLM-based features:

| Component | Technology |
|-----------|-----------|
| LLM routing | LiteLLM proxy (see `~/.claude/templates/litellm/`) |
| RAG pipeline | LangChain / LlamaIndex |
| Vector DB | Qdrant (self-hosted) or Pinecone (managed) |
| Embeddings | OpenAI text-embedding-3-small or local (sentence-transformers) |
| Evaluation | RAGAS + DeepEval |
| Prompt tracking | LangSmith or MLflow AI gateway |

---

## Folder Structure

```
{{PROJECT_NAME}}/
├── data/
│   ├── raw/              # DVC tracked → S3/GCS
│   ├── processed/        # DVC tracked
│   └── features/         # DVC tracked
├── models/
│   ├── trained/          # DVC tracked
│   └── evaluation/       # Reports, plots
├── notebooks/
│   ├── exploration/      # EDA
│   ├── experiments/      # Named experiments
│   └── reports/          # Final stakeholder reports
├── src/
│   ├── data/
│   │   ├── ingest.py
│   │   ├── validate.py
│   │   └── transform.py
│   ├── features/
│   │   ├── build.py
│   │   └── store.py       # Feast integration
│   ├── models/
│   │   ├── train.py
│   │   ├── evaluate.py
│   │   └── registry.py
│   ├── serving/
│   │   ├── service.py     # BentoML service
│   │   └── schemas.py
│   └── monitoring/
│       ├── drift.py
│       └── metrics.py
├── pipelines/
│   ├── train_pipeline.py  # Prefect/Airflow DAG
│   └── deploy_pipeline.py
├── tests/
│   ├── test_data.py
│   ├── test_features.py
│   ├── test_model.py
│   └── test_serving.py
├── configs/
│   ├── model.yaml
│   ├── data.yaml
│   └── serving.yaml
├── .github/workflows/
│   ├── train.yml          # Triggered on data/code change
│   └── deploy.yml         # Triggered on model promotion
├── dvc.yaml
├── feast.yaml             # Feature store config
├── bentofile.yaml         # BentoML build config
├── pyproject.toml
└── Makefile
```

---

## CI/CD: Automated Training + Deployment

```yaml
# .github/workflows/train.yml
name: Train and Evaluate Model

on:
  push:
    paths:
      - 'src/**'
      - 'configs/**'
      - 'dvc.yaml'

jobs:
  train:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install uv
        run: pip install uv && uv sync

      - name: Configure DVC remote (AWS)
        run: |
          uv run dvc remote modify myremote access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
          uv run dvc remote modify myremote secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Pull data
        run: uv run dvc pull

      - name: Run pipeline
        run: uv run dvc repro
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
          MLFLOW_EXPERIMENT_NAME: ${{ github.ref_name }}

      - name: Push metrics
        run: uv run dvc push

      - name: Check model performance
        run: uv run python scripts/check_performance.py --min-auc 0.85
```

---

## Model Serving with BentoML

```python
# src/serving/service.py
import bentoml
import numpy as np
from pydantic import BaseModel

runner = bentoml.mlflow.get("{{MODEL_NAME}}:latest").to_runner()

svc = bentoml.Service("{{PROJECT_NAME}}_service", runners=[runner])

class Input(BaseModel):
    features: list[float]

class Output(BaseModel):
    prediction: int
    probability: float

@svc.api(input=bentoml.io.JSON(pydantic_model=Input), output=bentoml.io.JSON(pydantic_model=Output))
async def predict(input_data: Input) -> Output:
    arr = np.array([input_data.features])
    result = await runner.async_run(arr)
    return Output(prediction=int(result[0]), probability=float(result[1].max()))
```

---

## Data Quality Checks (Pandera)

```python
# src/data/validate.py
import pandera as pa
from pandera.typing import DataFrame, Series
import pandas as pd

class InputSchema(pa.DataFrameModel):
    user_id: Series[int] = pa.Field(gt=0, nullable=False)
    age: Series[float] = pa.Field(ge=0, le=120, nullable=True)
    feature_1: Series[float] = pa.Field(nullable=False)
    feature_2: Series[float] = pa.Field(nullable=False)
    label: Series[int] = pa.Field(isin=[0, 1], nullable=False)

    class Config:
        coerce = True
        strict = "filter"

@pa.check_types
def validate_dataset(df: DataFrame[InputSchema]) -> DataFrame[InputSchema]:
    null_rates = df.isnull().mean()
    high_null = null_rates[null_rates > 0.20]
    if not high_null.empty:
        raise ValueError(f"High null rate columns: {high_null.to_dict()}")
    return df
```

---

## Monitoring Dashboard (Grafana)

Key panels to include in `dashboards/ml-model.json`:

```
Panel 1: Prediction Volume (requests/min)
Panel 2: Prediction Latency P50/P95/P99
Panel 3: Error Rate (4xx, 5xx)
Panel 4: Data Drift Score (feature-wise)
Panel 5: Model Performance (rolling AUC/accuracy)
Panel 6: Retraining Pipeline Status
Panel 7: Active Model Version
Panel 8: Prediction Distribution Over Time
```

---

## Deployment Strategies for ML

| Strategy | When to Use | Risk |
|----------|-------------|------|
| Shadow deployment | New model candidate, high-stakes decision | Zero — no real traffic affected |
| A/B test | Comparing 2 models on real traffic | Low — controlled split |
| Canary | Gradual rollout after A/B validation | Low — can halt at any % |
| Blue/green | Full cutover with instant rollback | Medium — hard switch |
| Direct replace | Internal tools, non-critical predictions | Medium — no safety net |

**Always use shadow → A/B → canary for customer-facing models.**
