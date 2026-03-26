const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI);

    console.log("MongoDB Connected");
    console.log("DB NAME:", conn.connection.db.databaseName); // ✅ correct
  } catch (error) {
    console.error("DB Connection Error ❌", error);
    process.exit(1);
  }
};

module.exports = connectDB;
