# dev-ml-workflow.md — AI/ML Project Workflow
# DevStarter MLOps Runbook

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## How to Use

Use when starting or working on an AI/ML project:
```
/new (select ML Starter or ML Standard stack)
/change add ML feature to existing project
```

---

## ⚠️ CRITICAL RULES

### Rule 1 — Data Never in Git
All datasets, feature files, and model artifacts go in DVC — never committed to git.
If you see a .csv, .parquet, .pkl, .pt, .h5 being git-added: STOP and set up DVC first.

### Rule 2 — Experiment Tracking is Mandatory
Every training run MUST be logged to MLflow/W&B before any model can be deployed.
"I'll add tracking later" = will never happen. Add it in the first training script.

### Rule 3 — No Production Training
Never retrain a model while it is serving predictions.
Always use shadow deployment or blue/green for model transitions.

### Rule 4 — Read Agent File First
Before any ML work, read `~/.claude/agents/devstarter-mlops.md`.

---

## PHASE 1 — ML Project Intake (extends Gate 1)

Additional questions for ML projects (after standard Gate 1 questions):

**ML-Q1. What type of ML problem?**
1. Classification (binary or multi-class)
2. Regression
3. Time-series forecasting
4. NLP / Text (classification, summarization, extraction, Q&A)
5. Computer Vision (classification, detection, segmentation)
6. Recommendation / Ranking
7. Generative AI / RAG
8. Anomaly detection / clustering
9. Reinforcement learning
10. Other — describe

**ML-Q2. What data do you have?**
- Source: [database / files / API / streams]
- Volume: [rows / GB / TBs]
- Labeled: [yes — how labeled / no — self-supervised / no — unsupervised]
- Update frequency: [static / daily / real-time]
- Historical period: [X months/years available]

**ML-Q3. What is the serving requirement?**
1. Batch inference (hourly / daily / weekly jobs)
2. Real-time online inference (< 200ms latency)
3. Both

**ML-Q4. What are the success metrics?**
- Business metric: [e.g. conversion rate lift, cost reduction]
- ML metric: [AUC, F1, RMSE, BLEU, etc.]
- Minimum acceptable performance: [e.g. AUC > 0.85]

**ML-Q5. Are there fairness / bias requirements?**
1. Yes — specify protected attributes and fairness constraints
2. No

**ML-Q6. What is the retraining strategy?**
1. Manual — retrain when performance drops
2. Scheduled — retrain every N days
3. Drift-triggered — retrain when data/model drift detected
4. Continuous — streaming retraining

---

## PHASE 2 — ML Stack Selection

Based on ML-Q1 to ML-Q6, select stack:

| Criteria | Stack |
|----------|-------|
| Learning project, solo data scientist | `ml-starter.md` |
| Production system, team, SLA-bound | `ml-standard.md` |
| LLM / RAG / generative AI | `ml-standard.md` + LiteLLM layer |

Read stack template: `~/.claude/templates/stacks/[stack].md`

---

## PHASE 3 — ML Architecture Documents (Gate 2 additions)

For ML projects, add these to the standard 9 Gate 2 documents:

**ML-DOC-1: ML System Design (`docs/ml-system-design.html`)**

Required sections:
1. Problem framing — task type, objective function, success criteria
2. Data architecture — sources, pipeline, storage, versioning strategy
3. Feature engineering — feature list with types, transformations, feature store
4. Model architecture — algorithm choice with rationale, baseline comparison
5. Training pipeline — steps, compute requirements, estimated runtime
6. Evaluation strategy — metrics, validation approach, statistical significance test
7. Serving architecture — latency budget, batch vs online, scaling plan
8. Retraining strategy — triggers, pipeline, approval gates
9. Monitoring plan — drift detection, performance tracking, alert thresholds
10. Rollback plan — version retention, rollback procedure

**ML-DOC-2: Data Validation Report (`docs/data-validation.html`)**

