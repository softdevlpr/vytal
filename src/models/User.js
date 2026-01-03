const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  user_id: {
    type: Number,
  },
  name: {
    type: String,
    required: true,
  },

  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
  },

  password_hash: {
    type: String,
    required: true,
  },

  date_of_birth: {
    type: Date,
  },

  gender: {
    type: String,
  },

  height: {
    type: Number,
  },

  weight: {
    type: Number,
  },

  created_at: {
    type: Date,
    default: Date.now,
  },

  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("User", userSchema, "users");
