const mongoose = require("mongoose");

const affirmationSchema = new mongoose.Schema({
  affirmation_id: String,
  affirmation: String,
});

module.exports = mongoose.model("Affirmation", affirmationSchema);
