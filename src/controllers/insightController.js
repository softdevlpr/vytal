const { getDB } = require("../config/db");

// Format date label
const formatLabel = (dateStr, period) => {
  const d = new Date(dateStr);
  if (period === "week") {
    return d.toLocaleDateString("en-US", { weekday: "short" });
  }
  if (period === "month") {
    return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short" });
  }
  return d.toLocaleDateString("en-US", { month: "short" });
};

// Period calculation
const getPeriodDates = (period) => {
  const now = new Date();
  if (period === "week") {
    return {
      since: new Date(now - 7 * 86400000),
      prev: new Date(now - 14 * 86400000),
    };
  }
  if (period === "month") {
    return {
      since: new Date(now - 30 * 86400000),
      prev: new Date(now - 60 * 86400000),
    };
  }
  return {
    since: new Date(now - 365 * 86400000),
    prev: new Date(now - 730 * 86400000),
  };
};

// GET /insights
const getInsights = async (req, res) => {
  try {
    const db = getDB();

    let { uid, period = "week" } = req.query;

    // ✅ FIX: ensure uid is string
    uid = String(uid);

    console.log("Incoming UID:", uid);
    console.log("Period:", period);

    if (!uid || uid === "null" || uid === "undefined") {
      return res.status(400).json({
        success: false,
        error: "valid uid required",
      });
    }

    const { since, prev } = getPeriodDates(period);

    // ✅ FILTER BY UID (already correct, kept)
    const logs = await db
      .collection("symptom_logs")
      .find({
        uid: uid,
        logged_at: { $gte: since.toISOString() },
      })
      .toArray();

    console.log("Logs found:", logs.length);

    if (!logs.length) {
      return res.json({ success: true, data: {} });
    }

    const symFreq = {};
    const urgencyCount = {};
    const chartByDay = {};

    for (const log of logs) {
      const sym = log.primary_symptom || "";
      const urgency = log.urgency || "Routine";
      const day = (log.logged_at || "").slice(0, 10);
      const score = log.severity_score || 0;

      symFreq[sym] = (symFreq[sym] || 0) + 1;
      urgencyCount[urgency] = (urgencyCount[urgency] || 0) + 1;

      if (!chartByDay[day]) chartByDay[day] = [];
      chartByDay[day].push(score);
    }

    const chartPoints = Object.keys(chartByDay)
      .sort()
      .map((day) => {
        const scores = chartByDay[day];
        const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
        return {
          label: formatLabel(day, period),
          score: Math.round(avg * 10) / 10,
        };
      });

    const topSymptom = Object.keys(symFreq).length
      ? Object.keys(symFreq).reduce((a, b) =>
          symFreq[a] > symFreq[b] ? a : b
        )
      : "None";

    const prevLogs = await db
      .collection("symptom_logs")
      .find({
        uid: uid,
        logged_at: {
          $gte: prev.toISOString(),
          $lt: since.toISOString(),
        },
      })
      .toArray();

    const prevUrgent = prevLogs.filter((l) => l.urgency === "Urgent").length;
    const currUrgent = urgencyCount["Urgent"] || 0;

    let improvement = null;
    if (prevUrgent > currUrgent) {
      improvement = `Great progress! Your Urgent symptom instances dropped from ${prevUrgent} to ${currUrgent} compared to the previous period.`;
    } else if (prevUrgent === 0 && currUrgent === 0) {
      improvement = "You had no urgent symptoms this period. Keep it up!";
    }

    const symptomFrequency = Object.fromEntries(
      Object.entries(symFreq).sort((a, b) => b[1] - a[1])
    );

    res.json({
      success: true,
      data: {
        total_logs: logs.length,
        top_symptom: topSymptom,
        urgency_breakdown: urgencyCount,
        symptom_frequency: symptomFrequency,
        chart_points: chartPoints,
        improvement,
      },
    });
  } catch (e) {
    console.error("Insights error:", e);
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getInsights };
