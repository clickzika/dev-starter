# ML Starter Stack
# DevStarter — AI/ML Project Template
# Use for: Learning projects, prototypes, solo data scientists, small datasets

---

## Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | Python 3.11+ | ML standard |
| Package manager | uv | Fast, reproducible installs |
| Notebooks | JupyterLab | Exploration & reporting |
| ML framework | scikit-learn + XGBoost | Classical ML |
| Deep learning | PyTorch (optional) | Neural networks |
| Experiment tracking | MLflow (local) | Track runs locally |
| Data versioning | DVC (local remote) | Version datasets |
| Serving | FastAPI | REST inference endpoint |
| Validation | Pydantic + Pandera | Input + data validation |
| Testing | pytest | Unit + integration tests |
| Formatting | ruff + black | Code quality |

---

## Folder Structure

```
{{PROJECT_NAME}}/
├── data/
│   ├── raw/          # gitignored, DVC tracked
│   ├── processed/    # gitignored, DVC tracked
│   └── features/     # gitignored, DVC tracked
├── models/
│   ├── trained/      # gitignored, DVC tracked
│   └── evaluation/
├── notebooks/
│   ├── exploration/
│   └── experiments/
├── src/
│   ├── data/
│   ├── features/
│   ├── models/
│   └── serving/
├── tests/
├── configs/
├── dvc.yaml
├── MLproject
├── pyproject.toml
├── Makefile
└── .gitignore
```

---

## pyproject.toml

```toml
[project]
name = "{{PROJECT_NAME}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "scikit-learn>=1.4",
    "xgboost>=2.0",
    "pandas>=2.0",
    "numpy>=1.26",
    "pyarrow>=14.0",
    "mlflow>=2.9",
    "dvc>=3.0",
    "fastapi>=0.110",
    "uvicorn>=0.27",
    "pydantic>=2.0",
    "pandera>=0.18",
    "evidently>=0.4",
    "prometheus-client>=0.19",
    "pyyaml>=6.0",
    "loguru>=0.7",
]

[project.optional-dependencies]
torch = ["torch>=2.2", "torchvision>=0.17"]
dev = [
    "pytest>=8.0",
    "pytest-cov",
    "ruff>=0.3",
    "black>=24.0",
    "pre-commit",
    "ipykernel",
    "jupyter",
    "papermill>=2.5",
    "nbstripout",
]

[tool.ruff]
line-length = 100
select = ["E", "F", "I", "N", "W", "UP"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--cov=src --cov-report=term-missing"
```

---

## Makefile

```makefile
.PHONY: install setup data train evaluate serve test lint

install:
	uv sync --all-extras

setup:
	uv run dvc init
	uv run mlflow server --host 0.0.0.0 --port 5000 &
	uv run pre-commit install

data:
	uv run dvc repro ingest validate transform

train:
	uv run dvc repro train

evaluate:
	uv run dvc repro evaluate

serve:
	uv run uvicorn src.serving.api:app --reload --port 8000

test:
	uv run pytest

lint:
	uv run ruff check src/ tests/
	uv run black --check src/ tests/
```

---

## .gitignore additions

```
# Data (tracked by DVC)
data/raw/
data/processed/
data/features/
models/trained/

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# MLflow
mlruns/

# Python
__pycache__/
*.pyc
.venv/
```

---

## Getting Started

```bash
# 1. Install
uv sync --all-extras

# 2. Start MLflow tracking server
mlflow server --host 0.0.0.0 --port 5000

# 3. Run full pipeline
make data
make train
make evaluate

# 4. Start serving endpoint
make serve
# → http://localhost:8000/predict
# → http://localhost:8000/docs (Swagger)

# 5. View experiments
# → http://localhost:5000 (MLflow UI)
```
