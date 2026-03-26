import axios from "axios";

export const predictTests = async (req, res) => {
  try {
    const response = await axios.post(
      "http://127.0.0.1:3000/predict-tests",
      {
        answers: req.body   // fix
      }
    );

    res.json(response.data);

  } catch (error) {
    console.error("ML ERROR:", error.response?.data || error.message);

    res.status(500).json({
      message: "ML prediction failed",
    });
  }
};
