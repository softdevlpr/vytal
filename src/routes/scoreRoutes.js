const express = require("express");
const router = express.Router();
const { saveSymptomLog } = require("../controllers/scoreController");

router.post("/", saveSymptomLog);

module.exports = router;
