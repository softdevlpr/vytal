const express = require("express");
const router = express.Router();

router.post("/predict-tests", (req, res) => {
  console.log("ML ROUTE HIT 🔥");
  res.json({ message: "ML working" });
});

module.exports = router;
