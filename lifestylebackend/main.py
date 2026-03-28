from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import random

from recommendation_engine import recommend_tips
from database import load_tips

app = FastAPI()


# -----------------------------
# REQUEST MODEL (IMPORTANT FIX)
# -----------------------------
class RecommendRequest(BaseModel):
    user_id: str
    symptoms: Optional[List[str]] = []


# -----------------------------
# HEALTH CHECK
# -----------------------------
@app.get("/")
def home():
    return {"message": "API Running"}


# -----------------------------
# RECOMMEND ENDPOINT (FIXED)
# -----------------------------
@app.post("/recommend")
def get_recommendations(data: RecommendRequest):

    try:
        user_id = data.user_id
        user_symptoms = data.symptoms or []

        results = recommend_tips(user_id, user_symptoms)

        # safety fallback
        if not results:
            return {"recommended_tips": []}

        return {"recommended_tips": results}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------------
# RANDOM TIPS (TRUE RANDOM FIX)
# -----------------------------
@app.get("/random_tips")
def random_tips():

    try:
        fresh = load_tips()

        if not fresh:
            return {"tips": []}

        sample_size = min(10, len(fresh))

        return {
            "tips": random.sample(fresh, sample_size)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------------
# RUN SERVER
# -----------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
