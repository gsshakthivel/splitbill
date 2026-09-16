import { Router } from "express";
import { createExpense, getExpenses, getExpenseById, updateExpense } from "../controllers/expense.controller.js";
import authenticate from "../middleware/auth.middleware.js";

const router = Router({ mergeParams: true });

router.post("/", authenticate, createExpense);

router.get("/", authenticate, getExpenses);

router.get("/:expenseId", authenticate, getExpenseById);

router.patch("/:expenseId", authenticate, updateExpense);

export default router;