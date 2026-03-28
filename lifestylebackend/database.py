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

#  NEW COLLECTION 
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

    # 1. store logs separately
    symptom_logs_collection.insert_one({
        "user_id": user_id,
        "symptom": symptom,
        "timestamp": datetime.utcnow()
    })

    # 2. update user profile scores
    users_collection.update_one(
        {"user_id": user_id},
        {"$inc": {f"symptoms.{symptom}": 1}},
        upsert=True
    )


def get_user_symptom_score(user_id):
    user = users_collection.find_one({"user_id": user_id})

    if not user or "symptoms" not in user:
        return {}

    return user["symptoms"]

# -----------------------------
# GET USER SYMPTOMS
# -----------------------------
def get_user_symptoms(user_id):
    user = users_collection.find_one({"user_id": user_id})

    if not user:
        return {}

    return user.get("symptoms", {})
