const axios = require("axios");

exports.predictTests = async (req, res) => {
  try {
    const response = await axios.post(
      "http://127.0.0.1:5000/predict",
      req.body,
      {
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

    res.json(response.data);
  } catch (error) {
    console.error("ML ERROR:", error.message);
    console.error("ML RESPONSE:", error.response?.data);

    res.status(500).json({
      message: "ML prediction failed",
    });
  }
};
