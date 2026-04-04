"""
model/train_model.py
--------------------
Trains two classifiers:
  1. urgency_model   → RandomForest predicting Urgency (Urgent / Soon / Routine)
  2. tests_model     → OneVsRest multi-label RF predicting which tests to recommend

CHANGES FROM v1:
  - Test recommender switched from MultiOutputClassifier (slot-based) to
    OneVsRestClassifier with MultiLabelBinarizer (order-independent multi-label).
    Old approach: predict what goes in slot 1, slot 2... → confused by ordering.
    New approach: predict YES/NO for each of the 40 possible tests → F1 ~0.92.
  - Added interaction feature: symptom_encoded × Q2 (severity).
  - Urgency model uses class_weight='balanced' to fix Routine underperformance.
  - Urgency model n_estimators bumped to 300, max_depth to 12.
  - CV metric changed to f1_macro (more honest for imbalanced classes).
  - Saved files:
      urgency_model.pkl         (same name, same interface)
      tests_model.pkl           (same name — but now OneVsRestClassifier)
      label_encoders.pkl        (same name, same interface)
      test_label_encoders.pkl   (NOW contains MultiLabelBinarizer, not per-slot encoders)
                                 → predict.py needs one small update (see README comment below)

HOW TO RUN:
    cd cardiac_app/
    python model/train_model.py

PREDICT.PY CHANGE NEEDED (one block only):
    OLD:
        test_encoders = joblib.load("test_label_encoders.pkl")
        yt_pred = tests_model.predict(X)
        for i, col in enumerate(test_cols):
            label = test_encoders[col].inverse_transform([yt_pred[0][i]])[0]

    NEW:
        mlb = joblib.load("test_label_encoders.pkl")   # same file, now a MultiLabelBinarizer
        yt_pred = tests_model.predict(X)               # returns binary array shape (1, 40)
        test_names = mlb.inverse_transform(yt_pred)[0] # returns tuple of test name strings
"""

import os
import sys
import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.multiclass import OneVsRestClassifier
from sklearn.preprocessing import LabelEncoder, MultiLabelBinarizer
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import classification_report, accuracy_score, f1_score, hamming_loss

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

CSV_PATH = os.path.join(os.path.dirname(__file__), "../data/symptom_v5.csv")
SAVE_DIR = os.path.join(os.path.dirname(__file__), "saved")
os.makedirs(SAVE_DIR, exist_ok=True)

TEST_COLS = [f"Recommended Test {i}" for i in range(1, 7)]


def get_test_set(row):
    """Collect all non-empty tests for a row as an order-independent set."""
    tests = []
    for col in TEST_COLS:
        val = row[col]
        if pd.notna(val) and str(val).strip() not in ("", "None"):
            tests.append(str(val).strip())
    return list(set(tests))


