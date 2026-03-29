// controllers/predictController.js
const axios = require("axios");

// POST /api/predict
// Forwards request to Flask ML service (port 5000)
const predict = async (req, res) => {
  const { answers = {} } = req.body || {};

  // Validate input
  if (Object.keys(answers).length < 6) {
    return res.status(400).json({
      success: false,
      error: "6 answers required",
    });
  }

  try {
    console.log("Sending to ML:", answers);

    // Call Flask API
    const response = await axios.post(
      "http://127.0.0.1:8000/ml-predict",
      { answers }
    );

    console.log("ML Response:", response.data);

    // Send back to client
    res.json({
      success: true,
      data: response.data,
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
