import { verifyToken } from "../utils/jwt.js";
import logger from "../utils/logger.js";

const initializeSocket = (io) => {

    io.use((socket, next) => {
        try {
            const token = socket.handshake.auth.token;

            if (!token) {
                return next(new Error("Authentication required"));
            }

            const decoded = verifyToken(token);

            socket.userId = decoded.id;

            next();
        } catch (error) {
            next(new Error("Invalid token"));
        }
    });

    io.on("connection", (socket) => {
        logger.info("Client connected:", socket.id);
        logger.info("User ID:", socket.userId);

        socket.join(`user:${socket.userId}`);

        logger.info(`User joined room: user:${socket.userId}`);

        socket.on("disconnect", () => {
            logger.info("Client disconnected:", socket.id);
        });
    });
};

export default initializeSocket;