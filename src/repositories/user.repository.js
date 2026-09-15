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
    try {
        const query = `SELECT * FROM users WHERE id = ?`;
        const [rows] = await pool.execute(query, [userId]);
        
        if (rows.length > 0) {
            return rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}


export { findUserByEmail, createUser, findUserById };    