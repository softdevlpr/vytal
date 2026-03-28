from fastapi import FastAPI
from recommendation_engine import recommend_tips
from database import load_tips
import uvicorn

app = FastAPI()

tips = load_tips()


@app.get("/")
def home():
    return {"message": "Health Tips Recommendation API Running"}


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

    fresh_tips = load_tips()

    sample_size = min(10, len(fresh_tips))

    return {
        "tips": fresh_tips[:sample_size]
    }


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
