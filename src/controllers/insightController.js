const { getDB } = require("../config/db");

// Format label
const formatLabel = (dateStr, period) => {
  const d = new Date(dateStr);

  if (period === "week") {
    return d.toLocaleDateString("en-US", { weekday: "short" });
  }
  if (period === "month") {
    return d.toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
    });
  }
  return d.toLocaleDateString("en-US", { month: "short" });
};

// Period dates
const getPeriodDates = (period) => {
  const now = new Date();

  if (period === "week") {
    return {
      since: new Date(now.getTime() - 7 * 86400000),
      prev: new Date(now.getTime() - 14 * 86400000),
    };
  }

  if (period === "month") {
    return {
      since: new Date(now.getTime() - 30 * 86400000),
      prev: new Date(now.getTime() - 60 * 86400000),
    };
  }

  return {
    since: new Date(now.getTime() - 365 * 86400000),
    prev: new Date(now.getTime() - 730 * 86400000),
  };
};

// GET /insights
const getInsights = async (req, res) => {
  try {
    const db = getDB();
    const { uid, period = "week" } = req.query;

    console.log(" INSIGHTS API HIT:", { uid, period });

    if (!uid) {
      return res.status(400).json({
        success: false,
        error: "uid required",
      });
    }

    const { since, prev } = getPeriodDates(period);

    // FETCH ALL USER LOGS FIRST
    const allLogs = await db
      .collection("symptom_logs")
      .find({ uid })
      .toArray();

    console.log(" TOTAL LOGS FOUND:", allLogs.length);

    // FILTER IN JS (FIXED)
    const logs = allLogs.filter((log) => {
      if (!log.logged_at) return false;
      const d = new Date(log.logged_at);
      return d >= since;
    });

    console.log(" FILTERED LOGS:", logs.length);

    if (!logs.length) {
      return res.json({ success: true, data: {} });
    }

    const symFreq = {};
    const urgencyCount = {};
    const chartByDay = {};

    for (const log of logs) {
      const sym = log.primary_symptom || "Unknown";
      const urgency = log.urgency || "Routine";
      const score = log.severity_score || 0;

      const day = new Date(log.logged_at)
        .toISOString()
        .slice(0, 10);

      symFreq[sym] = (symFreq[sym] || 0) + 1;
      urgencyCount[urgency] = (urgencyCount[urgency] || 0) + 1;

      if (!chartByDay[day]) chartByDay[day] = [];
      chartByDay[day].push(score);
    }

    const chartPoints = Object.keys(chartByDay)
      .sort()
      .map((day) => {
        const scores = chartByDay[day];
        const avg =
          scores.reduce((a, b) => a + b, 0) / scores.length;

        return {
          label: formatLabel(day, period),
          score: Number(avg.toFixed(1)),
        };
      });

    const topSymptom = Object.keys(symFreq).reduce((a, b) =>
      symFreq[a] > symFreq[b] ? a : b
    );

    // PREVIOUS LOGS
    const prevLogs = allLogs.filter((log) => {
      if (!log.logged_at) return false;
      const d = new Date(log.logged_at);
      return d >= prev && d < since;
    });

    const prevUrgent = prevLogs.filter(
      (l) => l.urgency === "Urgent"
    ).length;

    const currUrgent = urgencyCount["Urgent"] || 0;

    let improvement = null;

    if (prevUrgent > currUrgent) {
      improvement = `Great progress! Urgent cases reduced from ${prevUrgent} to ${currUrgent}`;
    } else if (prevUrgent === 0 && currUrgent === 0) {
      improvement = "No urgent symptoms. Keep it up!";
    }

    const symptomFrequency = Object.fromEntries(
      Object.entries(symFreq).sort((a, b) => b[1] - a[1])
    );

    console.log("INSIGHTS RESPONSE READY");

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
    console.error(" INSIGHTS ERROR:", e);
    res.status(500).json({
      success: false,
      error: e.message,
    });
  }
};

module.exports = { getInsights };
