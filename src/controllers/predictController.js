// controllers/predictController.js
const axios = require("axios");

const predict = async (req, res) => {
  const { primary_symptom = "", answers = {} } = req.body || {};

  if (!primary_symptom || Object.keys(answers).length < 6) {
    return res.status(400).json({
      success: false,
      error: "primary_symptom and 6 answers required",
    });
  }

  try {
    console.log("Sending to ML:", { primary_symptom, answers });

    const response = await axios.post(
      "http://127.0.0.1:8000/ml-predict",
      { primary_symptom, answers }
    );

    console.log("ML Response:", response.data);

    res.json({
      success: true,
      data: response.data.data,
    });

  } catch (e) {
    console.error("ML ERROR:", e.response?.data || e.message);

    res.status(500).json({
      success: false,
      error: e.response?.data || e.message,
    });
  }
};

module.exports = { predict };
