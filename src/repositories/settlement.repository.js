import pool from "../config/db.js";

const getPairwiseBalance = async (groupId, fromUserId, toUserId) => {
    const query = `
        SELECT  
            pair_balance.*,
            expense_from_to
            - expense_to_from
            - settled_from_to
            + settled_to_from AS net_debt
        FROM ( 
            SELECT  
                (
                    SELECT COALESCE(SUM(es.amount), 0)
                    FROM expenses AS e
                    JOIN expense_splits AS es
                        ON e.id = es.expense_id
                    WHERE e.group_id = ?
                      AND e.paid_by = ?
                      AND es.user_id = ?
                ) AS expense_from_to,

                (
                    SELECT COALESCE(SUM(es.amount), 0)
                    FROM expenses AS e
                    JOIN expense_splits AS es
                        ON e.id = es.expense_id
                    WHERE e.group_id = ?
                      AND e.paid_by = ?
                      AND es.user_id = ?
                ) AS expense_to_from,

                (
                    SELECT COALESCE(SUM(s.amount), 0)
                    FROM settlements AS s
                    WHERE s.group_id = ?
                      AND s.from_user_id = ?
                      AND s.to_user_id = ?
                ) AS settled_from_to,

                (
                    SELECT COALESCE(SUM(s.amount), 0)
                    FROM settlements AS s
                    WHERE s.group_id = ?
                      AND s.from_user_id = ?
                      AND s.to_user_id = ?
                ) AS settled_to_from
        ) AS pair_balance;
    `;

    const [result] = await pool.execute(query, [
        groupId,
        toUserId,
        fromUserId,

        groupId,
        fromUserId,
        toUserId,

        groupId,
        fromUserId,
        toUserId,

        groupId,
        toUserId,
        fromUserId
    ]);

    return result;
};

const createSettlement = async (groupId, toUserId, amount, fromUserId) => {
    const query = `
        INSERT INTO settlements (group_id, from_user_id, to_user_id, amount)
        VALUES (?, ?, ?, ?);
    `;
    const [result] = await pool.execute(query, [groupId, fromUserId, toUserId, amount]);
    return {
        id: result.insertId,
        groupId,
        fromUserId: fromUserId,
        toUserId,
        amount
    };  
};  

const getUserSettlements = async (groupId) => {
    const query = `
        SELECT id, from_user_id, to_user_id, amount, created_at FROM settlements 
        WHERE group_id = ? ORDER BY created_at DESC;
    `;
    const [result] = await pool.execute(query, [groupId]);
    return result;
};

export { getPairwiseBalance, createSettlement, getUserSettlements };