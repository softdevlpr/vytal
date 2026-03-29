"""
backend/app.py  —  ML Microservice ONLY
All DB routes have been moved to Node.js (server.js).
This file only handles the ML prediction endpoint.
Run: python backend/app.py
"""

import os, sys
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

sys.path.append(os.path.dirname(__file__))
from model.predict import predict_for_user   # ← your ML model stays here

load_dotenv()

app = Flask(__name__)
CORS(app)

# ── REMOVED from this file ────────────────────────────────────────────────────
# ✗ MongoClient         → Node.js uses Mongoose + native driver now
# ✗ /logs               → logController.js
# ✗ /insights           → insightController.js
# ✗ /tips               → tipController.js
# ✗ /tips/for-symptom   → tipController.js
# ✗ /clinics            → clinicController.js
# ✗ /users              → userController.js
# ✗ /reminders          → reminderController.js
# ─────────────────────────────────────────────────────────────────────────────


# ── PREDICTION (only route that stays here) ───────────────────────────────────
@app.route("/ml-predict", methods=["POST"])
def predict():
    body = request.json or {}
    symptom = body.get("primary_symptom", "")
    answers = body.get("answers", {})

    if not symptom or len(answers) < 6:
        return jsonify({
            "success": False,
            "error": "primary_symptom and 6 answers required"
        }), 400

    try:
        result = predict_for_user(symptom, answers)
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


if __name__ == "__main__":
    print("✅ ML microservice running at http://localhost:8000")
    app.run(host="0.0.0.0", port=8000, debug=True)



