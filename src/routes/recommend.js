const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");

router.post("/recommend", async (req, res) => {
  try {
    console.log("==== /recommend HIT ====");
    console.log("BODY:", req.body);

    const { user_id, symptom_name, intensity, details } = req.body;

    // ✅ Explicit validation (no truthy bugs)
    if (
      typeof user_id !== "string" ||
      typeof symptom_name !== "string" ||
      typeof intensity !== "number"
    ) {
      return res.status(400).json({
        message: "Invalid or missing fields",
        received: req.body,
      });
    }

    const db = mongoose.connection.db;

    // 1️⃣ Find symptom_id from symptoms collection
    const symptomDoc = await db.collection("symptoms").findOne({
      symptom_name: symptom_name,
    });

    if (!symptomDoc) {
      return res.status(404).json({ message: "Symptom not found" });
    }

    const symptom_id = symptomDoc.symptom_id; // e.g. S0001

    // 2️⃣ Log user symptom
    await db.collection("user_symptom_logs").insertOne({
      user_id,
      symptom_id,
      symptom_name,
      intensity,
      details: details || "",
      logged_at: new Date(),
    });

    // 3️⃣ Fetch test mapping
    const symptomTest = await db.collection("symptoms_tests").findOne({
      Symptom_id: symptom_id,
    });

    let testIds = [];
    if (symptomTest) {
      const key = `intensity${intensity}`; // intensity3
      if (symptomTest[key]) {
        testIds.push(symptomTest[key]);
      }
    }

    // 4️⃣ Fetch tests
    const tests = testIds.length
      ? await db
          .collection("tests")
          .find({ test_id: { $in: testIds } })
          .toArray()
      : [];

    // 5️⃣ Fetch possible causes
    const causeMapping = await db
      .collection("symptom_possibleCauses")
      .find({ symptom_id: symptom_id })
      .toArray();

    const causeIds = causeMapping.map((c) => c.cause_id);

    const causes = causeIds.length
      ? await db
          .collection("possibleCauses")
          .find({ cause_id: { $in: causeIds } })
          .toArray()
      : [];

    const formattedTests = tests.map((t) => ({
      name: (t.test_name || t["test_name "])?.trim(),
      purpose: (t["test_purpose "] || "").trim(),
    }));

    const formattedCauses = causes.map((c) => ({
      name: (c.cause_name || c["cause_name "])?.trim(),
      description: (c["cause_description "] || "").trim(),
    }));

    return res.json({
      recommendedTests: formattedTests,
      possibleCauses: formattedCauses,
    });
  } catch (err) {
    console.error("🔥 RECOMMEND ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
