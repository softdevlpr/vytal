"""
api/app.py
----------
Flask REST API that exposes the symptom → test prediction system.

HOW TO RUN:
    cd cardiac_app/
    python api/app.py

ENDPOINTS:

  GET  /symptoms
       Returns list of all valid symptoms.

  GET  /questions/<symptom>
       Returns the 6 questions for a given symptom.

  POST /predict
       Body (JSON):
         {
           "primary_symptom": "Chest Pain",
           "answers": { "Q1": 1, "Q2": 3, "Q3": 1, "Q4": 1, "Q5": 0, "Q6": 1 }
         }
       Returns urgency + recommended tests.

  GET  /records?symptom=Chest Pain&urgency=Urgent&limit=10
       Queries MongoDB for matching records.

  GET  /urgency-definitions
       Returns all 3 urgency level definitions.
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from flask import Flask, request, jsonify
from flask_cors import CORS

from model.predict import predict_for_user
from db.mongo_connect import get_collection
from utils.questions import QUESTIONS, SYMPTOMS_LIST, URGENCY_DEFINITIONS

app = Flask(__name__)
CORS(app)  # allows your frontend (React/etc.) to call this API


# ── Helpers ───────────────────────────────────────────────────────────────────

def error(message, code=400):
    return jsonify({"success": False, "error": message}), code


def ok(data):
    return jsonify({"success": True, "data": data})


# ── Routes ────────────────────────────────────────────────────────────────────

@app.route("/symptoms", methods=["GET"])
def get_symptoms():
    """Return list of all available symptoms."""
    return ok(SYMPTOMS_LIST)


@app.route("/questions/<path:symptom>", methods=["GET"])
def get_questions(symptom):
    """Return the 6 follow-up questions for a given symptom."""
    if symptom not in QUESTIONS:
        return error(f"Unknown symptom: '{symptom}'. Use GET /symptoms for valid options.")
    return ok({
        "symptom":   symptom,
        "questions": QUESTIONS[symptom]
    })


@app.route("/predict", methods=["POST"])
def predict():
    """
    Accept user symptom + answers, return urgency + recommended tests.
    Also saves the prediction to MongoDB for audit/history.
    """
    body = request.get_json(silent=True)
    if not body:
        return error("Request body must be JSON.")

    symptom = body.get("primary_symptom", "").strip()
    answers = body.get("answers", {})

    # Validate
    if not symptom:
        return error("'primary_symptom' is required.")
    if symptom not in QUESTIONS:
        return error(f"Unknown symptom: '{symptom}'.")
    for q in ["Q1", "Q2", "Q3", "Q4", "Q5", "Q6"]:
        if q not in answers:
            return error(f"Missing answer for {q}.")
        if not isinstance(answers[q], (int, float)):
            return error(f"Answer for {q} must be a number (0/1 for Yes/No, 1-3 for scale).")

    # Predict
    try:
        result = predict_for_user(symptom, answers)
    except ValueError as e:
        return error(str(e))
    except FileNotFoundError:
        return error("Model not found. Please run: python model/train_model.py", 500)

    # Save to MongoDB (optional audit log)
    try:
        collection = get_collection()
        collection.insert_one({
            "type":             "prediction_log",
            "primary_symptom":  symptom,
            "answers":          answers,
            "urgency":          result["urgency"],
            "recommended_tests": result["recommended_tests"],
        })
    except Exception:
        pass  # don't fail the response if DB is down

    return ok(result)


@app.route("/records", methods=["GET"])
def get_records():
    """
    Query MongoDB for dataset records.
    Query params: symptom, urgency, limit (default 20)
    """
    symptom = request.args.get("symptom")
    urgency = request.args.get("urgency")
    limit   = int(request.args.get("limit", 20))

    query = {"type": {"$ne": "prediction_log"}}  # exclude prediction logs
    if symptom:
        query["primary_symptom"] = symptom
    if urgency:
        query["urgency"] = urgency

    collection = get_collection()
    docs = list(collection.find(query, {"_id": 0}).limit(limit))
    return ok({"count": len(docs), "records": docs})


@app.route("/urgency-definitions", methods=["GET"])
def urgency_definitions():
    """Return formal definitions for all 3 urgency levels."""
    return ok(URGENCY_DEFINITIONS)


@app.route("/stats", methods=["GET"])
def stats():
    """Return basic stats from MongoDB."""
    collection = get_collection()
    data_query = {"type": {"$ne": "prediction_log"}}
    return ok({
        "total_records":   collection.count_documents(data_query),
        "total_symptoms":  len(SYMPTOMS_LIST),
        "urgency_counts": {
            u: collection.count_documents({**data_query, "urgency": u})
            for u in ["Urgent", "Soon", "Routine"]
        }
    })


# ── Run ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("🚀 Starting Cardiac Symptom API...")
    print("   http://localhost:5000/symptoms")
    print("   http://localhost:5000/questions/Chest Pain")
    print("   POST http://localhost:5000/predict")
    app.run(debug=True, port=5000)
