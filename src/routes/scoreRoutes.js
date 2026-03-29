const express = require("express");
const router = express.Router();
const { saveSymptomLog } = require("../controllers/logController");

router.post("/", saveSymptomLog);

module.exports = router;
