const { getDB } = require("../config/db");

const clean = (doc) => {
  doc._id = doc._id.toString();
  return doc;
};

const sinceDate = (period) => {
  const now = new Date();
  if (period === "week") return new Date(now - 7 * 86400000);
  if (period === "month") return new Date(now - 30 * 86400000);
  return new Date(now - 365 * 86400000);
};

// ── POST /api/logs ─────────────────────────────────
const addLog = async (req, res) => {
  try {
    const db = getDB();
    const body = req.body || {};

    const { uid, primary_symptom } = body;

    if (!uid || !primary_symptom) {
      return res.status(400).json({
        success: false,
        error: "uid and primary_symptom required",
      });
    }

    // Save log
    body.logged_at = new Date().toISOString();
    await db.collection("symptom_logs").insertOne(body);

    // 🔥 UPDATE SCORE (FIXED)
    await db.collection("users").updateOne(
      { uid },
      {
        $inc: {
          [`symptom_scores.${primary_symptom}`]: 1,
        },
      },
      { upsert: true } // ✅ IMPORTANT FIX
    );

    res.json({
      success: true,
      data: { message: "Log saved & score updated" },
    });
  } catch (e) {
    console.error("[addLog ERROR]", e);
    res.status(500).json({ success: false, error: e.message });
  }
};

// ── GET /api/logs ─────────────────────────────────
const getLogs = async (req, res) => {
  try {
    const db = getDB();
    const { uid, period = "week" } = req.query;

    if (!uid) {
      return res.status(400).json({
        success: false,
        error: "uid required",
      });
    }

    const since = sinceDate(period);

    const logs = await db
      .collection("symptom_logs")
      .find({ uid, logged_at: { $gte: since.toISOString() } })
      .sort({ logged_at: -1 })
      .toArray();

    res.json({
      success: true,
      data: { logs: logs.map(clean), count: logs.length },
    });
  } catch (e) {
    console.error("[getLogs ERROR]", e);
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { addLog, getLogs };
