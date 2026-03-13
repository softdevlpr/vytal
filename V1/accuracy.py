import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix, classification_report, accuracy_score, roc_auc_score, roc_curve, auc
from sklearn.preprocessing import label_binarize
from sklearn.multiclass import OneVsRestClassifier

# =========================
# 1. LOAD DATASET
# =========================
df = pd.read_csv("vytal_cardiac_dataset.csv")

X = df.drop("recommended_test", axis=1)
y = df["recommended_test"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# =========================
# 2. HYPERPARAMETER TUNING
# =========================
print("\n===== Hyperparameter Tuning (Decision Tree) =====")

param_grid = {
    'max_depth': [3,4,5,6,7],
    'min_samples_split': [2,5,10],
    'min_samples_leaf': [2,5,8,10],
    'criterion': ['gini','entropy']
}

grid = GridSearchCV(
    DecisionTreeClassifier(class_weight='balanced'),
    param_grid,
    cv=5,
    scoring='f1_macro'
)

grid.fit(X_train, y_train)

print("Best Parameters:", grid.best_params_)
print("Best CV Score:", grid.best_score_)

model = grid.best_estimator_

# =========================
# 3. FINAL MODEL PERFORMANCE
# =========================
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

print("\n===== Final Decision Tree Performance =====")
print("Accuracy:", accuracy_score(y_test, y_pred))
print(confusion_matrix(y_test, y_pred))
print(classification_report(y_test, y_pred))

# =========================
# 4. MODEL COMPARISON
# =========================
print("\n===== Model Comparison =====")

rf = RandomForestClassifier(n_estimators=150, class_weight='balanced', random_state=42)
rf.fit(X_train, y_train)

lr = LogisticRegression(max_iter=5000)
lr.fit(X_train, y_train)

print("Decision Tree Accuracy:", model.score(X_test,y_test))
print("Random Forest Accuracy:", rf.score(X_test,y_test))
print("Logistic Regression Accuracy:", lr.score(X_test,y_test))

# =========================
# 5. FEATURE IMPORTANCE
# =========================
print("\n===== Feature Importance =====")

importance = pd.Series(model.feature_importances_, index=X.columns)
importance = importance.sort_values(ascending=False)
print(importance)

# =========================
# 6. CROSS VALIDATION
# =========================
print("\n===== Cross Validation =====")

scores = cross_val_score(model, X, y, cv=10, scoring='f1_macro')
print("CV Scores:", scores)
print("CV Mean:", scores.mean())
print("CV Std Dev:", scores.std())

# =========================
# 7. ROC-AUC
# =========================
print("\n===== ROC-AUC =====")

classes = model.classes_
y_test_bin = label_binarize(y_test, classes=classes)
ovr = OneVsRestClassifier(model)
ovr.fit(X_train, label_binarize(y_train, classes=classes))
y_score = ovr.predict_proba(X_test)

roc = roc_auc_score(y_test_bin, y_score, average='macro', multi_class='ovr')
print("ROC-AUC (macro):", roc)

# =========================
# SAVE MODEL
# =========================
# joblib.dump(model, "vytal_model.pkl")
# print("\nModel saved as vytal_model.pkl")

# ======================================================
# 🔶 VISUALIZATIONS
# ======================================================

# 1️⃣ CONFUSION MATRIX HEATMAP
cm = confusion_matrix(y_test, y_pred)

plt.figure(figsize=(7,5))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=model.classes_,
            yticklabels=model.classes_)
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.title("Confusion Matrix Heatmap")
plt.tight_layout()
plt.show()


# 2️⃣ FEATURE IMPORTANCE BAR GRAPH
plt.figure(figsize=(8,6))
importance.sort_values().plot(kind='barh')
plt.title("Feature Importance (Symptoms influencing screening decision)")
plt.xlabel("Importance Score")
plt.tight_layout()
plt.show()


# 3️⃣ DECISION TREE VISUALIZATION
plt.figure(figsize=(20,10))
plot_tree(model,
          feature_names=X.columns,
          class_names=model.classes_,
          filled=True,
          rounded=True,
          fontsize=8)
plt.title("Decision Tree Clinical Logic")
plt.show()


# 4️⃣ ROC CURVES
plt.figure(figsize=(8,6))
for i in range(len(classes)):
    fpr, tpr, _ = roc_curve(y_test_bin[:, i], y_score[:, i])
    plt.plot(fpr, tpr, label=f"{classes[i]} (AUC={auc(fpr,tpr):.2f})")

plt.plot([0,1],[0,1],'k--')
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
plt.title("ROC Curve for Screening Categories")
plt.legend()
plt.tight_layout()
plt.show()


# 5️⃣ MODEL COMPARISON CHART
models = ["Decision Tree","Random Forest","Logistic Regression"]
scores_chart = [
    model.score(X_test,y_test),
    rf.score(X_test,y_test),
    lr.score(X_test,y_test)
]

plt.figure(figsize=(6,4))
plt.bar(models, scores_chart)
plt.ylabel("Accuracy")
plt.title("Model Comparison")
plt.ylim(0.9,1.0)
plt.tight_layout()
plt.show()