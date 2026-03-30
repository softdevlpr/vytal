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

    console.log("\n==================== GET TIPS ====================");
    console.log("Query Params:", { category, symptoms, uid, limit });

    const baseQuery = {};
    if (category) baseQuery.category = category;

    // ─────────────────────────────────────────
    // PERSONALIZED (UID BASED)
    // ─────────────────────────────────────────
    if (uid) {
      console.log("[STEP] Checking personalized tips...");

      const user = await db.collection("users").findOne({
        _id: uid, // FIXED
      });

      console.log("[DEBUG] User found:", user ? "YES" : "NO");

      if (user && user.symptom_scores) {
        const topSyms = Object.entries(user.symptom_scores)
          .filter(([, score]) => score > 0)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map(([sym]) => sym);

        console.log("[DEBUG] Top symptoms:", topSyms);

        if (topSyms.length) {
          const regexArray = topSyms.map(
            (s) => new RegExp(`^${s}$`, "i")
          );

          const matched = await db
            .collection("lifestyle_tips")
            .find({
              ...baseQuery,
              symptoms: { $in: regexArray },
            })
            .limit(limit)
            .toArray();

          console.log("[DEBUG] Personalized matched:", matched.length);

          if (matched.length >= limit) {
            return res.json({
              success: true,
              data: matched.map(clean),
            });
          }

          const matchedIds = matched.map((m) => m._id);

          const rest = await db
            .collection("lifestyle_tips")
            .find({
              ...baseQuery,
              _id: { $nin: matchedIds },
            })
            .limit(limit - matched.length)
            .toArray();

          console.log("[DEBUG] Fallback tips added:", rest.length);

          return res.json({
            success: true,
            data: [...matched, ...rest].map(clean),
          });
        }
      }
    }

    // ─────────────────────────────────────────
    // NORMAL FLOW (NO UID)
    // ─────────────────────────────────────────
    let query = { ...baseQuery };

    if (symptoms) {
      const symList = symptoms.split(",").map((s) => s.trim());

      console.log("[STEP] Filtering by symptoms:", symList);

      // FIX: CASE-INSENSITIVE MATCH
      query.symptoms = {
        $in: symList.map((s) => new RegExp(`^${s}$`, "i")),
      };
    }

    console.log("[DEBUG] Final Mongo Query:", JSON.stringify(query));

    let tips = await db
      .collection("lifestyle_tips")
      .find(query)
      .limit(limit)
      .toArray();

    console.log("[DEBUG] Matched tips:", tips.length);

    // ─────────────────────────────────────────
    // FALLBACK IF NO MATCH
    // ─────────────────────────────────────────
    if (tips.length === 0) {
      console.log("[STEP] No tips found → using fallback");

      tips = await db
        .collection("lifestyle_tips")
        .find(baseQuery)
        .limit(limit)
        .toArray();

      console.log("[DEBUG] Fallback tips:", tips.length);
    }

    console.log("================================================\n");

    res.json({
      success: true,
      data: tips.map(clean),
    });
  } catch (e) {
    console.error("[getTips] ERROR:", e);
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

    console.log("\n=========== GET TIPS FOR SYMPTOM ===========");
    console.log("Symptom:", symptom);

    const tips = await db
      .collection("lifestyle_tips")
      .find({
        symptoms: {
          $in: [new RegExp(`^${symptom}$`, "i")],
        },
      })
      .limit(limit)
      .toArray();

    console.log("Tips found:", tips.length);
    console.log("===========================================\n");

    res.json({
      success: true,
      data: tips.map(clean),
    });
  } catch (e) {
    console.error("[getTipsForSymptom] ERROR:", e);
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getTips, getTipsForSymptom };
