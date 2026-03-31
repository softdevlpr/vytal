const { getDB } = require("../config/db");

// Format a YYYY-MM-DD date string into a label based on period
const formatLabel = (dateStr, period) => {
  const d = new Date(dateStr);
  if (period === "week") {
    // e.g. "Mon", "Tue"
    return d.toLocaleDateString("en-US", { weekday: "short" });
  }
  if (period === "month") {
    // e.g. "05 Apr"
    return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short" });
  }
  // year → e.g. "Jan"
  return d.toLocaleDateString("en-US", { month: "short" });
};

// Build since/prev dates for the requested period
const getPeriodDates = (period) => {
  const now = new Date();
  if (period === "week") {
    return {
      since: new Date(now - 7   * 86400000),
      prev:  new Date(now - 14  * 86400000),
    };
  }
  if (period === "month") {
    return {
      since: new Date(now - 30  * 86400000),
      prev:  new Date(now - 60  * 86400000),
    };
  }
  return {
    since: new Date(now - 365  * 86400000),
    prev:  new Date(now - 730  * 86400000),
  };
};

// GET /insights
const getInsights = async (req, res) => {
  try {
    const db = getDB();
    const { uid, period = "week" } = req.query;

    if (!uid) {
      return res.status(400).json({ success: false, error: "uid required" });
    }

    const { since, prev } = getPeriodDates(period);

    // Current period logs
    const logs = await db
      .collection("symptom_logs")
      .find({ uid, logged_at: { $gte: since.toISOString() } })
      .toArray();

    if (!logs.length) {
      return res.json({ success: true, data: {} });
    }

    // Aggregate symptom frequency, urgency counts, and daily severity scores
    const symFreq      = {};
    const urgencyCount = {};
    const chartByDay   = {};

    for (const log of logs) {
      const sym     = log.primary_symptom || "";
      const urgency = log.urgency || "Routine";
      const day     = (log.logged_at || "").slice(0, 10);
      const score   = log.severity_score || 0;

      symFreq[sym]         = (symFreq[sym]         || 0) + 1;
      urgencyCount[urgency] = (urgencyCount[urgency] || 0) + 1;

      if (!chartByDay[day]) chartByDay[day] = [];
      chartByDay[day].push(score);
    }

    // Build chart points — one point per day, averaged severity
    const chartPoints = Object.keys(chartByDay)
      .sort()
      .map((day) => {
        const scores = chartByDay[day];
        const avg    = scores.reduce((a, b) => a + b, 0) / scores.length;
        return {
          label: formatLabel(day, period),
          score: Math.round(avg * 10) / 10, // 1 decimal
        };
      });

    // Top symptom by frequency
    const topSymptom = Object.keys(symFreq).length
      ? Object.keys(symFreq).reduce((a, b) => (symFreq[a] > symFreq[b] ? a : b))
      : "None";

    // Previous period logs for improvement comparison
    const prevLogs = await db
      .collection("symptom_logs")
      .find({
        uid,
        logged_at: {
          $gte: prev.toISOString(),
          $lt:  since.toISOString(),
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

    // Sort symptom_frequency descending before sending
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
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getInsights };
