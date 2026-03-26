import json

def load_tips():
    with open("tips.json", "r") as f:
        tips = json.load(f)
    return tips
