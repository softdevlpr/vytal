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

    # Fill missing first
    for col in X.columns:
        if col not in user_input:
            user_input[col] = 0

    #  Check after full input
    if all(value == 0 for value in user_input.values()):
        return "No Test Required (Healthy)"

    input_df = pd.DataFrame([user_input])
    input_df = input_df[X.columns]

    prediction = model.predict(input_df)

    return prediction[0]
