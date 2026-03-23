from database import load_tips

def recommend_tips(user_symptoms):

    tips = load_tips()

    recommendations = []

    for tip in tips:

        matches = set(user_symptoms) & set(tip["symptoms"])

        if matches:
            score = len(matches)

            recommendations.append({
                "tip": tip,
                "score": score
            })

    recommendations.sort(key=lambda x: x["score"], reverse=True)

    return [r["tip"] for r in recommendations[:10]]
