const express = require("express");
const router = express.Router();

const { predictTests } = require("../controllers/mlController");

router.post("/predict-tests", predictTests);

module.exports = router;
