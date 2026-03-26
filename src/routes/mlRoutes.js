import express from "express";
import { predictTests } from "../controllers/mlController.js";

const router = express.Router();

router.post("/predict-tests", predictTests);

module.exports = router;
