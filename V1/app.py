from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np

# load model
model = joblib.load("vytal_model.pkl")

app = Flask(__name__)
CORS(app)

FEATURE_ORDER = [
    "chest_pain",
    "short_breath",
    "dizziness",
    "high_bp",
    "sweating",
    "nausea",
    "fatigue",
    "arm_pain",
    "jaw_pain",
    "irregular_heartbeat",
    "swelling_legs",
    "fainting"
]

# simple descriptions for user
TEST_EXPLANATIONS = {
    "ECG": "An Electrocardiogram checks the electrical activity of your heart.",
    "Holter_Monitor": "A Holter monitor records heart rhythm over 24 hours to detect irregular beats.",
    "Echocardiography": "An echocardiogram uses ultrasound to check heart pumping function.",
    "BP_Monitoring": "Blood pressure monitoring evaluates hypertension and cardiovascular risk.",
    "Lipid_Profile": "A lipid profile measures cholesterol levels to assess heart disease risk.",
    "Tilt_Table_Test": "A tilt table test evaluates fainting related to sudden blood pressure changes."
}

@app.route("/predict", methods=["POST"])
def predict():

    data = request.get_json()

    # create feature vector
    features = []
    for feature in FEATURE_ORDER:
        features.append(int(data.get(feature, 0)))

    features = np.array(features).reshape(1, -1)

    # prediction
    prediction = model.predict(features)[0]

    # probability confidence
    probabilities = model.predict_proba(features)[0]
    confidence = float(max(probabilities)) * 100

    response = {
        "recommended_test": prediction,
        "confidence": round(confidence, 2),
        "description": TEST_EXPLANATIONS.get(prediction, "")
    }

    return jsonify(response)

@app.route("/")
def home():
    return "Vytal Cardiac Screening API is running"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)