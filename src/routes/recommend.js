const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");

router.post("/recommend", async (req, res) => {
  try {
    const { user_id, symptom_id, intensity, details } = req.body;

    if (!user_id || !symptom_id || !intensity) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const db = mongoose.connection.db;

    await db.collection("user_symptom_logs").insertOne({
      user_id,
      symptom_id,
      intensity,
      details: details || "",
      logged_at: new Date(),
    });

    const symptomTest = await db.collection("symptoms_tests").findOne({
      Symptom_id: symptom_id,
    });

    let testIds = [];
    if (symptomTest) {
      const key = `intensity${intensity}`;
      if (symptomTest[key]) {
        testIds.push(symptomTest[key]);
      }
    }

    const tests = await db
      .collection("tests")
      .find({ test_id: { $in: testIds } })
      .toArray();

    const causeMapping = await db
      .collection("symptom_possibleCauses")
      .find({ symptom_id })
      .toArray();

    const causeIds = causeMapping.map((c) => c.cause_id);

    if (testIds.length === 0 && causeIds.length === 0) {
      return res.json({
        recommendedTests: [],
        possibleCauses: [],
        message: "No recommendations available for this symptom",
      });
    }

    const causes = await db
      .collection("possibleCauses")
      .find({ cause_id: { $in: causeIds } })
      .toArray();

    const formattedTests = tests.map((t) => ({
      test_id: t.test_id,
      test_name: t["test_name "] || t.test_name,
    }));

    const formattedCauses = causes.map((c) => ({
      cause_id: c.cause_id,
      cause_name: c["cause_name "] || c.cause_name,
    }));

    res.json({
      recommendedTests: formattedTests,
      possibleCauses: formattedCauses,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
