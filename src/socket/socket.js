import { verifyToken } from "../utils/jwt.js";

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
        console.log("Client connected:", socket.id);
        console.log("User ID:", socket.userId);

        socket.join(`user:${socket.userId}`);

        console.log(`User joined room: user:${socket.userId}`);

        socket.on("disconnect", () => {
            console.log("Client disconnected:", socket.id);
        });
    });
};

export default initializeSocket;