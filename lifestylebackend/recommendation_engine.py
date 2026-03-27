from database import load_tips, update_user_symptom, get_user_symptoms
import random

# -----------------------------
# CONFIG
# -----------------------------
CATEGORIES = [
    "Healthy Lifestyle",
    "Weight Management",
    "Fitness & Strength",
    "Condition Support",
    "Energy and Productivity"
]


# -----------------------------
# MAIN FUNCTION
# -----------------------------
def recommend_tips(user_id, user_symptoms):

    tips = load_tips()

    # ✅ STEP 1: UPDATE SYMPTOM SCORES IN MONGO (ONLY ON BUTTON CLICK)
    for symptom in user_symptoms:
        update_user_symptom(user_id, symptom)

    # ✅ STEP 2: LOAD UPDATED USER PROFILE
    user_data = get_user_symptoms(user_id)

    scored_tips = []

    # -----------------------------
    # STEP 3: SCORE TIPS (PERSONALIZATION)
    # -----------------------------
    for tip in tips:
        score = 0
        tip_symptoms = tip.get("symptoms", [])

        for symptom in tip_symptoms:
            score += user_data.get(symptom, 0)

        if score > 0:
            scored_tips.append({
                "tip": tip,
                "score": score
            })

    # Sort by score (highest first)
    scored_tips.sort(key=lambda x: x["score"], reverse=True)

    # -----------------------------
    # STEP 4: GROUP BY CATEGORY (STRICT)
    # -----------------------------
    grouped = {cat: [] for cat in CATEGORIES}

    for item in scored_tips:
        tip = item["tip"]
        category = tip.get("category")

        if category in grouped:
            grouped[category].append(tip)

    # Limit top 5 per category
    for category in grouped:
        grouped[category] = grouped[category][:5]

    # -----------------------------
    # STEP 5: CATEGORY-WISE FALLBACK (NO MIXING FIX)
    # -----------------------------
    for category in CATEGORIES:

        if len(grouped[category]) == 0:

            category_tips = [
                t for t in tips
                if t.get("category") == category
            ]

            if len(category_tips) > 0:
                grouped[category] = random.sample(
                    category_tips,
                    min(3, len(category_tips))
                )

    # -----------------------------
    # STEP 6: FINAL RESPONSE FORMAT
    # -----------------------------
    result = []

    for category in CATEGORIES:
        result.append({
            "category": category,
            "tips": grouped[category]
        })

    return result
