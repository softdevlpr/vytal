"""
backend/app.py  —  Extended Flask API
Covers all routes the Flutter app needs.
Run: python backend/app.py
"""

import os, sys
from datetime import datetime, timedelta
from collections import defaultdict
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from bson import ObjectId
from dotenv import load_dotenv

sys.path.append(os.path.dirname(__file__))
from model.predict import predict_for_user

load_dotenv()

app = Flask(__name__)
CORS(app)

client = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017"))
db = client["cardiac_app_db"]

def ok(data):    return jsonify({"success": True,  "data": data})
def err(msg, c=400): return jsonify({"success": False, "error": msg}), c
def clean(doc):
    doc["_id"] = str(doc["_id"])
    return doc


# ── PREDICTION ────────────────────────────────────────────────────────────────
@app.route("/predict", methods=["POST"])
def predict():
    body = request.json or {}
    symptom = body.get("primary_symptom", "")
    answers = body.get("answers", {})
    if not symptom or len(answers) < 6:
        return err("primary_symptom and 6 answers required")
    try:
        result = predict_for_user(symptom, answers)
        return ok(result)
    except Exception as e:
        return err(str(e), 500)


# ── SYMPTOM LOGS ───────────────────────────────────────────────────────────────
@app.route("/logs", methods=["POST"])
def add_log():
    body = request.json or {}
    uid = body.get("uid")
    if not uid:
        return err("uid required")

    body["logged_at"] = datetime.utcnow().isoformat()
    db.symptom_logs.insert_one(body)

    # Update user's symptom score
    symptom = body.get("primary_symptom", "")
    if symptom:
        db.users.update_one(
            {"uid": uid},
            {"$inc": {f"symptom_scores.{symptom}": 1}},
        )
    return ok({"message": "Log saved"})


@app.route("/logs", methods=["GET"])
def get_logs():
    uid = request.args.get("uid")
    period = request.args.get("period", "week")  # week / month / year
    if not uid:
        return err("uid required")

    now = datetime.utcnow()
    if period == "week":
        since = now - timedelta(days=7)
    elif period == "month":
        since = now - timedelta(days=30)
    else:
        since = now - timedelta(days=365)

    logs = list(db.symptom_logs.find(
        {"uid": uid, "logged_at": {"$gte": since.isoformat()}},
        sort=[("logged_at", -1)]
    ))
    return ok({"logs": [clean(l) for l in logs], "count": len(logs)})


# ── INSIGHTS ───────────────────────────────────────────────────────────────────
@app.route("/insights", methods=["GET"])
def insights():
    uid = request.args.get("uid")
    period = request.args.get("period", "week")
    if not uid:
        return err("uid required")

    now = datetime.utcnow()
    if period == "week":
        since = now - timedelta(days=7)
        prev  = now - timedelta(days=14)
        label_fmt = "%a"
    elif period == "month":
        since = now - timedelta(days=30)
        prev  = now - timedelta(days=60)
        label_fmt = "%d %b"
    else:
        since = now - timedelta(days=365)
        prev  = now - timedelta(days=730)
        label_fmt = "%b"

    logs = list(db.symptom_logs.find(
        {"uid": uid, "logged_at": {"$gte": since.isoformat()}}
    ))

    if not logs:
        return ok({})

    # Symptom frequency
    sym_freq = defaultdict(int)
    urgency_count = defaultdict(int)
    chart_by_day = defaultdict(list)

    for log in logs:
        sym_freq[log.get("primary_symptom", "")] += 1
        urgency_count[log.get("urgency", "Routine")] += 1
        day = log.get("logged_at", "")[:10]
        chart_by_day[day].append(log.get("severity_score", 0))

    # Chart points
    sorted_days = sorted(chart_by_day.keys())
    chart_points = [
        {
            "label": datetime.strptime(d, "%Y-%m-%d").strftime(label_fmt),
            "score": round(sum(chart_by_day[d]) / len(chart_by_day[d]), 1),
        }
        for d in sorted_days
    ]

    top_symptom = max(sym_freq, key=sym_freq.get) if sym_freq else "None"

    # Compare to previous period for improvement message
    prev_logs = list(db.symptom_logs.find(
        {"uid": uid, "logged_at": {"$gte": prev.isoformat(), "$lt": since.isoformat()}}
    ))
    prev_urgent = sum(1 for l in prev_logs if l.get("urgency") == "Urgent")
    curr_urgent = urgency_count.get("Urgent", 0)

    improvement = None
    if prev_urgent > curr_urgent:
        improvement = f"Great progress! Your Urgent symptom instances dropped from {prev_urgent} to {curr_urgent} compared to the previous period."
    elif prev_urgent == 0 and curr_urgent == 0:
        improvement = "You had no urgent symptoms this period. Keep it up!"

    return ok({
        "total_logs": len(logs),
        "top_symptom": top_symptom,
        "urgency_breakdown": dict(urgency_count),
        "symptom_frequency": dict(sorted(sym_freq.items(), key=lambda x: -x[1])),
        "chart_points": chart_points,
        "improvement": improvement,
    })


