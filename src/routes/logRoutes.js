const express = require("express");
const router  = express.Router();
const { addLog, getLogs } = require("../controllers/logController");

router.post("/", addLog);
router.get("/",  getLogs);

module.exports = router;
