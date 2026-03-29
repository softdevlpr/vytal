const { getDB } = require("../config/db");

const clean = (doc) => {
  doc._id = doc._id.toString();
  return doc;
};

// ─────────────────────────────────────────
// GET /api/tips
// ─────────────────────────────────────────
const getTips = async (req, res) => {
  try {
    const db = getDB();
    const { category = "", symptoms = "", uid = "" } = req.query;
    const limit = parseInt(req.query.limit) || 5;

    console.log(`\n[getTips] → category: "${category}", uid: "${uid}", limit: ${limit}`);

    const baseQuery = {};
    if (category) baseQuery.category = category;

    // ─────────────────────────────
    // PERSONALIZED (using user data)
    // ─────────────────────────────
    if (uid) {
      const user = await db.collection("users").findOne({ uid });

      if (user && user.symptom_scores) {
        const topSyms = Object.entries(user.symptom_scores)
          .filter(([, score]) => score > 0)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map(([sym]) => sym);

        console.log(`[getTips] top symptoms: ${JSON.stringify(topSyms)}`);

        if (topSyms.length) {
          const matched = await db
            .collection("lifestyle_tips")
            .find({
              ...baseQuery,
              symptoms: {
                $in: topSyms.map((s) => new RegExp(s, "i")),
              },
            })
            .limit(limit)
            .toArray();

          console.log(`[getTips] personalized matched: ${matched.length}`);

          if (matched.length >= limit) {
            return res.json({
              success: true,
              data: matched.map(clean),
            });
          }

          // fallback (fill remaining)
          const matchedIds = matched.map((m) => m._id);

          const rest = await db
            .collection("lifestyle_tips")
            .find({
              ...baseQuery,
              _id: { $nin: matchedIds },
            })
            .limit(limit - matched.length)
            .toArray();

          return res.json({
            success: true,
            data: [...matched, ...rest].map(clean),
          });
        }
      }
    }

    // ─────────────────────────────
    // GENERIC (based on symptoms)
    // ─────────────────────────────
    let query = { ...baseQuery };

    if (symptoms) {
      const symList = symptoms.split(",").map((s) => s.trim());

      query.symptoms = {
        $in: symList.map((s) => new RegExp(s, "i")),
      };
    }

    console.log(`[getTips] final query: ${JSON.stringify(query)}`);

    const tips = await db
      .collection("lifestyle_tips")
      .find(query)
      .limit(limit)
      .toArray();

    console.log(`[getTips] returning ${tips.length} tips\n`);

    res.json({
      success: true,
      data: tips.map(clean),
    });
  } catch (e) {
    console.error(`[getTips] ERROR: ${e.message}`);
    res.status(500).json({ success: false, error: e.message });
  }
};

// ─────────────────────────────────────────
// GET /api/tips/for-symptom
// ─────────────────────────────────────────
const getTipsForSymptom = async (req, res) => {
  try {
    const db = getDB();
    const { symptom = "" } = req.query;
    const limit = parseInt(req.query.limit) || 3;

    console.log(`\n[getTipsForSymptom] → symptom: "${symptom}", limit: ${limit}`);

    const tips = await db
      .collection("lifestyle_tips")
      .find({
        symptoms: {
          $in: [new RegExp(symptom, "i")],
        },
      })
      .limit(limit)
      .toArray();

    console.log(`[getTipsForSymptom] returning ${tips.length} tips\n`);

    res.json({
      success: true,
      data: tips.map(clean),
    });
  } catch (e) {
    console.error(`[getTipsForSymptom] ERROR: ${e.message}`);
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getTips, getTipsForSymptom };
