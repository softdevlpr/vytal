import express from "express";
import { predictTests } from "../controllers/mlController.js";

const router = express.Router();

router.post("/predict-tests", predictTests);
export default router;
