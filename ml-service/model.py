import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from collections import OrderedDict
import pickle

test_descriptions = {
    "No Test Required": "You do not appear to have any concerning symptoms. No medical test is needed at this time.",
    "Basic Cardiac Checkup": "A routine evaluation of heart health including basic tests and physical examination to detect early heart issues.",
    "ECG": "Records the electrical activity of the heart to identify irregular rhythms or heart-related problems.",
    "ECG + Troponin Test": "Combines heart activity monitoring with a blood test to detect heart muscle damage, often used in suspected heart attacks.",
    "Chest X-ray": "An imaging test used to examine the lungs, heart, and chest structure for infections or abnormalities.",
    "Chest X-ray + Echo": "A combination of imaging and ultrasound to evaluate both lung condition and heart structure/function.",
    "CBC Test": "A blood test that measures different components of blood to detect infections, anemia, or other conditions.",
    "MRI Brain + ECG": "Brain imaging along with heart monitoring to evaluate causes like dizziness, fainting, or neurological issues.",
    "BP Check": "A simple measurement of blood pressure to check for hypertension or low blood pressure.",
    "Blood Pressure Monitoring + Lipid Profile": "Tracks blood pressure over time and checks cholesterol levels to assess heart disease risk.",
    "General Checkup": "A routine health examination to assess overall well-being and detect any underlying issues.",
    "Blood Test": "A general test to analyze blood for infections, deficiencies, or other health conditions."
}

# Load dataset
df = pd.read_csv("vytal_final_dataset_v2_2.csv")

# Split input/output
X = df.drop("recommended_test", axis=1)
y = df["recommended_test"]



# Load pre-trained model
model = pickle.load(open("model.pkl", "rb"))
# Prediction function
def predict_test(user_input):

    # Fill missing columns
    for col in X.columns:
        if col not in user_input:
            user_input[col] = 0

    # Healthy case
    if all(value == 0 for value in user_input.values()):
        return {
            "test": "No Test Required",
            "description": "You do not appear to have any concerning symptoms."
        }

    input_df = pd.DataFrame([user_input])
    input_df = input_df[X.columns]

    prediction = model.predict(input_df)
    predicted_test = prediction[0]

    
    return OrderedDict([
    ("test", predicted_test),
    ("description", test_descriptions.get(predicted_test, "No description available"))
    ])

pickle.dump(model, open("model.pkl", "wb"))
