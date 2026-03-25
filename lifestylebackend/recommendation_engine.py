from database import load_tips
import random

def recommend_tips(user_symptoms):

    tips = load_tips()

    recommendations = []

    # Step 1: Score tips based on matching symptoms
    for tip in tips:
        matches = set(user_symptoms) & set(tip["symptoms"])

        if matches:
            score = len(matches)

            recommendations.append({
                "tip": tip,
                "score": score
            })

    # Step 2: Sort by score (highest first)
    recommendations.sort(key=lambda x: x["score"], reverse=True)

    # Step 3: Define categories
    categories = [
        "Healthy Lifestyle",
        "Weight Management",
        "Fitness & Strength",
        "Condition Support",
        "Energy and Productivity"
    ]

    selected_tips = []
    used_tip_ids = set()

    # Step 4: Ensure 1 tip per category
    for category in categories:
        found = False

        for item in recommendations:
            tip = item["tip"]

            if tip["category"] == category and tip["tip_id"] not in used_tip_ids:
                selected_tips.append(tip)
                used_tip_ids.add(tip["tip_id"])
                found = True
                break

        if not found:
            category_tips = [t for t in tips if t["category"] == category]

            if category_tips:
                random_tip = random.choice(category_tips)

                if random_tip["tip_id"] not in used_tip_ids:
                    selected_tips.append(random_tip)
                    used_tip_ids.add(random_tip["tip_id"])

    # Step 5: Fill remaining slots (up to 10 tips)
    for item in recommendations:
        if len(selected_tips) >= 10:
            break

        tip = item["tip"]

        if tip["tip_id"] not in used_tip_ids:
            selected_tips.append(tip)
            used_tip_ids.add(tip["tip_id"])

    
    grouped = {}

    for tip in selected_tips:
        category = tip["category"]

        if category not in grouped:
            grouped[category] = []

        grouped[category].append(tip)

    # Convert dict → list format
    result = []
    for category, tips_list in grouped.items():
        result.append({
            "category": category,
            "tips": tips_list
        })

    return result
