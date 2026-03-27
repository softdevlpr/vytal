from pymongo import MongoClient
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Get URI from .env
MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise Exception("MONGO_URI not found in .env file")

client = MongoClient(MONGO_URI)

db = client["VYTALDB"]

tips_collection = db["tips"]
users_collection = db["users"]


# -----------------------------
# LOAD TIPS
# -----------------------------
def load_tips():
    return list(tips_collection.find({}, {"_id": 0}))


# -----------------------------
# UPDATE SYMPTOM SCORE
# -----------------------------
def update_user_symptom(user_id, symptom):
    users_collection.update_one(
        {"user_id": user_id},
        {"$inc": {f"symptoms.{symptom}": 1}},
        upsert=True
    )


# -----------------------------
# GET USER SYMPTOMS
# -----------------------------
def get_user_symptoms(user_id):
    user = users_collection.find_one({"user_id": user_id})

    if not user:
        return {}

    return user.get("symptoms", {})
