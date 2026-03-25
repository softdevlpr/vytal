import pandas as pd
from sklearn.tree import DecisionTreeClassifier

# Load dataset
df = pd.read_csv("vytal_screening_dataset.csv")

# Split input/output
X = df.drop("recommended_test", axis=1)
y = df["recommended_test"]

# Train model
model = DecisionTreeClassifier()
model.fit(X, y)

# Prediction function
def predict_test(user_input):
    input_df = pd.DataFrame([user_input])

    # Fill missing columns with 0
    for col in X.columns:
        if col not in input_df:
            input_df[col] = 0

    # Ensure same column order
    input_df = input_df[X.columns]

    prediction = model.predict(input_df)

    return prediction[0]
