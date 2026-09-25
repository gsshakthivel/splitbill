import mysql from "mysql2/promise";
import fs from "fs";

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,

    ssl: process.env.DB_SSL === "true"
        ? {
            ca: fs.readFileSync(process.env.DB_SSL_CA)
        }
        : undefined
});

export default pool;