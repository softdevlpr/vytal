"""
ML Microservice (ONLY prediction)
"""

import os, sys
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

sys.path.append(os.path.dirname(__file__))
from model.predict import predict_for_user

load_dotenv()

app = Flask(__name__)
CORS(app)

# ── DEBUG CONFIG ─────────────────────────────
logging.basicConfig(level=logging.DEBUG)


@app.route("/ml-predict", methods=["POST"])
def predict():
    body = request.json or {}

    logging.debug(f"Incoming request body: {body}")

    symptom = body.get("primary_symptom", "")
    answers = body.get("answers", {})

    logging.debug(f"Parsed symptom: {symptom}")
    logging.debug(f"Parsed answers: {answers}")

    if not symptom or len(answers) < 6:
        logging.error("Validation failed: symptom or answers missing")
        return jsonify({
            "success": False,
            "error": "primary_symptom and 6 answers required"
        }), 400

    try:
        result = predict_for_user(symptom, answers)

        logging.debug(f"ML result: {result}")

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        logging.exception("Prediction error")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


if __name__ == "__main__":
    print("ML service running at http://0.0.0.0:8000")
    app.run(host="0.0.0.0", port=8000, debug=True)
