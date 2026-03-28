def recommend_tips(user_id, user_symptoms):

    tips = load_tips()

    # STEP 1: UPDATE ONLY CURRENT SYMPTOM (NO LOSS, NO FIRST ONLY)
    if user_symptoms:
        unique_symptoms = list(set([s for s in user_symptoms if s]))

        for symptom in unique_symptoms:
            update_user_symptom(user_id, symptom)

    # STEP 2: FETCH UPDATED SCORES
    user_data = get_user_symptoms(user_id)

    has_history = any(user_data.values())
    grouped = {cat: [] for cat in CATEGORIES}

    # -------------------------
    # CASE 1: NEW USER
    # -------------------------
    if not has_history:

        for category in CATEGORIES:
            category_tips = [t for t in tips if t["category"] == category]

            if category_tips:
                grouped[category] = random.sample(
                    category_tips,
                    min(len(category_tips), 3)
                )

    # -------------------------
    # CASE 2: PERSONALIZED
    # -------------------------
    else:

        scored = []

        for tip in tips:
            score = 0
            for symptom in tip.get("symptoms", []):
                score += user_data.get(symptom, 0)

            if score > 0:
                scored.append({"tip": tip, "score": score})

        scored.sort(key=lambda x: x["score"], reverse=True)

        # distribute into categories fairly
        for item in scored:
            tip = item["tip"]
            cat = tip["category"]

            if cat in grouped:
                grouped[cat].append(tip)

        # ensure minimum fill per category (important UX fix)
        for category in CATEGORIES:
            if len(grouped[category]) < 2:
                fallback = [
                    t for t in tips
                    if t["category"] == category
                ]
                grouped[category].extend(
                    random.sample(fallback, min(2, len(fallback)))
                )

    # FINAL FORMAT
    result = []

    for category in CATEGORIES:
        result.append({
            "category": category,
            "tips": grouped[category][:5]
        })

    return result
