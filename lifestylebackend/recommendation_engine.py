import random
from database import load_tips, update_user_symptom, get_user_symptoms

CATEGORIES = [
    "Healthy Lifestyle",
    "Weight Management",
    "Fitness & Strength",
    "Condition Support",
    "Energy and Productivity"
]


def recommend_tips(user_id, user_symptoms):

    tips = load_tips()

    print("\n==============================")
    print("REQUEST RECEIVED")
    print("USER ID:", user_id)
    print("INPUT SYMPTOMS:", user_symptoms)
    print("==============================\n")

    # -----------------------------
    # STEP 1: UPDATE ONLY ONE SYMPTOM (SAFE + CONSISTENT)
    # -----------------------------
    if user_symptoms:
        symptom = user_symptoms[0]
        update_user_symptom(user_id, symptom)

    # -----------------------------
    # STEP 2: FETCH USER PROFILE
    # -----------------------------
    user_data = get_user_symptoms(user_id)

    print("USER PROFILE:", user_data)

    has_history = any(user_data.values())

    grouped = {cat: [] for cat in CATEGORIES}

    # -----------------------------
    # CASE 1: NEW USER (RANDOM)
    # -----------------------------
    if not has_history:

        for category in CATEGORIES:
            category_tips = [t for t in tips if t.get("category") == category]

            if category_tips:
                grouped[category] = random.sample(
                    category_tips,
                    min(3, len(category_tips))
                )

    # -----------------------------
    # CASE 2: PERSONALIZED
    # -----------------------------
    else:

        scored = []

        for tip in tips:
            score = 0

            for symptom in tip.get("symptoms", []):
                score += int(user_data.get(symptom, 0) or 0)

            if score > 0:
                scored.append({
                    "tip": tip,
                    "score": score
                })

        scored.sort(key=lambda x: x["score"], reverse=True)

        # distribute by category
        for item in scored:
            tip = item["tip"]
            cat = tip.get("category")

            if cat in grouped:
                grouped[cat].append(tip)

        # fallback fill (important UX safety)
        for category in CATEGORIES:
            if len(grouped[category]) < 2:
                fallback = [t for t in tips if t.get("category") == category]

                if fallback:
                    grouped[category].extend(
                        random.sample(fallback, min(2, len(fallback)))
                    )

    # -----------------------------
    # FINAL RESPONSE
    # -----------------------------
    result = []

    for category in CATEGORIES:
        result.append({
            "category": category,
            "tips": grouped[category][:5]
        })

    print("RESPONSE READY\n")

    return result
