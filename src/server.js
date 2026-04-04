require("dotenv").config({ path: "D:/vytal/.env" });

const express = require("express");
const cors = require("cors"); //  ADDED
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

connectDB();

const app = express();

// ─────────────────────────────
// MIDDLEWARE
// ─────────────────────────────
app.use(cors()); //  IMPORTANT FOR FLUTTER
app.use(express.json());

// ── Existing route mounts ─────────────────────────────────────────────────────
app.use("/api/auth",      authRoutes);   // LOGIN + REGISTER WORK HERE
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

// ─────────────────────────────
// TEST ROUTE
// ─────────────────────────────
app.get("/", (req, res) => {
  res.send("Vytal backend is running");
});

// ─────────────────────────────
// GLOBAL ERROR HANDLER (DEBUG HELPER)
// ─────────────────────────────
app.use((err, req, res, next) => {
  console.error(" SERVER ERROR:", err);
  res.status(500).json({
    success: false,
    error: err.message || "Server Error",
  });
});

// ─────────────────────────────
// SERVER
// ─────────────────────────────
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
