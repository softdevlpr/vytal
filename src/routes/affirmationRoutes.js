const express = require("express");
const router = express.Router();
const {
  getRandomAffirmation,
} = require("../controllers/affirmationController");

router.get("/affirmations/random", getRandomAffirmation);

module.exports = router;
