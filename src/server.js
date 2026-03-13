require("dotenv").config({ path: "D:/vytal/.env" });

const express = require("express");
const mongoose = require("mongoose");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const profileRoutes = require("./routes/profileRoutes");
const recommendRoute = require("./routes/recommend");
const affirmationRoutes = require("./routes/affirmationRoutes");

connectDB();

const app = express();
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/user", profileRoutes);
app.use("/api", recommendRoute);
app.use("/api", affirmationRoutes);

app.get("/", (req, res) => {
  res.send("Vytal backend is running");
});

const PORT = process.env.PORT || 5000;

//for now
const User = require("./models/User");

/*app.get("/debug/where-is-my-data", async (req, res) => {
  const users = await User.find({});
  res.json({
    database: mongoose.connection.name,
    count: users.length,
    users,
  });
});*/

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
