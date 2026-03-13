import axios from "axios";

export const predictTests = async (req, res) => {
  try {
    const symptoms = req.body;

    const response = await axios.post(
      "http://127.0.0.1:5000/predict",
      symptoms,
    );

    res.json(response.data);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "ML prediction failed",
    });
  }
};
