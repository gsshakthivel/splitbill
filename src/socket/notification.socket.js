import { getIO } from "./socket.manager.js";

const sendNotification = (userId, notification) => {
    
    const io = getIO();

    console.log("Sending notification to:", `user:${userId}`);

    io.to(`user:${userId}`).emit("notification", notification);
};

export default sendNotification;