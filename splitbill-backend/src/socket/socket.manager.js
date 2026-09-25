let io;

const initializeSocketManager = (socketIO) => {
    io = socketIO;
};

const getIO = () => {
    if (!io) {
        throw new Error("Socket.IO has not been initialized");
    }

    return io;
};

export {
    initializeSocketManager,
    getIO
};