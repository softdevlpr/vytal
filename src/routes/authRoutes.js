const express = require("express");
const router  = express.Router();
const {
  getUser,
  createUser,
  updateUser,
  deleteUser,
} = require("../controllers/userController");

router.get("/:uid",    getUser);
router.post("/",       createUser);
router.put("/:uid",    updateUser);
router.delete("/:uid", deleteUser);

module.exports = router;
