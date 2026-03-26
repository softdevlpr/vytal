const mongoose = require("mongoose");

const reminderSchema = new mongoose.Schema(
  {
    userId: {
      type: Number, // INT(100)
      required: true,
    },

    title: {
      type: String, // VARCHAR(500)
      required: true,
    },

    notes: {
      type: String, // TEXT
      default: "",
    },

    timeOfDay: {
      type: String, // TIME (store as "HH:mm")
      required: true,
    },

    isRecurring: {
      type: Boolean,
      default: false,
    },

    daysOfWeek: {
      type: [String], // ["Mon", "Tue"]
      default: [],
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: { createdAt: "created_at", updatedAt: false },
  },
);

module.exports = mongoose.model("Reminder", reminderSchema);
