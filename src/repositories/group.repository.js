import pool from "../config/db.js";

const createGroup = async (connection, name, createdBy) => {
    const query = `INSERT INTO \`groups\` (name, created_by) VALUES (?, ?)`;
    const [result] = await connection.execute(query, [name, createdBy]);
    return { id: result.insertId, name: name, createdBy: createdBy };
}

const addUserToGroup = async (connection, groupId, userId, role, createdBy) => {
    const query = `INSERT INTO group_members (group_id, user_id, role, created_by) VALUES (?, ?, ?, ?)`;
    await connection.execute(query, [groupId, userId, role, createdBy]);
    return { groupId: groupId, userId: userId, createdBy: createdBy };
}

const getGroupsByUserId = async (userId) => {
    const query = `SELECT g.id, g.name, g.created_by FROM \`groups\` AS g JOIN group_members AS gm ON g.id = gm.group_id WHERE gm.user_id = ?`;
    const [result] = await pool.execute(query, [userId]);
    return result;
}

const getGroupMember = async (groupId, userId) => {
    const query = `SELECT gm.group_id, gm.user_id, gm.role FROM group_members AS gm WHERE gm.group_id = ? AND gm.user_id = ?`;
    const [result] = await pool.execute(query, [groupId, userId]);
    return result;
}

const getGroupMemberTransaction = async (connection, groupId, userId) => {
    const query = `SELECT gm.group_id, gm.user_id, gm.role FROM group_members AS gm WHERE gm.group_id = ? AND gm.user_id = ?`;
    const [result] = await connection.execute(query, [groupId, userId]);
    return result;
}

const getGroupMembers = async (connection, groupId) => {
    const query = `SELECT gm.group_id, gm.user_id, gm.role FROM group_members AS gm WHERE gm.group_id = ?`;
    const [result] = await connection.execute(query, [groupId]);
    return result;
}

const addGroupMember = async (groupId, userId, role, createdBy) => {
    const query = `INSERT INTO group_members (group_id, user_id, role, created_by) VALUES (?, ?, ?, ?)`;
    await pool.execute(query, [groupId, userId, role, createdBy]);
    return { groupId: groupId, userId: userId, createdBy: createdBy };
}

const getGroupDetailsByGroupId = async (groupId) => {
    const query = `SELECT g.id, g.name, g.created_by, u.id AS user_id, u.name AS username, gm.role FROM \`groups\` AS g JOIN group_members AS gm ON g.id = gm.group_id JOIN users AS u ON gm.user_id = u.id WHERE gm.group_id = ? `;
    const [result] = await pool.execute(query, [groupId]);
    return result;
}

const hasUserExpensesInGroup = async (groupId, userId) => {
    const query = `
        SELECT EXISTS (
            SELECT 1 FROM expenses WHERE group_id = ? AND paid_by = ?
            UNION ALL
            SELECT 1 FROM expense_splits AS es JOIN expenses AS e ON es.expense_id = e.id WHERE e.group_id = ? AND es.user_id = ?
        ) AS has_expenses
    `;
    const [result] = await pool.execute(query, [groupId, userId, groupId, userId]);
    return Boolean(Number(result[0]?.has_expenses));
}

const removeGroupMember = async (groupId, userId) => {
    const query = `DELETE FROM group_members WHERE group_id = ? AND user_id = ?`;
    const [result] = await pool.execute(query, [groupId, userId]);
    return result;
}

const getGroupBalances = async (groupId) => {
    const query = `
        SELECT
            gm.user_id,
            gm.role,
            COALESCE(paid_summary.total_paid, 0) AS total_paid,
            COALESCE(owed_summary.total_owed, 0) AS total_owed,
            COALESCE(paid_summary.total_paid, 0)
                - COALESCE(owed_summary.total_owed, 0) AS balance
        FROM group_members AS gm

        LEFT JOIN (
            SELECT
                e.paid_by AS user_id,
                e.group_id,
                SUM(e.amount) AS total_paid
            FROM expenses AS e
            WHERE e.group_id = ?
            GROUP BY e.paid_by, e.group_id
        ) AS paid_summary
            ON gm.user_id = paid_summary.user_id
            AND gm.group_id = paid_summary.group_id

        LEFT JOIN (
            SELECT
                es.user_id,
                e.group_id,
                SUM(es.amount) AS total_owed
            FROM expense_splits AS es
            JOIN expenses AS e
                ON es.expense_id = e.id
            WHERE e.group_id = ?
            GROUP BY es.user_id, e.group_id
        ) AS owed_summary
            ON gm.user_id = owed_summary.user_id
            AND gm.group_id = owed_summary.group_id

        WHERE gm.group_id = ?
    `;

    const [result] = await pool.execute(query, [
        groupId,
        groupId,
        groupId
    ]);

    return result;
};

export { createGroup, addUserToGroup, getGroupsByUserId, getGroupMember, getGroupMemberTransaction, getGroupMembers, addGroupMember, getGroupDetailsByGroupId, hasUserExpensesInGroup, removeGroupMember, getGroupBalances };