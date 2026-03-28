from pymongo import MongoClient
from dotenv import load_dotenv
import os
from datetime import datetime

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise Exception("MONGO_URI not found in .env file")

client = MongoClient(MONGO_URI)

db = client["VYTALDB"]

tips_collection = db["tips"]
users_collection = db["users"]
symptom_logs_collection = db["user_symptom_logs"]


# -----------------------------
# LOAD TIPS
# -----------------------------
def load_tips():
    return list(tips_collection.find({}, {"_id": 0}))


# -----------------------------
# UPDATE SYMPTOM SCORE + LOGGING
# -----------------------------
def update_user_symptom(user_id, symptom):

    if not user_id or not symptom:
        return

    # ensure user exists
    users_collection.update_one(
        {"user_id": user_id},
        {"$setOnInsert": {"symptoms": {}}},
        upsert=True
    )

    # increment symptom score
    users_collection.update_one(
        {"user_id": user_id},
        {"$inc": {f"symptoms.{symptom}": 1}}
    )

    # log event (safe)
    try:
        symptom_logs_collection.insert_one({
            "user_id": user_id,
            "symptom": symptom,
            "timestamp": datetime.utcnow()
        })
    except Exception as e:
        print("LOG ERROR:", e)


# -----------------------------
# GET USER SYMPTOMS
# -----------------------------
def get_user_symptoms(user_id):
    user = users_collection.find_one({"user_id": user_id})

    if not user:
        return {}

    symptoms = user.get("symptoms", {})

    if symptoms is None:
        return {}

    return {k: int(v) for k, v in symptoms.items()}