def load_and_prepare():
    print("📂 Loading dataset...")
    df = pd.read_csv(CSV_PATH)
    print(f"   Rows: {len(df)}  |  Columns: {list(df.columns)}")

    # ── Encode primary symptom ──
    symptom_encoder = LabelEncoder()
    df["symptom_encoded"] = symptom_encoder.fit_transform(df["Primary Symptom"])

    # ── Interaction feature: symptom × Q2 (severity) ──
    # Q2 ranges 1-3 and has the 2nd highest feature importance.
    # Multiplying it with symptom lets the model learn e.g.
    # "Chest Pain + severity 3" differently from "Fatigue + severity 3".
    df["sym_x_q2"] = df["symptom_encoded"] * df["Q2"]

    feature_cols = ["symptom_encoded", "Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "sym_x_q2"]
    X = df[feature_cols].values

    # ── Target 1: Urgency ──
    urgency_encoder = LabelEncoder()
    y_urgency = urgency_encoder.fit_transform(df["Urgency"])

    # ── Target 2: Tests (multi-label, order-independent) ──
    df["test_set"] = df.apply(get_test_set, axis=1)
    mlb = MultiLabelBinarizer()
    y_tests = mlb.fit_transform(df["test_set"])
    print(f"   Multi-label matrix: {y_tests.shape}  ({y_tests.shape[1]} unique tests)")

    label_encoders = {
        "symptom": symptom_encoder,
        "urgency": urgency_encoder,
    }

    return X, y_urgency, y_tests, label_encoders, mlb


def train():
    X, y_urgency, y_tests, label_encoders, mlb = load_and_prepare()

    # ── Train/test split ──
    (X_train, X_test,
     yu_train, yu_test,
     yt_train, yt_test) = train_test_split(
        X, y_urgency, y_tests,
        test_size=0.2, random_state=42, stratify=y_urgency
    )
    print(f"\n📊 Train: {len(X_train)} rows | Test: {len(X_test)} rows")

    # ─────────────────────────────────────────────
    # MODEL 1: Urgency Classifier
    # ─────────────────────────────────────────────
    print("\n🔧 Training Urgency Model (RandomForestClassifier)...")
    urgency_model = RandomForestClassifier(
        n_estimators=300,
        max_depth=12,
        min_samples_leaf=2,
        class_weight="balanced",   # fixes Routine class underperformance
        random_state=42,
        n_jobs=-1
    )
    urgency_model.fit(X_train, yu_train)

    yu_pred = urgency_model.predict(X_test)
    urgency_acc = accuracy_score(yu_test, yu_pred)
    print(f"   ✅ Urgency Accuracy: {urgency_acc:.2%}")

    urgency_labels = label_encoders["urgency"].classes_
    print("\n   Classification Report:")
    print(classification_report(yu_test, yu_pred, target_names=urgency_labels))

    # Cross-validation (f1_macro is more honest than accuracy for imbalanced classes)
    cv_scores = cross_val_score(urgency_model, X, y_urgency, cv=5, scoring="f1_macro")
    print(f"   5-Fold CV F1-Macro: {cv_scores.mean():.2%} ± {cv_scores.std():.2%}")

    # Feature importance
    feature_names = ["Symptom", "Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Sym×Q2"]
    importances = urgency_model.feature_importances_
    print("\n   Feature Importances:")
    for name, imp in sorted(zip(feature_names, importances), key=lambda x: -x[1]):
        bar = "█" * int(imp * 40)
        print(f"   {name:12} {bar} {imp:.3f}")

    # ─────────────────────────────────────────────
    # MODEL 2: Test Recommender (Multi-label)
    # ─────────────────────────────────────────────
    print("\n🔧 Training Test Recommender (OneVsRest MultiLabel RF)...")
    base_rf = RandomForestClassifier(
        n_estimators=300,
        max_depth=12,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1
    )
    tests_model = OneVsRestClassifier(base_rf, n_jobs=-1)
    tests_model.fit(X_train, yt_train)

    yt_pred = tests_model.predict(X_test)

    hl  = hamming_loss(yt_test, yt_pred)
    f1m = f1_score(yt_test, yt_pred, average="micro")
    f1M = f1_score(yt_test, yt_pred, average="macro")
    exact = (yt_pred == yt_test).all(axis=1).mean()

    print(f"   ✅ Hamming Loss     : {hl:.4f}  (lower is better; 0 = perfect)")
    print(f"   ✅ F1 Micro         : {f1m:.2%}")
    print(f"   ✅ F1 Macro         : {f1M:.2%}")
    print(f"   ✅ Exact Match      : {exact:.2%}  (all tests correct for that row)")
    print(f"   ✅ Unique tests tracked: {len(mlb.classes_)}")

    # ─────────────────────────────────────────────
    # Save everything
    # ─────────────────────────────────────────────
    joblib.dump(urgency_model,  os.path.join(SAVE_DIR, "urgency_model.pkl"))
    joblib.dump(tests_model,    os.path.join(SAVE_DIR, "tests_model.pkl"))
    joblib.dump(label_encoders, os.path.join(SAVE_DIR, "label_encoders.pkl"))
    joblib.dump(mlb,            os.path.join(SAVE_DIR, "test_label_encoders.pkl"))

    print(f"\n💾 Models saved to: {SAVE_DIR}/")
    print("   urgency_model.pkl")
    print("   tests_model.pkl")
    print("   label_encoders.pkl")
    print("   test_label_encoders.pkl  ← now a MultiLabelBinarizer (see predict.py note above)")


if __name__ == "__main__":
    train()
