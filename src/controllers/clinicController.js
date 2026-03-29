const { getDB } = require("../config/db");

const clean = (doc) => { doc._id = doc._id.toString(); return doc; };

// GET /clinics  — optionally filter by tests_available
const getClinics = async (req, res) => {
  try {
    const db = getDB();
    const { tests = "" } = req.query;

    // Split comma-separated test names and strip whitespace
    const testList = tests
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);

    const query = {};
    if (testList.length) {
      query.tests_available = { $in: testList };
    }

    const clinics = await db
      .collection("clinics_jaipur")
      .find(query)
      .toArray();

    res.json({ success: true, data: clinics.map(clean) });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getClinics };
