from database import load_tips
import random
import json
import os

USER_DATA_FILE = "user_data.json"


# 🔥 LOAD USER SCORES
def load_user_data():
    if not os.path.exists(USER_DATA_FILE):
        return {}
    with open(USER_DATA_FILE, "r") as f:
        return json.load(f)


# 🔥 SAVE USER SCORES
def save_user_data(data):
    with open(USER_DATA_FILE, "w") as f:
        json.dump(data, f)


def recommend_tips(user_symptoms):

    tips = load_tips()
    user_data = load_user_data()

    # ✅ STEP 1: UPDATE SYMPTOM SCORES
    for symptom in user_symptoms:
        user_data[symptom] = user_data.get(symptom, 0) + 1

    save_user_data(user_data)

    scored_tips = []

    # ✅ STEP 2: SCORE TIPS USING PERSONALIZATION
    for tip in tips:
        score = 0

        for symptom in tip["symptoms"]:
            if symptom in user_data:
                score += user_data[symptom]  # 🔥 weighted score

        if score > 0:
            scored_tips.append({
                "tip": tip,
                "score": score
            })

    # ✅ STEP 3: SORT
    scored_tips.sort(key=lambda x: x["score"], reverse=True)

    # ✅ STEP 4: CATEGORIES
    categories = [
        "Healthy Lifestyle",
        "Weight Management",
        "Fitness & Strength",
        "Condition Support",
        "Energy and Productivity"
    ]

    grouped = {cat: [] for cat in categories}

    # ✅ STEP 5: GROUP
    for item in scored_tips:
        tip = item["tip"]
        category = tip["category"]

        if category in grouped:
            grouped[category].append(tip)

    # ✅ STEP 6: LIMIT (TOP 5)
    for category in grouped:
        grouped[category] = grouped[category][:5]

    # ✅ STEP 7: RANDOM FILL
    for category in categories:
        if not grouped[category]:
            category_tips = [t for t in tips if t["category"] == category]

            if category_tips:
                grouped[category] = random.sample(
                    category_tips,
                    min(3, len(category_tips))
                )

    # ✅ STEP 8: FINAL FORMAT
    result = []

    for category in categories:
        result.append({
            "category": category,
            "tips": grouped[category]
        })

    return result
