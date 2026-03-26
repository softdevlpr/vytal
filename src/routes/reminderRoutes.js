const express = require("express");
const router = express.Router();

const reminderController = require("../controllers/reminderController");

// 🔥 CREATE REMINDER
router.post("/", reminderController.createReminder);

// 🔥 GET REMINDERS BY USER
router.get("/", async (req, res) => {
  try {
    const { userId } = req.query;

    console.log("GET REMINDERS 🔥 userId:", userId);

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const Reminder = require("../models/reminder.model");

    const reminders = await Reminder.find({
      userId: Number(userId),
    });

    res.status(200).json(reminders);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching reminders" });
  }
});

module.exports = router;
