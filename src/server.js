import "dotenv/config";
import http from "http";
import app from "./app.js";
import { Server } from "socket.io";
import initializeSocket from "./socket/socket.js";
import { initializeSocketManager } from "./socket/socket.manager.js";
import pool from "./config/db.js";
import logger from "./utils/logger.js";

if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured");
}

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

const io = new Server(server);

initializeSocketManager(io);

initializeSocket(io);

server.listen(PORT, () => {
    logger.info(`Server running on port ${PORT}`);
});

const shutdown = async (signal) => {
    logger.info(`${signal} received. Shutting down gracefully...`);

    server.close(async () => {
        logger.info("HTTP server closed");

        await io.close();
        logger.info("Socket.IO closed");

        await pool.end();
        logger.info("MySQL pool closed");

        process.exit(0);
    });
};

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));