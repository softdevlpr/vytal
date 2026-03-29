const { getDB } = require("../config/db");

const clean = (doc) => { doc._id = doc._id.toString(); return doc; };

// GET /users/:uid
const getUser = async (req, res) => {
  try {
    const db  = getDB();
    const user = await db.collection("users").findOne({ uid: req.params.uid });

    if (!user) {
      return res.status(404).json({ success: false, error: "User not found" });
    }
    res.json({ success: true, data: clean(user) });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// POST /users  — upsert (create if not exists)
const createUser = async (req, res) => {
  try {
    const db   = getDB();
    const body = req.body || {};
    const now  = new Date().toISOString();

    const doc = {
      ...body,
      created_at:            now,
      updated_at:            now,
      symptom_scores:        body.symptom_scores        || {},
      preferred_categories:  body.preferred_categories  || [],
    };

    // $setOnInsert → only writes if document is newly created
    await db.collection("users").updateOne(
      { uid: doc.uid },
      { $setOnInsert: doc },
      { upsert: true }
    );

    res.json({ success: true, data: { message: "User created" } });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// PUT /users/:uid
const updateUser = async (req, res) => {
  try {
    const db   = getDB();
    const body = req.body || {};

    // Never overwrite _id from client payload
    delete body._id;
    body.updated_at = new Date().toISOString();

    await db
      .collection("users")
      .updateOne({ uid: req.params.uid }, { $set: body });

    res.json({ success: true, data: { message: "Updated" } });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// DELETE /users/:uid  — cascades to logs & reminders
const deleteUser = async (req, res) => {
  try {
    const db  = getDB();
    const uid = req.params.uid;

    await db.collection("users").deleteOne({ uid });
    await db.collection("symptom_logs").deleteMany({ uid });
    await db.collection("reminders").deleteMany({ uid });

    res.json({ success: true, data: { message: "Account deleted" } });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getUser, createUser, updateUser, deleteUser };
