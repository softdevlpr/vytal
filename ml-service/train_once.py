import pandas as pd
from sklearn.tree import DecisionTreeClassifier
import pickle

df = pd.read_csv("vytal_final_dataset_v2_2.csv")

X = df.drop("recommended_test", axis=1)
y = df["recommended_test"]

model = DecisionTreeClassifier()
model.fit(X, y)

pickle.dump(model, open("model.pkl", "wb"))

print("Model saved!")
