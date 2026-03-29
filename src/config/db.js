const mongoose = require("mongoose");
const { MongoClient } = require("mongodb");

let nativeDB; // used by new controllers (logs, tips, clinics, etc.)

const connectDB = async () => {
  try {
    // ── Mongoose connection (existing — keeps your models/auth working) ──────
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ Mongoose connected");
    console.log("DB NAME:", conn.connection.db.databaseName);

    // ── Native MongoDB driver (new controllers need getDB()) ─────────────────
    // Reuse the same underlying connection that Mongoose already opened
    nativeDB = conn.connection.db;
    console.log("✅ Native MongoDB client ready");

  } catch (error) {
    console.error("❌ DB Connection Error:", error);
    process.exit(1);
  }
};

// New controllers call this to get the native db instance
const getDB = () => {
  if (!nativeDB) throw new Error("DB not initialised. Call connectDB() first.");
  return nativeDB;
};

module.exports = connectDB;           // existing imports stay unbroken
module.exports.getDB = getDB;         // new controllers use this
