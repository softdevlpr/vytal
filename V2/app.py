from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np

# load multilabel model
model = joblib.load("V2/vytal_multilabel_model.pkl")

app = Flask(__name__)
CORS(app)

# =========================
# FEATURE ORDER
# =========================
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

# =========================
# TEST LABELS
# =========================
TEST_LABELS = [
    "ECG",
    "Troponin",
    "Chest_Xray",
    "BNP",
    "Holter_Monitor",
    "Echocardiography",
    "BP_Monitoring",
    "Tilt_Table_Test"
]

# =========================
# TEST DESCRIPTIONS
# =========================
TEST_EXPLANATIONS = {
    "ECG": "Electrocardiogram that measures electrical activity of the heart to detect rhythm issues or ischemia.",
    "Troponin": "Blood test used to detect damage to heart muscle, commonly used in suspected heart attacks.",
    "Chest_Xray": "Radiology imaging used to visualize heart size and detect fluid accumulation in lungs.",
    "BNP": "Brain Natriuretic Peptide blood test used to detect heart failure.",
    "Holter_Monitor": "Portable ECG device worn for 24–48 hours to detect intermittent arrhythmias.",
    "Echocardiography": "Ultrasound imaging of the heart to assess structure and pumping function.",
    "BP_Monitoring": "Blood pressure monitoring to evaluate hypertension and cardiovascular risk.",
    "Tilt_Table_Test": "Test used to evaluate unexplained fainting due to abnormal blood pressure regulation."
}

# =========================
# PREDICT ENDPOINT
# =========================
@app.route("/predict", methods=["POST"])
def predict():

    data = request.get_json()

    # build feature vector
    features = []
    for feature in FEATURE_ORDER:
        features.append(int(data.get(feature, 0)))

    features = np.array(features).reshape(1, -1)

    # get probabilities from each classifier
    probabilities = []

    for estimator in model.estimators_:
        prob = estimator.predict_proba(features)[0][1]
        probabilities.append(prob)

    # combine labels with probabilities
    results = []

    for label, prob in zip(TEST_LABELS, probabilities):

        results.append({
            "test": label,
            "probability": round(prob * 100, 2),
            "description": TEST_EXPLANATIONS.get(label, "")
        })

    # sort tests by probability
    results = sorted(results, key=lambda x: x["probability"], reverse=True)

    # categorize tests
    primary_tests = []
    secondary_tests = []
    optional_tests = []

    for r in results:

        p = r["probability"]

        if p >= 70:
            primary_tests.append(r)

        elif p >= 40:
            secondary_tests.append(r)

        elif p >= 20:
            optional_tests.append(r)

    response = {
        "primary_tests": primary_tests,
        "secondary_tests": secondary_tests,
        "optional_tests": optional_tests
    }

    return jsonify(response)


# =========================
# HEALTH CHECK
# =========================
@app.route("/")
def home():
    return "Vytal Cardiac Multi-Label Diagnostic API Running"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)