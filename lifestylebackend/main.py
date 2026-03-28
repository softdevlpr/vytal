from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from recommendation_engine import recommend_tips
from database import load_tips
import random

app = FastAPI()


# -----------------------------
# REQUEST MODEL
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
# RECOMMEND ENDPOINT
# -----------------------------
@app.post("/recommend")
def get_recommendations(data: RecommendRequest):

    try:
        results = recommend_tips(
            data.user_id,
            data.symptoms or []
        )

        # ✅ FIX: CLEAN RESPONSE FOR UI (ONLY tip_text)
        clean_results = []

        for tip in results:
            if isinstance(tip, str):
                clean_results.append(tip)

            elif isinstance(tip, dict):
                if "tip_text" in tip and tip["tip_text"]:
                    clean_results.append(tip["tip_text"])

        return {"recommended_tips": clean_results}

    except Exception as e:
        print("ERROR:", str(e))
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------------
# RANDOM TIPS
# -----------------------------
@app.get("/random_tips")
def random_tips():

    tips = load_tips()

    if not tips:
        return {"tips": []}

    return {
        "tips": random.sample(tips, min(10, len(tips)))
    }


# -----------------------------
# RUN SERVER
# -----------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
