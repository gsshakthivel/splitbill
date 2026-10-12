import pool from "../config/db.js";

const findUserByEmail = async (email) => {
    try {
        const query = `SELECT * FROM users WHERE email = ?`;
        const [rows] = await pool.execute(query, [email]);
        
        if (rows.length > 0) {
            return rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

const createUser = async (name, email, passwordHash) => {
    try {
        const query = `INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)`;
        const [result] = await pool.execute(query, [name, email, passwordHash]);
        return {id: result.insertId, name: name, email: email};
    } catch (error) {
        throw error;
    }
}

const findUserById = async (userId) => {
    
        const query = `SELECT id, name, email FROM users WHERE id = ?`;
        const [rows] = await pool.execute(query, [userId]);
        
        if (rows.length > 0) {
            return rows[0];
        }
        return null;
}

const searchUsers = async (query, currentUserId) => {
    const sql = `
        SELECT id, name, email
        FROM users
        WHERE id <> ?
          AND (name LIKE ? OR email LIKE ?)
        ORDER BY name ASC
        LIMIT 20
    `;

    const searchTerm = `%${query}%`;

    const [rows] = await pool.execute(sql, [
        currentUserId,
        searchTerm,
        searchTerm
    ]);

    return rows;
};


export { findUserByEmail, createUser, findUserById, searchUsers };