# 🛡️ PhishGuard XAI — AI-Powered Phishing Detection

<p align="center">
  <img src="https://img.shields.io/badge/ML-XGBoost-orange?style=for-the-badge&logo=python" />
  <img src="https://img.shields.io/badge/XAI-SHAP-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/badge/API-FastAPI-009688?style=for-the-badge&logo=fastapi" />
  <img src="https://img.shields.io/badge/F1_Score-1.000-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/AUC-1.000-brightgreen?style=for-the-badge" />
</p>

> **Detect phishing emails and messages in real-time** using an XGBoost classifier with full SHAP explainability — not just a verdict, but *why* it's phishing, with per-feature attribution scores.

---

## ✨ Features

| Feature | Details |
|---|---|
|  **ML Model** | XGBoost classifier trained on 37 hand-crafted NLP + structural features |
|  **SHAP Explainability** | Per-prediction feature contributions — see exactly what triggered the detection |
|  **FastAPI Backend** | REST API with `/analyze`, `/model-info`, and `/health` endpoints |
|  **Interactive Dashboard** | Single-file HTML frontend — no build step needed |
|  **Attack Taxonomy** | Auto-classifies into: Credential Harvesting, BEC/CEO Fraud, Malware Delivery, IT Impersonation, Advance Fee |
|  **4-Axis Risk Scoring** | Independent Urgency / Deception / Authority / Payload scores |
|  **Text Highlighting** | Highlights the exact words/phrases that triggered the detection |

---

##  Quick Start

### 1. Clone & install dependencies

```bash
git clone https://github.com/YOUR_USERNAME/phishguard-xai.git
cd phishguard-xai
pip install scikit-learn xgboost shap fastapi uvicorn python-multipart pandas numpy
```

### 2. Train the model

```bash
python train.py
```

This auto-generates inside `models/`:
- `phishguard_model.pkl` — trained XGBoost classifier
- `shap_explainer.pkl` — SHAP TreeExplainer
- `feature_names.json` — feature schema
- `training_report.json` — full metrics report

### 3. Start the API

```bash
uvicorn api.main:app --reload --port 8000
```

You should see:
```
Model loaded. F1=1.0, AUC=1.0
INFO: Uvicorn running on http://127.0.0.1:8000
```

### 4. Open the frontend

Just open `frontend/index.html` in your browser. The dashboard auto-connects to the API and shows a green **"ML API connected · F1=1"** badge when live.

> **Windows users:** `start chrome "frontend/index.html"`  
> **Mac users:** `open frontend/index.html`

---

##  Project Structure

```
phishguard/
├── api/
│   ├── __init__.py
│   └── main.py               # FastAPI backend — /analyze, /model-info, /health
├── data/
│   ├── __init__.py
│   ├── generate_dataset.py   # Synthetic dataset builder
│   └── emails.csv            # Generated after running train.py
├── models/
│   ├── __init__.py
│   ├── feature_extractor.py  # 37-feature NLP + structural extractor
│   ├── phishguard_model.pkl  # Generated after running train.py
│   ├── shap_explainer.pkl    # Generated after running train.py
│   ├── feature_names.json    # Generated after running train.py
│   └── training_report.json  # Generated after running train.py
├── frontend/
│   └── index.html            # Full interactive dashboard
├── train.py                  # Training pipeline — run this first
└── README.md
```

---

##  API Reference

### `POST /analyze`

Analyze a message for phishing indicators.

**Request:**
```json
{
  "body":    "Your account has been SUSPENDED. Verify IMMEDIATELY.",
  "subject": "URGENT: Verify now",
  "sender":  "security@bankofamerica-verify.net",
  "channel": "email"
}
```

**Response:**
```json
{
  "threat_score":     0.919,
  "threat_score_pct": 92,
  "verdict":          "PHISHING",
  "verdict_class":    "danger",
  "attack_types":     [{"label": "Credential Harvesting", "severity": "critical"}],
  "urgency_score":    80,
  "deception_score":  60,
  "authority_score":  30,
  "shap_values": [
    {"feature": "Sender Has Hyphen", "value": 2.076, "direction": "increases_risk"},
    {"feature": "Urgency Count",     "value": 0.122, "direction": "increases_risk"}
  ],
  "highlighted_spans":  ["..."],
  "recommendations":    ["..."]
}
```

### `GET /health`
```json
{"status": "healthy", "model_loaded": true, "f1_score": 1.0}
```

### `GET /model-info`
Returns the full training report — accuracy, F1, AUC, CV scores, top features.

Interactive Swagger docs available at: **`http://127.0.0.1:8000/docs`**

---

##  Model Performance

| Metric | Score |
|---|---|
| Accuracy | **100%** |
| F1-Score | **1.000** |
| ROC-AUC | **1.000** |
| CV F1 (5-fold) | **1.000 ± 0.000** |
| False Positive Rate | **0.0%** |

>  **Note:** Perfect scores are expected on the small synthetic dataset (53 samples).  
> With real-world PhishTank + CEAS-08 data (~10k+ samples), expect F1 ~0.97–0.99.

---

##  Feature Engineering (37 Features)

| Group | Features |
|---|---|
| **Urgency lexicon** | `urgency_count`, `threat_count` |
| **PII / payload** | `pii_count`, `macro_count`, `financial_count` |
| **Authority** | `authority_count`, `impersonates_brand` |
| **Social engineering** | `secrecy_count`, `safe_signal_count` |
| **URL analysis** | `suspicious_pattern`, `has_ip`, `suspicious_tld`, `entropy`, `hyphen_count` |
| **Sender metadata** | `sender_is_legit`, `sender_has_hyphen`, `sender_tld_suspicious` |
| **Structural** | `caps_ratio`, `exclamation_count`, `body_length`, `time_pressure` |
| **Derived** | `social_eng_score`, `credential_risk` |

---

## 🔬 XAI Methods

| Method | Purpose |
|---|---|
| **SHAP TreeExplainer** | Per-prediction feature contributions (± impact on threat score) |
| **XGBoost feature_importances_** | Global feature ranking across all training samples |
| **Highlighted text spans** | Exact words/phrases that triggered the detection |
| **Attack type taxonomy** | Classifies into 5 attack categories with severity levels |
| **Indicator scores** | Urgency / Deception / Authority / Payload — four independent risk axes |

---

##  Using Real-World Datasets

To upgrade from the synthetic dataset to real phishing data, swap the data loader in `train.py`:

```python
# Replace build_dataset() with this:
def load_kaggle_datasets():
    import pandas as pd
    df1 = pd.read_csv("data/dataset_phishing.csv")
    df1['label'] = (df1['status'] == 'phishing').astype(int)
    df1 = df1.drop(columns=['status', 'url'], errors='ignore')
    return df1
```

**Recommended datasets:**

| Dataset | Source | Size |
|---|---|---|
| PhishTank | https://www.phishtank.com | ~80k URLs |
| CEAS-08 | Email phishing benchmark | ~40k emails |
| Enron Corpus | Legitimate email baseline | ~500k emails |

---

##  References

- Lundberg & Lee (2017) — *A Unified Approach to Interpreting Model Predictions* (SHAP)
- Ribeiro et al. (2016) — *"Why Should I Trust You?" Explaining the Predictions of Any Classifier* (LIME)
- Fette et al. (2007) — *Learning to Detect Phishing Emails*
- Chen et al. (2016) — *XGBoost: A Scalable Tree Boosting System*

---

##  License

MIT License — free to use, modify, and distribute.
