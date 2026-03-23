import random

categories = [
    "healthy lifestyle",
    "weight management",
    "fitness and strength",
    "condition support",
    "energy and productivity"
]

for category in categories:
    found = False

    for item in scored_tips:
        if item["tip"]["category"] == category and item["tip"]["tip_id"] not in used_tip_ids:
            selected_tips.append(item["tip"])
            used_tip_ids.add(item["tip"]["tip_id"])
            found = True
            break

    # If no matching tip found → pick random from that category
    if not found:
        category_tips = [t for t in tips if t["category"] == category]
        if category_tips:
            random_tip = random.choice(category_tips)
            selected_tips.append(random_tip)
            used_tip_ids.add(random_tip["tip_id"])