# ── LIFESTYLE TIPS ─────────────────────────────────────────────────────────────
@app.route("/tips", methods=["GET"])
def get_tips():
    category = request.args.get("category", "")
    symptoms  = request.args.get("symptoms", "")
    limit     = int(request.args.get("limit", 5))
    uid       = request.args.get("uid", "")

    query = {}
    if category:
        query["category"] = category

    # Personalisation: if user has symptom history, boost matching tips
    if uid:
        user = db.users.find_one({"uid": uid})
        if user:
            top_symptoms = sorted(
                user.get("symptom_scores", {}).items(),
                key=lambda x: -x[1]
            )[:3]
            top_syms = [s[0] for s in top_symptoms if s[1] > 0]
            if top_syms:
                # Prefer tips matching user's top symptoms
                matched = list(db.lifestyle_tips.find(
                    {**query, "related_symptoms": {"$in": top_syms}},
                    limit=limit
                ))
                if len(matched) >= limit:
                    return ok([clean(t) for t in matched])
                # Top up with non-matched
                matched_ids = [m["_id"] for m in matched]
                rest = list(db.lifestyle_tips.find(
                    {**query, "_id": {"$nin": matched_ids}},
                    limit=limit - len(matched)
                ))
                return ok([clean(t) for t in matched + rest])

    # Raw query (no personalisation yet or no symptom history)
    if symptoms:
        sym_list = symptoms.split(",")
        query["related_symptoms"] = {"$in": sym_list}

    tips = list(db.lifestyle_tips.find(query, limit=limit))
    return ok([clean(t) for t in tips])


@app.route("/tips/for-symptom", methods=["GET"])
def tips_for_symptom():
    symptom = request.args.get("symptom", "")
    limit   = int(request.args.get("limit", 3))
    tips = list(db.lifestyle_tips.find(
        {"related_symptoms": symptom}, limit=limit
    ))
    return ok([clean(t) for t in tips])


# ── CLINICS ────────────────────────────────────────────────────────────────────
@app.route("/clinics", methods=["GET"])
def get_clinics():
    tests_param = request.args.get("tests", "")
    test_list   = [t.strip() for t in tests_param.split(",") if t.strip()]
    query = {}
    if test_list:
        query["tests_available"] = {"$in": test_list}
    clinics = list(db.clinics_jaipur.find(query))
    return ok([clean(c) for c in clinics])


# ── USERS ──────────────────────────────────────────────────────────────────────
@app.route("/users/<uid>", methods=["GET"])
def get_user(uid):
    user = db.users.find_one({"uid": uid})
    if not user:
        return err("User not found", 404)
    return ok(clean(user))


@app.route("/users", methods=["POST"])
def create_user():
    body = request.json or {}
    body["created_at"] = datetime.utcnow().isoformat()
    body["updated_at"] = datetime.utcnow().isoformat()
    body.setdefault("symptom_scores", {})
    body.setdefault("preferred_categories", [])
    db.users.update_one({"uid": body["uid"]}, {"$setOnInsert": body}, upsert=True)
    return ok({"message": "User created"})


@app.route("/users/<uid>", methods=["PUT"])
def update_user(uid):
    body = request.json or {}
    body["updated_at"] = datetime.utcnow().isoformat()
    body.pop("_id", None)
    db.users.update_one({"uid": uid}, {"$set": body})
    return ok({"message": "Updated"})


@app.route("/users/<uid>", methods=["DELETE"])
def delete_user(uid):
    db.users.delete_one({"uid": uid})
    db.symptom_logs.delete_many({"uid": uid})
    db.reminders.delete_many({"uid": uid})
    return ok({"message": "Account deleted"})


# ── REMINDERS ──────────────────────────────────────────────────────────────────
@app.route("/reminders", methods=["GET"])
def get_reminders():
    uid = request.args.get("uid")
    reminders = list(db.reminders.find({"uid": uid}))
    return ok([clean(r) for r in reminders])


@app.route("/reminders", methods=["POST"])
def add_reminder():
    body = request.json or {}
    body["created_at"] = datetime.utcnow().isoformat()
    result = db.reminders.insert_one(body)
    body["_id"] = str(result.inserted_id)
    return ok(body)


@app.route("/reminders/<rid>", methods=["DELETE"])
def delete_reminder(rid):
    db.reminders.delete_one({"_id": ObjectId(rid)})
    return ok({"message": "Deleted"})


@app.route("/reminders/<rid>", methods=["PATCH"])
def toggle_reminder(rid):
    body = request.json or {}
    db.reminders.update_one(
        {"_id": ObjectId(rid)},
        {"$set": {"is_active": body.get("is_active", True)}}
    )
    return ok({"message": "Updated"})


if __name__ == "__main__":
    print("Vytal App API running at http://localhost:8000")
    app.run(host="0.0.0.0", port=8000, debug=True)
