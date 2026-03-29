const { getDB } = require("../config/db");
const { ObjectId } = require("mongodb");

const clean = (doc) => { doc._id = doc._id.toString(); return doc; };

// GET /tips  (with personalisation if uid is passed)
const getTips = async (req, res) => {
  try {
    const db = getDB();
    const { category = "", symptoms = "", uid = "" } = req.query;
    const limit = parseInt(req.query.limit) || 5;

    const query = {};
    if (category) query.category = category;

    // ── Personalised path ────────────────────────────────────────────────────
    if (uid) {
      const user = await db.collection("users").findOne({ uid });

      if (user && user.symptom_scores) {
        // Pick top 3 symptoms by score
        const topSyms = Object.entries(user.symptom_scores)
          .filter(([, score]) => score > 0)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map(([sym]) => sym);

        if (topSyms.length) {
          // Grab tips that match user's top symptoms first
          const matched = await db
            .collection("lifestyle_tips")
            .find({ ...query, related_symptoms: { $in: topSyms } })
            .limit(limit)
            .toArray();

          if (matched.length >= limit) {
            return res.json({ success: true, data: matched.map(clean) });
          }

          // Top up remaining slots with non-matched tips
          const matchedIds = matched.map((m) => m._id);
          const rest = await db
            .collection("lifestyle_tips")
            .find({ ...query, _id: { $nin: matchedIds } })
            .limit(limit - matched.length)
            .toArray();

          return res.json({
            success: true,
            data: [...matched, ...rest].map(clean),
          });
        }
      }
    }

    // ── Generic / symptom-filtered path ─────────────────────────────────────
    if (symptoms) {
      const symList = symptoms.split(",").map((s) => s.trim());
      query.related_symptoms = { $in: symList };
    }

    const tips = await db
      .collection("lifestyle_tips")
      .find(query)
      .limit(limit)
      .toArray();

    res.json({ success: true, data: tips.map(clean) });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// GET /tips/for-symptom
const getTipsForSymptom = async (req, res) => {
  try {
    const db = getDB();
    const { symptom = "" } = req.query;
    const limit = parseInt(req.query.limit) || 3;

    const tips = await db
      .collection("lifestyle_tips")
      .find({ related_symptoms: symptom })
      .limit(limit)
      .toArray();

    res.json({ success: true, data: tips.map(clean) });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getTips, getTipsForSymptom };
