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

    print("\n==============================")
    print("REQUEST RECEIVED")
    print("USER ID:", user_id)
    print("INPUT SYMPTOMS:", user_symptoms)
    print("==============================\n")

    tips = load_tips()

    print("TOTAL TIPS LOADED:", len(tips))

    # update only if valid single symptoms exist
    if user_symptoms:
        for symptom in user_symptoms:
            if symptom:
                update_user_symptom(user_id, symptom)

    user_data = get_user_symptoms(user_id)

    print("USER PROFILE:", user_data)

    has_history = any(user_data.values())

    grouped = {cat: [] for cat in CATEGORIES}

    # RANDOM MODE
    if not has_history:

        print("MODE: RANDOM")

        for category in CATEGORIES:

            category_tips = [
                t for t in tips if t.get("category") == category
            ]

            if category_tips:

                k = random.randint(1, min(5, len(category_tips)))

                grouped[category] = random.sample(category_tips, k)

    # PERSONALIZED MODE
    else:

        print("MODE: PERSONALIZED")

        scored = []

        for tip in tips:
            score = 0
            for symptom in tip.get("symptoms", []):
                score += user_data.get(symptom, 0)

            scored.append({"tip": tip, "score": score})

        scored.sort(key=lambda x: x["score"], reverse=True)

        for item in scored:
            tip = item["tip"]
            category = tip.get("category")

            if category in grouped:
                grouped[category].append(tip)

        for category in grouped:
            grouped[category] = grouped[category][:5]

    # FINAL RESPONSE
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

    print("RESPONSE SENT")

    return result
