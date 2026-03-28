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
    print("🔥 REQUEST RECEIVED")
    print("USER ID:", user_id)
    print("INPUT SYMPTOMS:", user_symptoms)
    print("==============================\n")

    tips = load_tips()

    print("📦 TOTAL TIPS LOADED:", len(tips))

    # -----------------------------
    # STEP 1: update symptoms (if any)
    # -----------------------------
    if user_symptoms and len(user_symptoms) > 0:
        for symptom in user_symptoms:
            update_user_symptom(user_id, symptom)

    # -----------------------------
    # STEP 2: fetch user profile
    # -----------------------------
    user_data = get_user_symptoms(user_id)

    print("👤 USER PROFILE FROM DB:", user_data)

    has_history = any(user_data.values())

    print("📊 HAS HISTORY:", has_history)

    grouped = {cat: [] for cat in CATEGORIES}

    # -----------------------------
    # CASE 1: NO HISTORY → RANDOM MODE
    # -----------------------------
    if not has_history:

        print("🎲 MODE: RANDOM TIPS")

        for category in CATEGORIES:

            category_tips = [
                t for t in tips
                if t.get("category") == category
            ]

            print(f"\n➡️ Category: {category}")
            print("Available tips:", len(category_tips))

            if category_tips:

                # 🔥 RANDOM COUNT (BETWEEN 1 and 5 or available size)
                k = random.randint(1, min(5, len(category_tips)))

                print("Random count selected:", k)

                grouped[category] = random.sample(category_tips, k)

    # -----------------------------
    # CASE 2: PERSONALIZED MODE
    # -----------------------------
    else:

        print("🧠 MODE: PERSONALIZED")

        scored = []

        for tip in tips:
            score = 0
            tip_symptoms = tip.get("symptoms", [])

            for symptom in tip_symptoms:
                score += user_data.get(symptom, 0)

            scored.append({
                "tip": tip,
                "score": score
            })

        scored.sort(key=lambda x: x["score"], reverse=True)

        for item in scored:
            tip = item["tip"]
            category = tip.get("category")

            if category in grouped:
                grouped[category].append(tip)

        for category in grouped:
            grouped[category] = grouped[category][:5]

    # -----------------------------
    # FINAL OUTPUT
    # -----------------------------
    result = []

    for category in CATEGORIES:

        print(f"\n📤 FINAL CATEGORY: {category}")
        print("Tips count:", len(grouped[category]))

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

    print("\n✅ FINAL RESPONSE SENT\n")

    return result
