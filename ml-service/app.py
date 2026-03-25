from flask import Flask, request, jsonify
import json
from model import predict_test

app = Flask(__name__)

# Load flow
with open("flow.json") as f:
    flow = json.load(f)

# Route: Get questions
@app.route('/get_questions', methods=['POST'])
def get_questions():
    data = request.json
    symptom = data.get("symptom")

    if symptom in flow:
        return jsonify(flow[symptom]["questions"])
    else:
        return jsonify({"error": "Invalid symptom"}), 400


# Route: Predict test
@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    answers = data.get("answers")

    if not answers:
        return jsonify({"error": "No answers provided"}), 400

   result = predict_test(answers)
   return jsonify(result)


if __name__ == "__main__":
    app.run(debug=True)
