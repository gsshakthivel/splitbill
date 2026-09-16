import pool from "../config/db.js";

const createExpense = async (connection, groupId, paidBy, amount, description, splitType, createdBy) => {
    const query = `INSERT INTO expenses (group_id, paid_by, amount, description, split_type, created_by) VALUES (?, ?, ?, ?, ?, ?)`;
    const [result] = await connection.execute(query, [groupId, paidBy, amount, description, splitType, createdBy]);
    return { id: result.insertId, group_id: groupId, paid_by: paidBy, amount: amount, description: description, split_type: splitType, created_by: createdBy };
}

const createExpenseSplit = async (connection, expenseId, userId, amount) => {
    const query = `INSERT INTO expense_splits (expense_id, user_id, amount) VALUES (?, ?, ?)`;
    await connection.execute(query, [expenseId, userId, amount]);
    return { expenseId: expenseId, userId: userId, amount: amount };
}  

const getExpensesByGroupId = async (groupId, userId) => {
    const query = `SELECT e.id, e.description, e.group_id, e.amount, e.paid_by, e.created_by, e.split_type, e.created_at, es.amount AS my_share
                    FROM expenses AS e
                    LEFT JOIN expense_splits AS es ON e.id = es.expense_id AND es.user_id = ?
                    WHERE e.group_id = ? ORDER BY e.created_at DESC`;
    const [result] = await pool.execute(query, [userId, groupId]);
    return result;
}   

const getExpenseById = async (groupId, expenseId) => {
    const query = `SELECT e.id AS expense_id, e.description, e.group_id, e.amount, e.paid_by, e.created_by, e.split_type, e.created_at, es.user_id, es.amount AS split_amount 
                    FROM expenses As e 
                    JOIN expense_splits as es on e.id = es.expense_id 
                    where e.id = ? and e.group_id = ?`;
    const [result] = await pool.execute(query, [expenseId, groupId]);
    return result;  
}

const getExpenseForUpdate = async (connection, groupId, expenseId) => {
    const query = `SELECT id AS expense_id, description, group_id, amount, paid_by, created_by, split_type
                    FROM expenses
                    where id = ? and group_id = ?`;
    const [result] = await connection.execute(query, [expenseId, groupId]);
    return result;  
}

const updateExpense = async (connection, groupId, expenseId, paidBy, amount, description, splitType, updatedBy) => {
    const query = `UPDATE expenses SET paid_by = ?, amount = ?, description = ?, split_type = ?, updated_by = ? WHERE id = ? AND group_id = ?`;
    await connection.execute(query, [paidBy, amount, description, splitType, updatedBy, expenseId, groupId]);
    return { id: expenseId, group_id: groupId, paid_by: paidBy, amount: amount, description: description, split_type: splitType, updated_by: updatedBy };
}

const deleteExpense = async (connection, expenseId) => {
    const query = `DELETE FROM expenses WHERE id = ?`;
    const [result] = await connection.execute(query, [expenseId]);

    return result.affectedRows;
};

const deleteExpenseSplits = async (connection, expenseId) => {
    const query = `DELETE FROM expense_splits WHERE expense_id = ?`;
    await connection.execute(query, [expenseId]);
};

export { createExpense, createExpenseSplit, getExpensesByGroupId, getExpenseById, getExpenseForUpdate, updateExpense, deleteExpense, deleteExpenseSplits  };