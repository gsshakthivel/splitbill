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

export { createGroup, addUserToGroup, getGroupsByUserId, getGroupMember, addGroupMember, getGroupDetailsByGroupId };