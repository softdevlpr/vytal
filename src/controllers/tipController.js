const { getDB } = require("../config/db");
const { ObjectId } = require("mongodb");

const clean = (doc) => { doc._id = doc._id.toString(); return doc; };

// GET /api/tips
const getTips = async (req, res) => {
  try {
    const db = getDB();
    const { category = "", symptoms = "", uid = "" } = req.query;
    const limit = parseInt(req.query.limit) || 5;

    console.log(`\n[getTips] called with → category: "${category}", uid: "${uid}", limit: ${limit}`);

    const query = {};
    if (category) query.category = category;

    console.log(`[getTips] MongoDB query: ${JSON.stringify(query)}`);

    // ── Personalised path ────────────────────────────────────────────────────
    if (uid) {
      const user = await db.collection("users").findOne({ uid });
      console.log(`[getTips] user found: ${!!user}`);

      if (user && user.symptom_scores) {
        const topSyms = Object.entries(user.symptom_scores)
          .filter(([, score]) => score > 0)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map(([sym]) => sym);

        console.log(`[getTips] topSyms: ${JSON.stringify(topSyms)}`);

        if (topSyms.length) {
          const matched = await db
            .collection("lifestyle_tips")
            .find({ ...query, related_symptoms: { $in: topSyms } })
            .limit(limit)
            .toArray();

          console.log(`[getTips] personalised matched count: ${matched.length}`);

          if (matched.length >= limit) {
            return res.json({ success: true, data: matched.map(clean) });
          }

          const matchedIds = matched.map((m) => m._id);
          const rest = await db
            .collection("lifestyle_tips")
            .find({ ...query, _id: { $nin: matchedIds } })
            .limit(limit - matched.length)
            .toArray();

          console.log(`[getTips] topped up with ${rest.length} more tips`);

          return res.json({
            success: true,
            data: [...matched, ...rest].map(clean),
          });
        }
      }
    }

    // ── Generic path ─────────────────────────────────────────────────────────
    if (symptoms) {
      const symList = symptoms.split(",").map((s) => s.trim());
      query.related_symptoms = { $in: symList };
    }

    // DEBUG: check what's actually in the collection
    const totalInCollection = await db.collection("lifestyle_tips").countDocuments({});
    const totalMatchingQuery = await db.collection("lifestyle_tips").countDocuments(query);
    console.log(`[getTips] lifestyle_tips total docs: ${totalInCollection}`);
    console.log(`[getTips] docs matching query: ${totalMatchingQuery}`);

    // DEBUG: log one sample doc so we can see real field names
    const sample = await db.collection("lifestyle_tips").findOne({});
    console.log(`[getTips] sample doc from collection: ${JSON.stringify(sample)}`);

    const tips = await db
      .collection("lifestyle_tips")
      .find(query)
      .limit(limit)
      .toArray();

    console.log(`[getTips] returning ${tips.length} tips\n`);

    res.json({ success: true, data: tips.map(clean) });
  } catch (e) {
    console.error(`[getTips] ERROR: ${e.message}`);
    res.status(500).json({ success: false, error: e.message });
  }
};

// GET /api/tips/for-symptom
const getTipsForSymptom = async (req, res) => {
  try {
    const db = getDB();
    const { symptom = "" } = req.query;
    const limit = parseInt(req.query.limit) || 3;

    console.log(`\n[getTipsForSymptom] symptom: "${symptom}", limit: ${limit}`);

    const tips = await db
      .collection("lifestyle_tips")
      .find({ related_symptoms: symptom })
      .limit(limit)
      .toArray();

    console.log(`[getTipsForSymptom] returning ${tips.length} tips\n`);

    res.json({ success: true, data: tips.map(clean) });
  } catch (e) {
    console.error(`[getTipsForSymptom] ERROR: ${e.message}`);
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getTips, getTipsForSymptom };
