const { getDB } = require("../config/db");

// Helper: convert _id ObjectId → string for JSON response
const clean = (doc) => {
  doc._id = doc._id.toString();
  return doc;
};

// Helper: compute "since" date from period string
const sinceDate = (period) => {
  const now = new Date();
  if (period === "week")  return new Date(now - 7   * 86400000);
  if (period === "month") return new Date(now - 30  * 86400000);
  return                         new Date(now - 365 * 86400000); // year
};

// ── POST /logs ────────────────────────────────────────────────────────────────
const addLog = async (req, res) => {
  try {
    const db = getDB();
    const body = req.body || {};
    const { uid, primary_symptom: symptom } = body;

    if (!uid) {
      return res.status(400).json({ success: false, error: "uid required" });
    }

    // Stamp the log with current UTC time
    body.logged_at = new Date().toISOString();
    await db.collection("symptom_logs").insertOne(body);

    // Increment symptom score on the user doc
    if (symptom) {
      await db.collection("users").updateOne(
        { uid },
        { $inc: { [`symptom_scores.${symptom}`]: 1 } }
      );
    }

    res.json({ success: true, data: { message: "Log saved" } });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// ── GET /logs ─────────────────────────────────────────────────────────────────
const getLogs = async (req, res) => {
  try {
    const db = getDB();
    const { uid, period = "week" } = req.query;

    if (!uid) {
      return res.status(400).json({ success: false, error: "uid required" });
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
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { addLog, getLogs };
