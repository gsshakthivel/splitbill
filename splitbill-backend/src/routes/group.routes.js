import { Router } from "express";
import { createGroup, getGroups, addGroupMember, getGroupDetails, removeGroupMember, getGroupBalances } from "../controllers/group.controller.js";
import authenticate from "../middleware/auth.middleware.js";
import expenseRoutes from "./expense.routes.js";
import settlementRoutes from "./settlement.routes.js";

const router = Router();

router.post("/", authenticate, createGroup);

router.get("/", authenticate, getGroups);

router.post("/:groupId/members", authenticate, addGroupMember);

router.get("/:groupId", authenticate, getGroupDetails);

router.delete("/:groupId/members/:userId", authenticate, removeGroupMember);

router.use("/:groupId/expenses", expenseRoutes);

router.get("/:groupId/balances", authenticate, getGroupBalances);

router.use("/:groupId/settlements", settlementRoutes);

export default router;