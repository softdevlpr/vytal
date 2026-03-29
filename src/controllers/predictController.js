// controllers/predictController.js
const axios = require("axios");

// POST /api/predict
// Forwards the request to the Python ML microservice on port 8000
const predict = async (req, res) => {
  const { primary_symptom: symptom = "", answers = {} } = req.body || {};

  if (!symptom || Object.keys(answers).length < 6) {
    return res.status(400).json({
      success: false,
      error: "primary_symptom and 6 answers required",
    });
  }

  try {
    const response = await axios.post(
      "http://localhost:8000/ml-predict",   // Python microservice
      { primary_symptom: symptom, answers }
    );
    res.json({ success: true, data: response.data.data });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { predict };

