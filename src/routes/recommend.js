const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");

router.post("/recommend", async (req, res) => {
  try {
    console.log("==== /recommend HIT ====");
    console.log("HEADERS:", req.headers);
    console.log("BODY:", req.body);

    // 🔴 NO VALIDATION AT ALL
    return res.status(200).json({
      message: "DEBUG SUCCESS",
      receivedBody: req.body,
    });
  } catch (err) {
    console.error("🔥 ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
