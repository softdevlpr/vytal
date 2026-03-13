import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression

from sklearn.metrics import (
    accuracy_score,
    f1_score,
    hamming_loss,
    jaccard_score,
    classification_report
)

from sklearn.multioutput import MultiOutputClassifier
from sklearn.preprocessing import label_binarize

# =========================
# 1. LOAD DATASET
# =========================

df = pd.read_csv("V2/cardiac_multilabel_dataset_noisy.csv")

# symptom columns
X = df.iloc[:,0:12]

# test columns
y = df.iloc[:,12:]

X_train, X_test, y_train, y_test = train_test_split(
    X,y,test_size=0.2,random_state=42
)

# =========================
# 2. HYPERPARAMETER TUNING
# =========================

print("\n===== Hyperparameter Tuning =====")

param_grid = {
    "estimator__max_depth":[3,4,5,6,7],
    "estimator__min_samples_split":[2,5,10],
    "estimator__min_samples_leaf":[1,2,5]
}

base_tree = DecisionTreeClassifier()

multi_model = MultiOutputClassifier(base_tree)

grid = GridSearchCV(
    multi_model,
    param_grid,
    cv=5,
    scoring="f1_micro"
)

grid.fit(X_train,y_train)

print("Best Parameters:",grid.best_params_)
model = grid.best_estimator_

# =========================
# 3. FINAL MODEL PERFORMANCE
# =========================

y_pred = model.predict(X_test)

print("\n===== Multi Label Performance =====")

print("Subset Accuracy:",accuracy_score(y_test,y_pred))
print("F1 Micro:",f1_score(y_test,y_pred,average="micro"))
print("F1 Macro:",f1_score(y_test,y_pred,average="macro"))
print("Hamming Loss:",hamming_loss(y_test,y_pred))
print("Jaccard Score:",jaccard_score(y_test,y_pred,average="samples", zero_division=0))

print("\nClassification Report")
print(classification_report(y_test,
                            y_pred,
                            target_names=y.columns, 
                            zero_division=0))

# =========================
# 4. MODEL COMPARISON
# =========================

print("\n===== Model Comparison =====")

rf = MultiOutputClassifier(RandomForestClassifier(n_estimators=150))
rf.fit(X_train,y_train)

lr = MultiOutputClassifier(LogisticRegression(max_iter=5000))
lr.fit(X_train,y_train)

print("Decision Tree F1:",f1_score(y_test,model.predict(X_test),average="micro"))
print("Random Forest F1:",f1_score(y_test,rf.predict(X_test),average="micro"))
print("Logistic Regression F1:",f1_score(y_test,lr.predict(X_test),average="micro"))

# =========================
# 5. FEATURE IMPORTANCE
# =========================

print("\n===== Feature Importance =====")

importances = np.mean(
    [tree.feature_importances_ for tree in model.estimators_],
    axis=0
)

importance = pd.Series(importances,index=X.columns).sort_values(ascending=False)

print(importance)

# =========================
# 6. CROSS VALIDATION
# =========================

print("\n===== Cross Validation =====")

scores = cross_val_score(model,X,y,cv=5,scoring="f1_micro")

print("CV Scores:",scores)
print("CV Mean:",scores.mean())
print("CV Std:",scores.std())

# =========================
# SAVE MODEL
# =========================

# joblib.dump(model,"vytal_multilabel_model_noisy.pkl")

# =========================
# VISUALIZATIONS
# =========================

# 1️⃣ FEATURE IMPORTANCE
plt.figure(figsize=(8,6))
importance.sort_values().plot(kind="barh")
plt.title("Symptom Importance")
plt.xlabel("Importance Score")
plt.tight_layout()
plt.show()

# 2️⃣ LABEL DISTRIBUTION
plt.figure(figsize=(8,5))
y.sum().sort_values().plot(kind="barh")
plt.title("Test Distribution")
plt.xlabel("Number of Cases")
plt.tight_layout()
plt.show()

# 3️⃣ PREDICTION DISTRIBUTION
pred_counts = pd.DataFrame(y_pred,columns=y.columns).sum()

plt.figure(figsize=(8,5))
pred_counts.sort_values().plot(kind="barh")
plt.title("Predicted Test Distribution")
plt.tight_layout()
plt.show()

# 4️⃣ MODEL COMPARISON GRAPH

models = ["Decision Tree","Random Forest","Logistic Regression"]

scores_chart = [
    f1_score(y_test,model.predict(X_test),average="micro"),
    f1_score(y_test,rf.predict(X_test),average="micro"),
    f1_score(y_test,lr.predict(X_test),average="micro")
]

plt.figure(figsize=(6,4))
plt.bar(models,scores_chart)
plt.ylabel("F1 Score")
plt.title("Model Comparison (Multi Label)")
plt.tight_layout()
plt.show()