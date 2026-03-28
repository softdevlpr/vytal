from database import load_tips, update_user_symptom, get_user_symptoms
import random

CATEGORIES = [
    "Healthy Lifestyle",
    "Weight Management",
    "Fitness & Strength",
    "Condition Support",
    "Energy and Productivity"
]


def recommend_tips(user_id, user_symptoms):

    tips = load_tips()

    # -----------------------------
    # STEP 1: update symptom scores
    # -----------------------------
    if user_symptoms:
        for symptom in user_symptoms:
            update_user_symptom(user_id, symptom)

    # -----------------------------
    # STEP 2: load updated user profile
    # -----------------------------
    user_data = get_user_symptoms(user_id)

    scored_tips = []

    # -----------------------------
    # STEP 3: scoring
    # -----------------------------
    for tip in tips:
        score = 0
        tip_symptoms = tip.get("symptoms", [])

        for symptom in tip_symptoms:
            score += user_data.get(symptom, 0)

        scored_tips.append({
            "tip": tip,
            "score": score
        })

    # sort
    scored_tips.sort(key=lambda x: x["score"], reverse=True)

    # -----------------------------
    # STEP 4: group by category
    # -----------------------------
    grouped = {cat: [] for cat in CATEGORIES}

    for item in scored_tips:
        tip = item["tip"]
        category = tip.get("category")

        if category in grouped:
            grouped[category].append(tip)

    # limit top 5
    for category in grouped:
        grouped[category] = grouped[category][:5]

    # -----------------------------
    # STEP 5: fallback (IMPORTANT FIX)
    # -----------------------------
    for category in CATEGORIES:
        if len(grouped[category]) == 0:
            category_tips = [t for t in tips if t.get("category") == category]

            if category_tips:
                grouped[category] = random.sample(
                    category_tips,
                    min(3, len(category_tips))
                )

    # -----------------------------
    # STEP 6: FINAL FORMAT (FLUTTER FRIENDLY FIX)
    # -----------------------------
    result = []

    for category in CATEGORIES:
        result.append({
            "category": category,
            "tips": [
                {
                    "tip_text": t.get("tip_text", ""),
                    "symptoms": t.get("symptoms", []),
                    "category": t.get("category", "")
                }
                for t in grouped[category]
            ]
        })

    return result
