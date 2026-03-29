"""
model/train_model.py
--------------------
Trains two Random Forest classifiers:
  1. urgency_model   → predicts Urgency (Urgent / Soon / Routine)
  2. tests_model     → predicts which tests to recommend (multi-label)

WHY RANDOM FOREST?
  - Your dataset has 1152 rows and 7 input features (1 categorical + 6 numeric).
  - Random Forest is ideal here because:
      • It handles small-to-medium datasets very well without overfitting
      • It works naturally with both categorical and numeric inputs after encoding
      • It gives feature importance — you can see which questions matter most
      • No scaling needed (unlike SVM or neural networks)
      • Fast to train and fast to predict
      • Interpretable — doctors/users can understand "Q1 was the most important factor"
  - For test recommendation it uses MultiOutputClassifier which trains one RF per test slot.

HOW TO RUN:
    cd cardiac_app/
    python model/train_model.py

OUTPUT:
    model/saved/urgency_model.pkl
    model/saved/tests_model.pkl
    model/saved/label_encoders.pkl
    model/saved/test_label_encoder.pkl
"""

import os
import sys
import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.multioutput import MultiOutputClassifier
from sklearn.preprocessing import LabelEncoder, OrdinalEncoder
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import classification_report, accuracy_score

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

CSV_PATH   = os.path.join(os.path.dirname(__file__), "../data/symptom_v5.csv")
SAVE_DIR   = os.path.join(os.path.dirname(__file__), "saved")
os.makedirs(SAVE_DIR, exist_ok=True)


def load_and_prepare():
    print("📂 Loading dataset...")
    df = pd.read_csv(CSV_PATH)
    print(f"   Rows: {len(df)}  |  Columns: {list(df.columns)}")

    # ── Encode primary symptom (categorical → integer) ──
    symptom_encoder = LabelEncoder()
    df["symptom_encoded"] = symptom_encoder.fit_transform(df["Primary Symptom"])

    # ── Feature matrix: symptom + Q1..Q6 ──
    feature_cols = ["symptom_encoded", "Q1", "Q2", "Q3", "Q4", "Q5", "Q6"]
    X = df[feature_cols].values

    # ── Target 1: Urgency ──
    urgency_encoder = LabelEncoder()
    y_urgency = urgency_encoder.fit_transform(df["Urgency"])

    # ── Target 2: Recommended Tests (up to 6, multi-label) ──
    test_cols = ["Recommended Test 1", "Recommended Test 2", "Recommended Test 3",
                 "Recommended Test 4", "Recommended Test 5", "Recommended Test 6"]

    # Fill blanks, encode each test column with its own encoder
    df[test_cols] = df[test_cols].fillna("None")
    test_encoders = {}
    y_tests_encoded = np.zeros((len(df), 6), dtype=int)

    for i, col in enumerate(test_cols):
        enc = LabelEncoder()
        y_tests_encoded[:, i] = enc.fit_transform(df[col])
        test_encoders[col] = enc

    label_encoders = {
        "symptom": symptom_encoder,
        "urgency": urgency_encoder,
    }

    return X, y_urgency, y_tests_encoded, label_encoders, test_encoders


def train():
    X, y_urgency, y_tests, label_encoders, test_encoders = load_and_prepare()

    # ── Train/test split ──
    X_train, X_test, yu_train, yu_test, yt_train, yt_test = train_test_split(
        X, y_urgency, y_tests, test_size=0.2, random_state=42, stratify=y_urgency
    )
    print(f"\n📊 Train: {len(X_train)} rows | Test: {len(X_test)} rows")

    # ─────────────────────────────────────────────
    # MODEL 1: Urgency Classifier
    # ─────────────────────────────────────────────
    print("\n🔧 Training Urgency Model (RandomForestClassifier)...")
    urgency_model = RandomForestClassifier(
        n_estimators=200,     # 200 decision trees
        max_depth=10,         # prevents overfitting
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1             # use all CPU cores
    )
    urgency_model.fit(X_train, yu_train)

    yu_pred = urgency_model.predict(X_test)
    urgency_acc = accuracy_score(yu_test, yu_pred)
    print(f"   ✅ Urgency Accuracy: {urgency_acc:.2%}")

    urgency_labels = label_encoders["urgency"].classes_
    print("\n   Classification Report:")
    print(classification_report(yu_test, yu_pred, target_names=urgency_labels))

    # Cross-validation
    cv_scores = cross_val_score(urgency_model, X, y_urgency, cv=5, scoring="accuracy")
    print(f"   5-Fold CV Accuracy: {cv_scores.mean():.2%} ± {cv_scores.std():.2%}")

    # Feature importance
    feature_names = ["Symptom", "Q1", "Q2", "Q3", "Q4", "Q5", "Q6"]
    importances = urgency_model.feature_importances_
    print("\n   Feature Importances:")
    for name, imp in sorted(zip(feature_names, importances), key=lambda x: -x[1]):
        bar = "█" * int(imp * 40)
        print(f"   {name:10} {bar} {imp:.3f}")

    # ─────────────────────────────────────────────
    # MODEL 2: Test Recommender (Multi-output RF)
    # ─────────────────────────────────────────────
    print("\n🔧 Training Test Recommender (MultiOutputClassifier)...")
    base_rf = RandomForestClassifier(
        n_estimators=200,
        max_depth=12,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1
    )
    tests_model = MultiOutputClassifier(base_rf, n_jobs=-1)
    tests_model.fit(X_train, yt_train)

    yt_pred = tests_model.predict(X_test)
    # Per-output accuracy
    per_output_acc = [accuracy_score(yt_test[:, i], yt_pred[:, i]) for i in range(6)]
    print(f"   ✅ Per-test-slot accuracy: {[f'{a:.0%}' for a in per_output_acc]}")
    print(f"   ✅ Mean test-slot accuracy: {sum(per_output_acc)/len(per_output_acc):.2%}")

    # ─────────────────────────────────────────────
    # Save everything
    # ─────────────────────────────────────────────
    joblib.dump(urgency_model,  os.path.join(SAVE_DIR, "urgency_model.pkl"))
    joblib.dump(tests_model,    os.path.join(SAVE_DIR, "tests_model.pkl"))
    joblib.dump(label_encoders, os.path.join(SAVE_DIR, "label_encoders.pkl"))
    joblib.dump(test_encoders,  os.path.join(SAVE_DIR, "test_label_encoders.pkl"))

    print(f"\n💾 Models saved to: {SAVE_DIR}/")
    print("   urgency_model.pkl")
    print("   tests_model.pkl")
    print("   label_encoders.pkl")
    print("   test_label_encoders.pkl")


if __name__ == "__main__":
    train()
