"""
model/predict.py
----------------
Loads the trained models and makes predictions for a given symptom + answers.
"""

import os
import sys
import joblib
import numpy as np

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

SAVE_DIR = os.path.join(os.path.dirname(__file__), "saved")

# ── Test descriptions ──────────────────────────────────────
TEST_DESCRIPTIONS = {
    "ECG": "Records your heart's electrical activity to detect irregularities in rhythm or signs of a heart attack.",
    "Troponin Blood Test": "A blood test that detects proteins released when heart muscle is damaged — key marker for heart attacks.",
    "Stress Test (TMT)": "You walk on a treadmill while your heart is monitored to check how it performs under physical stress.",
    "Chest X-Ray": "An imaging scan of your chest to check the size of your heart and look for fluid in or around the lungs.",
    "Echocardiogram": "An ultrasound of your heart that shows how well it is pumping and whether valves are working properly.",
    "Coronary Angiography": "A procedure using dye and X-rays to see if any arteries supplying your heart are blocked or narrowed.",
    "Lipid Panel": "A blood test that measures your cholesterol and triglyceride levels to assess your risk of heart disease.",
    "CT Coronary Angiography": "A detailed CT scan that creates 3D images of the arteries around your heart to detect blockages.",
    "BNP Test": "A blood test that measures a hormone released by your heart when it is under strain — used to detect heart failure.",
    "Pulse Oximetry": "A simple clip placed on your finger to measure the oxygen level in your blood within seconds.",
    "D-Dimer Test": "A blood test that checks for abnormal blood clotting — used to rule out a pulmonary embolism.",
    "Spirometry": "A breathing test where you blow into a device to measure how much air your lungs can hold.",
    "Complete Blood Count (CBC)": "A blood test that checks your red cells, white cells, and platelets — helps detect anemia or infection.",
    "24-hr BP Monitoring": "A small device worn on your arm for 24 hours that records your blood pressure at regular intervals.",
    "Fasting Blood Glucose": "A blood test taken after fasting overnight to check your blood sugar level.",
    "Brain MRI": "A detailed scan of your brain using magnetic fields — used to rule out neurological causes of dizziness.",
    "Carotid Ultrasound": "An ultrasound of the arteries in your neck to check for plaque buildup.",
    "Thyroid Function Tests": "A blood test that measures your thyroid hormone levels.",
    "Holter Monitor": "A small wearable device that records your heart's rhythm continuously for 24–48 hours.",
    "Kidney Function Tests": "A blood test that checks how well your kidneys are filtering waste.",
    "Urine Analysis": "A urine test that checks for protein, blood, or other markers.",
    "Fundoscopy (Eye exam)": "A doctor examines the blood vessels at the back of your eye.",
    "Brain CT Scan": "A quick CT scan of the brain to rule out bleeding, stroke, or neurological problems.",
    "Cortisol Level Test": "A blood test that measures your stress hormone (cortisol) levels.",
    "Liver Function Tests": "A blood panel that checks whether your liver is working properly.",
    "Serum Electrolytes": "A blood test measuring minerals like sodium and potassium.",
    "Abdominal Ultrasound": "An ultrasound scan of your abdomen to check organs as a cause of nausea.",
    "H. Pylori Test": "A breath or stool test to check for stomach bacteria that causes nausea.",
    "Iron Studies": "A blood test that checks your iron stores — low iron causes fatigue.",
    "Vitamin B12/D Test": "A blood test to check your B12 and Vitamin D levels.",
    "Nerve Conduction Study": "A test that measures how fast electrical signals travel through your nerves.",
    "X-Ray (Shoulder/Arm)": "An X-ray of your shoulder or arm to check for bone or muscle issues.",
    "Dental X-Ray": "An X-ray of your jaw and teeth to rule out dental problems.",
    "TMJ Evaluation": "An assessment of your jaw joint to check if jaw pain is structural.",
    "Cardiac MRI": "A detailed MRI scan of your heart to assess its structure and muscle health.",
    "EP Study": "An electrophysiology study that maps the electrical pathways of your heart.",
    "Doppler Ultrasound (legs)": "An ultrasound of the blood vessels in your legs to check for blood clots (DVT).",
    "Urine Protein Test": "A urine test checking for protein — high levels indicate kidney issues.",
    "Tilt Table Test": "You lie on a table that slowly tilts upright to diagnose fainting causes.",
    "Anxiety/Stress Assessment": "A structured evaluation to determine whether anxiety is the primary trigger.",
    "None": "",
}

URGENCY_DEFINITIONS = {
    "Urgent": "Immediate medical attention required.",
    "Soon": "Consult a doctor within 24–72 hours.",
    "Routine": "Consult a doctor when convenient."
}


def load_models():
    urgency_model = joblib.load(os.path.join(SAVE_DIR, "urgency_model.pkl"))
    tests_model = joblib.load(os.path.join(SAVE_DIR, "tests_model.pkl"))
    label_encoders = joblib.load(os.path.join(SAVE_DIR, "label_encoders.pkl"))
    mlb = joblib.load(os.path.join(SAVE_DIR, "test_label_encoders.pkl"))
    return urgency_model, tests_model, label_encoders, mlb


def predict_for_user(primary_symptom: str, answers: dict) -> dict:
    urgency_model, tests_model, label_encoders, mlb = load_models()

    # Encode symptom
    symptom_enc = label_encoders["symptom"]
    if primary_symptom not in symptom_enc.classes_:
        raise ValueError("Unknown symptom")

    symptom_int = symptom_enc.transform([primary_symptom])[0]

    q2 = int(answers["Q2"])

    X = np.array([[
        symptom_int,
        int(answers["Q1"]),
        q2,
        int(answers["Q3"]),
        int(answers["Q4"]),
        int(answers["Q5"]),
        int(answers["Q6"]),
        symptom_int * q2
    ]])

    # Urgency prediction
    urgency_int = urgency_model.predict(X)[0]
    urgency_label = label_encoders["urgency"].inverse_transform([urgency_int])[0]

    # Test prediction (TOP 6 using probability)
    probs = tests_model.predict_proba(X)

    test_scores = []
    for i in range(probs.shape[1]):
        score = probs[0][i]
        test_name = mlb.classes_[i]

        if test_name != "None":
            test_scores.append((test_name, score))

    sorted_tests = sorted(test_scores, key=lambda x: x[1], reverse=True)
    top_tests = sorted_tests[:6]

    recommended = []
    for rank, (name, _) in enumerate(top_tests, 1):
        recommended.append({
            "rank": rank,
            "name": name,
            "description": TEST_DESCRIPTIONS.get(name, "")
        })

    return {
        "urgency": urgency_label,
        "urgency_description": URGENCY_DEFINITIONS[urgency_label],
        "recommended_tests": recommended
    }


if __name__ == "__main__":
    result = predict_for_user("Chest Pain", {
        "Q1": 1,
        "Q2": 3,
        "Q3": 1,
        "Q4": 1,
        "Q5": 1,
        "Q6": 1,
    })

    print("Urgency:", result["urgency"])
    print("Tests:")
    for t in result["recommended_tests"]:
        print(f"{t['rank']}. {t['name']}")
