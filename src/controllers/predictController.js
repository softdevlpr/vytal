const { predictForUser } = require("../model/predict"); 

// POST /predict
const predict = async (req, res) => {
  const { primary_symptom: symptom = "", answers = {} } = req.body || {};

  // Validate inputs — need symptom + at least 6 answers
  if (!symptom || Object.keys(answers).length < 6) {
    return res
      .status(400)
      .json({ success: false, error: "primary_symptom and 6 answers required" });
  }

  try {
    const result = await predictForUser(symptom, answers);
    res.json({ success: true, data: result });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { predict };
