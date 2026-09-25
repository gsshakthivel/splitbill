import { getIO } from "./socket.manager.js";
import logger from "../utils/logger.js";

const sendNotification = (userId, notification) => {
    
    const io = getIO();

    logger.info("Sending notification to:", `user:${userId}`);

    io.to(`user:${userId}`).emit("notification", notification);
};

export default sendNotification;