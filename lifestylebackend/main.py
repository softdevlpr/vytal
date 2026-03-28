from fastapi import FastAPI
from recommendation_engine import recommend_tips
from database import load_tips
import uvicorn

app = FastAPI()


@app.get("/")
def home():
    return {"message": "API Running"}


@app.post("/recommend")
def get_recommendations(data: dict):

    user_id = data.get("user_id")
    user_symptoms = data.get("symptoms", [])

    results = recommend_tips(user_id, user_symptoms)

    return {
        "recommended_tips": results
    }


@app.get("/random_tips")
def random_tips():

    fresh = load_tips()
    return {"tips": fresh[:10]}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
