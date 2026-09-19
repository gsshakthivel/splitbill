import "dotenv/config";
import http from "http";
import app from "./app.js";
import { Server } from "socket.io";
import initializeSocket from "./socket/socket.js";
import { initializeSocketManager } from "./socket/socket.manager.js";

if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured");
}

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

const io = new Server(server);

initializeSocketManager(io);

initializeSocket(io);

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});