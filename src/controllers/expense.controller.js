import { createExpenseService, getExpensesService, getExpenseByIdService, updateExpenseService } from "../services/expense.service.js";
import AppError from "../utils/errors.js";

const createExpense = async (req, res) => {
    const { groupId } = req.params; 
    const { paidBy, amount, description, splitType, splits } = req.body;
    const { id } = req.user;
    const result = await createExpenseService(groupId, paidBy, amount, description, splitType, id, splits);
    res.status(201).json({message: "Expense created successfully", expense: result});
}

const getExpenses = async (req, res) => {
    const { groupId } = req.params;
    const { id } = req.user;
    const result = await getExpensesService(groupId, id);
    res.status(200).json({message: "Expenses fetched successfully", expenses: result});
}   

const getExpenseById = async (req, res) => {
    const { groupId, expenseId } = req.params;
    const { id } = req.user;
    const result = await getExpenseByIdService(groupId, expenseId, id);
    res.status(200).json({message: "Expense fetched successfully", expense: result});
}

const updateExpense = async (req, res) => {
    const { groupId, expenseId } = req.params;
    const { description, amount, paidBy, splitType, splits } = req.body;
    const { id } = req.user;

    const groupIdNumber = Number(groupId);
    const expenseIdNumber = Number(expenseId);

    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    if (!Number.isInteger(expenseIdNumber) || expenseIdNumber <= 0) {
        throw new AppError("Invalid expenseId", 400);
    }
    const result = await updateExpenseService(groupIdNumber, expenseIdNumber, id, description, amount, paidBy, splitType, splits);
    res.status(200).json({message: "Expense updated successfully", expense: result});
}   

export { createExpense, getExpenses, getExpenseById, updateExpense };