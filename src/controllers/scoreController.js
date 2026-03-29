const { getDB } = require("../config/db");

// SAVE LOG + UPDATE SCORE
const saveSymptomLog = async (req, res) => {
  try {
    const db = getDB();
    const log = req.body;

    // Save log
    await db.collection("logs").insertOne(log);

    //  UPDATE USER SYMPTOM SCORE
    await db.collection("users").updateOne(
      { uid: log.uid },
      {
        $inc: {
          [`symptom_scores.${log.primarySymptom}`]: 1
        }
      },
      { upsert: true }
    );

    res.json({ success: true });
  } catch (e) {
    console.error("Error saving log:", e);
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { saveSymptomLog };
