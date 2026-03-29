const express = require("express");
const router  = express.Router();
const { getTips, getTipsForSymptom } = require("../controllers/tipController");

// Order matters — specific route before param route
router.get("/for-symptom", getTipsForSymptom);
router.get("/",            getTips);

module.exports = router;