Required sections:
1. Dataset statistics — row count, column count, null rates, data types
2. Distribution analysis — histograms, outlier detection
3. Label distribution — class balance for classification
4. Train/val/test split — sizes, stratification strategy
5. Data quality issues found and remediation
6. Data schema (Pandera or Great Expectations schema)

---

## PHASE 4 — Development (Gate 4)

ML tasks follow this order within each sprint:

```
Task order for ML feature development:
  1. Data pipeline → validate → commit + DVC push
  2. Feature engineering → validate → commit + DVC push
  3. Baseline model (simple) → log to MLflow → commit
  4. Improved model → compare vs baseline in MLflow → commit
  5. Serving endpoint → test → commit
  6. Monitoring setup → test drift detection → commit
  7. CI pipeline → automated train on PR → commit
```

---

## PHASE 5 — Model Deployment Checklist

Before any model goes to production:

```
MODEL DEPLOYMENT CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━

Data:
[ ] Train/val/test split verified (no temporal leakage for time-series)
[ ] Data schema validated (Pandera / Great Expectations)
[ ] Dataset version tagged in DVC + pushed to remote
[ ] Data quality report in docs/data-validation.html

Training:
[ ] Experiment logged to MLflow/W&B (all hyperparameters, metrics, artifacts)
[ ] Model beats baseline on val set by statistically significant margin
[ ] Model registered in model registry with input signature
[ ] Evaluation report in docs/ml-evaluation.html

Serving:
[ ] Serving endpoint tested with production-representative inputs
[ ] Input validation rejects malformed requests (Pydantic)
[ ] P95 latency < 200ms (online) or throughput target met (batch)
[ ] Health check + /metrics endpoint available
[ ] Authentication configured

Monitoring:
[ ] Data drift detection deployed
[ ] Model performance metrics tracked
[ ] Alerting configured for drift > threshold
[ ] Prediction logs stored for future retraining

Deployment:
[ ] Shadow deployment run for 24h+ with no errors
[ ] Rollback procedure documented and tested
[ ] Previous model version retained in registry
[ ] Traffic split plan defined (A/B or canary %)
```

---

## PHASE 6 — Retraining Pipeline

Trigger retraining via:

```bash
# Manual trigger
python pipelines/train_pipeline.py --triggered-by=manual

# Drift-triggered (called by monitoring)
python pipelines/train_pipeline.py --triggered-by=drift --drift-score=0.42

# Scheduled (via Prefect/Airflow cron)
# See pipelines/train_pipeline.py for schedule definition
```

Retraining pipeline steps:
```
1. Pull latest data (DVC pull from remote)
2. Run data validation
3. Run feature pipeline
4. Train new model version
5. Evaluate: compare vs current production model
6. If new model wins → promote to Staging in registry
7. Run automated integration tests
8. Notify team: "New model candidate ready — [model version] — [metrics delta]"
9. Wait for human approval to promote Staging → Production
10. Deploy with shadow → canary → full rollout
```

---

## PHASE 7 — LLM / RAG Projects

For generative AI features, additional setup:

```bash
# 1. Start LiteLLM proxy (multi-provider routing)
# See: ~/.claude/templates/litellm/litellm-config.yaml
litellm --config ~/.claude/templates/litellm/litellm-config.yaml

# 2. Set up vector database
docker run -p 6333:6333 qdrant/qdrant

# 3. Build RAG ingestion pipeline
python src/rag/ingest.py --source docs/ --collection {{PROJECT_NAME}}

# 4. Test RAG endpoint
curl -X POST http://localhost:8000/rag/query \
  -H "Content-Type: application/json" \
  -d '{"query": "test question", "top_k": 5}'
```

RAG evaluation metrics to track:
- Answer relevance (RAGAS)
- Context precision (RAGAS)
- Context recall (RAGAS)
- Faithfulness (RAGAS)
- Latency: embedding + retrieval + generation separately

---

## Learned Patterns

<!-- Append new patterns discovered in ML sessions — ask user before modifying -->
