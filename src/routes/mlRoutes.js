const express = require("express");
const { predictTests } = require("../controllers/mlController");

const router = express.Router();

router.post("/predict-tests", predictTests);

module.exports = router; // ✅ IMPORTANT
