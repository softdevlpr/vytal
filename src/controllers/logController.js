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

    let { uid, primary_symptom } = body;

    // ✅ FIX: ensure uid is string
    uid = String(uid);

    console.log("Incoming UID:", uid);

    // ✅ FIX: reject invalid UID
    if (
      !uid ||
      uid === "null" ||
      uid === "undefined" ||
      uid === "current_user_uid"
    ) {
      return res.status(400).json({
        success: false,
        error: "valid uid required",
      });
    }

    if (!primary_symptom) {
      return res.status(400).json({
        success: false,
        error: "primary_symptom required",
      });
    }

    // ✅ FIX: create clean log object instead of inserting raw body
    const log = {
      uid: uid,
      primary_symptom: body.primary_symptom,
      answers: body.answers || {},
      urgency: body.urgency || "Routine",
      recommended_tests: body.recommended_tests || [],
      severity_score: body.severity_score || 0,
      logged_at: new Date().toISOString(),
      week_number: body.week_number,
      month: body.month,
      year: body.year,
    };

    console.log("Saving log:", log);

    await db.collection("symptom_logs").insertOne(log);

    // Update user stats
    await db.collection("users").updateOne(
      { uid: uid },
      {
        $inc: {
          [`symptom_scores.${primary_symptom}`]: 1,
        },
      },
      { upsert: true }
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
    let { uid, period = "week" } = req.query;

    uid = String(uid);

    if (!uid || uid === "null" || uid === "undefined") {
      return res.status(400).json({
        success: false,
        error: "uid required",
      });
    }

    const since = sinceDate(period);

    const logs = await db
      .collection("symptom_logs")
      .find({ uid: uid, logged_at: { $gte: since.toISOString() } })
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
