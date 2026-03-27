from pymongo import MongoClient

#  MongoDB Connection
MONGO_URI=mongodb+srv://vytaluser:Vytal123@vytalcluster.0hcdsof.mongodb.net/VYTALDB?appName=VytalCluster

client = MongoClient(MONGO_URI)

#  Your database name (as you said)
db = client["VYTALDB"]

# Collections (equivalent to JSON files)
tips_collection = db["tips"]
users_collection = db["users"]


# -----------------------------
#  REPLACE load_tips()
# -----------------------------
def load_tips():
    tips = list(tips_collection.find({}, {"_id": 0}))
    return tips


# -----------------------------
# OPTIONAL: Save tips (if needed later)
# -----------------------------
def save_tip(tip):
    tips_collection.insert_one(tip)


# -----------------------------
# USER SYMPTOM STORAGE
# -----------------------------
def update_user_symptom(user_id, symptom):
    users_collection.update_one(
        {"user_id": user_id},
        {"$inc": {f"symptoms.{symptom}": 1}},
        upsert=True
    )


# -----------------------------
# GET USER DATA
# -----------------------------
def get_user_symptoms(user_id):
    user = users_collection.find_one({"user_id": user_id})

    if not user:
        return {}

    return user.get("symptoms", {})
