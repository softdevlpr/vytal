from fastapi import FastAPI
from recommendation_engine import recommend_tips
from database import load_tips
import uvicorn

app = FastAPI()


# -----------------------------
# LOAD TIPS ON START
# -----------------------------
tips = load_tips()


# -----------------------------
# HEALTH CHECK
# -----------------------------
@app.get("/")
def home():
    return {"message": "Health Tips Recommendation API Running"}


# -----------------------------
# RECOMMENDATION ENDPOINT (FIXED)
# -----------------------------
@app.post("/recommend")
def get_recommendations(data: dict):

    user_id = data.get("user_id")
    user_symptoms = data.get("symptoms", [])

    # 🔥 NOW USING USER_ID BASED SYSTEM (IMPORTANT FIX)
    results = recommend_tips(user_id, user_symptoms)

    return {
        "recommended_tips": results
    }


# -----------------------------
# RANDOM TIPS (CATEGORY SAFE FIX)
# -----------------------------
@app.get("/random_tips")
def random_tips():

    # avoid global reuse bug
    fresh_tips = load_tips()

    # safe fallback (no crash if <10 tips exist)
    sample_size = min(10, len(fresh_tips))

    return {
        "tips": fresh_tips[:sample_size]
    }


# -----------------------------
# RUN SERVER
# -----------------------------
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
