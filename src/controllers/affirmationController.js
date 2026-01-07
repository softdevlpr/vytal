const Affirmation = require("../models/Affirmations");

exports.getRandomAffirmation = async (req, res) => {
  try {
    const result = await Affirmation.aggregate([{ $sample: { size: 1 } }]);

    if (!result.length) {
      return res.status(404).json({ message: "No affirmations found" });
    }

    res.status(200).json({
      affirmation: result[0].affirmation,
    });
  } catch (error) {
    console.error("Affirmation error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
