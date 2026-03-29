const express = require("express");
const router  = express.Router();
const {
  getReminders,
  addReminder,
  deleteReminder,
  toggleReminder,
} = require("../controllers/reminderController");

router.get("/",         getReminders);
router.post("/",        addReminder);
router.delete("/:rid",  deleteReminder);
router.patch("/:rid",   toggleReminder);

module.exports = router;
