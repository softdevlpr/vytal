const { getDB }  = require("../config/db");
const { ObjectId } = require("mongodb");

const clean = (doc) => { doc._id = doc._id.toString(); return doc; };

// GET /reminders?uid=xxx
const getReminders = async (req, res) => {
  try {
    const db  = getDB();
    const { uid } = req.query;

    const reminders = await db
      .collection("reminders")
      .find({ uid })
      .toArray();

    res.json({ success: true, data: reminders.map(clean) });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// POST /reminders
const addReminder = async (req, res) => {
  try {
    const db   = getDB();
    const body = req.body || {};
    body.created_at = new Date().toISOString();

    const result = await db.collection("reminders").insertOne(body);

    // Return the saved doc with its new _id
    body._id = result.insertedId.toString();
    res.json({ success: true, data: body });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// DELETE /reminders/:rid
const deleteReminder = async (req, res) => {
  try {
    const db = getDB();
    await db
      .collection("reminders")
      .deleteOne({ _id: new ObjectId(req.params.rid) });

    res.json({ success: true, data: { message: "Deleted" } });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

// PATCH /reminders/:rid  — toggle is_active
const toggleReminder = async (req, res) => {
  try {
    const db       = getDB();
    const is_active = req.body?.is_active ?? true;

    await db
      .collection("reminders")
      .updateOne(
        { _id: new ObjectId(req.params.rid) },
        { $set: { is_active } }
      );

    res.json({ success: true, data: { message: "Updated" } });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
};

module.exports = { getReminders, addReminder, deleteReminder, toggleReminder };
