require("dotenv").config({ path: "D:/vytal/.env" });
const express = require("express");
const connectDB = require("./config/db");

const authRoutes        = require("./routes/authRoutes");
const profileRoutes     = require("./routes/profileRoutes");
const recommendRoute    = require("./routes/recommend");
const affirmationRoutes = require("./routes/affirmationRoutes");
const mlRoutes          = require("./routes/mlRoutes");
const reminderRoutes    = require("./routes/reminderRoutes");
const predictRoutes     = require("./routes/predictRoutes");
const logRoutes         = require("./routes/logRoutes");
const insightRoutes     = require("./routes/insightRoutes");
const tipRoutes         = require("./routes/tipRoutes");
const clinicRoutes      = require("./routes/clinicRoutes");
const userRoutes        = require("./routes/userRoutes");
const scoreRoutes = require("./routes/scoreRoutes");

connectDB();

const app = express();
app.use(express.json());

// ── Existing route mounts ─────────────────────────────────────────────────────
app.use("/api/auth",      authRoutes);
app.use("/api/user",      profileRoutes);
app.use("/api",           recommendRoute);
app.use("/api",           affirmationRoutes);
app.use("/api/ml",        mlRoutes);
app.use("/api/reminders", reminderRoutes);

app.use("/api/predict",   predictRoutes);
app.use("/api/logs",      logRoutes);
app.use("/api/insights",  insightRoutes);
app.use("/api/tips",      tipRoutes);
app.use("/api/clinics",   clinicRoutes);
app.use("/api/users",     userRoutes);
app.use("/api/score", scoreRoutes);

// Test route
app.get("/", (req, res) => {
  res.send("Vytal backend is running");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
