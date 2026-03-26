const Reminder = require("../models/reminder.model");

exports.createReminder = async (req, res) => {
  try {
    console.log("API HIT 🔥");
    console.log("Body:", req.body);

    const { userId, title, notes, timeOfDay, isRecurring, daysOfWeek } =
      req.body;

    // 🔹 Basic validation (important)
    if (userId === undefined || !title || !timeOfDay) {
      return res.status(400).json({
        message: "userId, title and timeOfDay are required",
      });
    }

    const reminder = new Reminder({
      userId,
      title,
      notes: notes || "",
      timeOfDay,
      isRecurring: isRecurring || false,
      daysOfWeek: daysOfWeek || [],
    });
    console.log("Before Save 🚀");

    const savedReminder = await reminder.save();

    console.log("Saved in DB ✅", savedReminder);

    res.status(201).json({
      message: "Reminder created successfully",
      reminder: savedReminder,
    });
  } catch (error) {
    console.error("ERROR ❌", error);

    res.status(500).json({
      message: "Error creating reminder",
      error: error.message,
    });
  }
};
