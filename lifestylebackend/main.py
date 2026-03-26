from fastapi import FastAPI
from recommendation_engine import recommend_tips
import random
from database import load_tips
import uvicorn

app = FastAPI()

tips = load_tips()


@app.get("/")
def home():
    return {"message": "Health Tips Recommendation API Running"}


@app.post("/recommend")

def get_recommendations(data: dict):

    user_symptoms = data["symptoms"]

    results = recommend_tips(user_symptoms)

    return {"recommended_tips": results}


@app.get("/random_tips")

def random_tips():

    return {"tips": random.sample(tips, 10)}


if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)

app.run(debug=True, port=5001)
