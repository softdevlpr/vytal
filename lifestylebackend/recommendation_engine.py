from database import load_tips
import random

def recommend_tips(user_symptoms):

    tips = load_tips()

    scored_tips = []

    # ✅ Step 1: Score tips based on matching symptoms
    for tip in tips:
        matches = set(user_symptoms) & set(tip["symptoms"])

        if matches:
            score = len(matches)

            scored_tips.append({
                "tip": tip,
                "score": score
            })

    # ✅ Step 2: Sort by score (highest first)
    scored_tips.sort(key=lambda x: x["score"], reverse=True)

    # ✅ Step 3: Define categories
    categories = [
        "Healthy Lifestyle",
        "Weight Management",
        "Fitness & Strength",
        "Condition Support",
        "Energy and Productivity"
    ]

    # ✅ Step 4: Group tips by category (MULTIPLE TIPS)
    grouped = {cat: [] for cat in categories}

    for item in scored_tips:
        tip = item["tip"]
        category = tip["category"]

        if category in grouped:
            grouped[category].append(tip)

    # ✅ Step 5: Limit to top 5 tips per category
    for category in grouped:
        grouped[category] = grouped[category][:5]

    # ✅ Step 6: Fill empty categories with random tips
    for category in categories:
        if not grouped[category]:
            category_tips = [t for t in tips if t["category"] == category]

            if category_tips:
                random_sample = random.sample(
                    category_tips,
                    min(3, len(category_tips))
                )
                grouped[category] = random_sample

    # ✅ Step 7: Convert to required output format
    result = []

    for category in categories:
        result.append({
            "category": category,
            "tips": grouped[category]
        })

    return result
