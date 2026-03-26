require("dotenv").config({ path: "D:/vytal/.env" });

const express = require("express");
const connectDB = require("./config/db");

// Routes
const authRoutes = require("./routes/authRoutes");
const profileRoutes = require("./routes/profileRoutes");
const recommendRoute = require("./routes/recommend");
const affirmationRoutes = require("./routes/affirmationRoutes");
const mlRoutes = require("./routes/mlRoutes");
const reminderRoutes = require("./routes/reminderRoutes");

// Connect to DB (ONLY ONCE)
connectDB();

const app = express();
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/user", profileRoutes);
app.use("/api", recommendRoute);
app.use("/api", affirmationRoutes);
app.use("/api/ml", mlRoutes);
app.use("/api/reminders", reminderRoutes);

// Test route
app.get("/", (req, res) => {
  res.send("Vytal backend is running");
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
