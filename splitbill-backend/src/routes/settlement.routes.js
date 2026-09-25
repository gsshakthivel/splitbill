import { Router } from "express";
import authenticate from "../middleware/auth.middleware.js";
import { createSettlement, getUserSettlements } from "../controllers/settlement.controller.js";

const router = Router({ mergeParams: true });

router.post("/", authenticate, createSettlement);

router.get("/", authenticate, getUserSettlements);

export default router;