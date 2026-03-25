const express = require("express");
const router = express.Router();
const Reminder = require("../models/Reminder");

// CREATE reminder
router.post("/", async (req, res) => {
  try {
    console.log("POST HIT ✅");
    const reminder = await Reminder.create(req.body);
    res.json(reminder);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET all reminders
router.get("/", async (req, res) => {
  try {
    console.log("GET HIT ✅");
    const reminders = await Reminder.find();
    res.json(reminders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;