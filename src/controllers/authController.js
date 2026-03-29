const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

//  TOKEN GENERATOR
const generateToken = (id) => {
  return jwt.sign(
    { id },
    process.env.JWT_SECRET || "secret123", //  fallback added
    { expiresIn: "30d" }
  );
};

// ─────────────────────────────
// REGISTER USER
// ─────────────────────────────
const registerUser = async (req, res) => {
  const { name, email, password, age, gender } = req.body;

  try {
    //  VALIDATION
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        error: "All required fields missing",
      });
    }

    //  CHECK EXISTING USER
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({
        success: false,
        error: "User already exists",
      });
    }

    //  HASH PASSWORD
    const password_hash = await bcrypt.hash(password, 10);

    //  CREATE USER
    const user = await User.create({
      name,
      email,
      password_hash,
      gender: gender || null,
      date_of_birth: age ? new Date() : null, // optional mapping
    });

    //  RESPONSE FORMAT FIXED
    return res.status(201).json({
      success: true,
      data: {
        uid: user._id,
        name: user.name,
        email: user.email,
        token: generateToken(user._id),
      },
    });

  } catch (error) {
    console.error("REGISTER ERROR:", error);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// ─────────────────────────────
// LOGIN USER
// ─────────────────────────────
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    //  VALIDATION
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: "Email and password required",
      });
    }

    //  FIND USER
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({
        success: false,
        error: "Invalid email or password",
      });
    }

    //  CHECK PASSWORD
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        error: "Invalid email or password",
      });
    }

    // SUCCESS RESPONSE
    return res.status(200).json({
      success: true,
      data: {
        uid: user._id,
        name: user.name,
        email: user.email,
        token: generateToken(user._id),
      },
    });

  } catch (error) {
    console.error("LOGIN ERROR:", error);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

module.exports = { registerUser, loginUser };
