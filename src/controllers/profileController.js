const User = require("../models/User");

const updateProfile = async (req, res) => {
  const { date_of_birth, gender, height, weight } = req.body;

  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (date_of_birth) user.date_of_birth = date_of_birth;
    if (gender) user.gender = gender;

    if (height !== undefined) user.height = height;
    if (weight !== undefined) user.weight = weight;

    user.updated_at = new Date();

    await user.save();

    res.json({
      message: "Profile updated successfully",
      user,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { updateProfile };
