import { createServer } from "http";
import { Server } from "socket.io";
import { io as Client } from "socket.io-client";
import initializeSocket from "../src/socket/socket.js";
import { generateToken } from "../src/utils/jwt.js";
import sendNotification from "../src/socket/notification.socket.js";
import { initializeSocketManager } from "../src/socket/socket.manager.js";

describe("Socket.IO", () => {
    let httpServer;
    let io;
    let client;

    beforeEach((done) => {
        httpServer = createServer();

        io = new Server(httpServer);

        initializeSocketManager(io);
        initializeSocket(io);

        httpServer.listen(() => {
            done();
        });
    });

    afterEach(() => {
        if (client) {
            client.disconnect();
        }

        io.close();
        httpServer.close();
    });

    test("should authenticate a client with a valid token and connect", (done) => {
        const token = generateToken(1);

        client = Client(`http://localhost:${httpServer.address().port}`, {
            auth: {
                token
            }
        });

        client.on("connect", () => {
            expect(client.connected).toBe(true);
            done();
        });
    });

    test("should reject a client without a token", (done) => {
        client = Client(`http://localhost:${httpServer.address().port}`, {
            auth: {}
        });

        client.on("connect_error", (error) => {
            expect(error.message).toBe("Authentication required");
            done();
        });
    });

    test("should reject a client with an invalid token", (done) => {
        client = Client(`http://localhost:${httpServer.address().port}`, {
            auth: {
                token: "invalid-token"
            }
        });

        client.on("connect_error", (error) => {
            expect(error.message).toBe("Invalid token");
            done();
        });
    });

    test("should receive notification sent to the user's room", (done) => {
    const token = generateToken(1);

    client = Client(`http://localhost:${httpServer.address().port}`, {
        auth: {
            token
        }
    });

    client.on("connect", () => {
        const notification = {
            id: 10,
            userId: 2,
            groupId: 5,
            type: "expense_created",
            message: "Dinner expense was added"
        };

        sendNotification(1, notification);
    });

    client.on("notification", (data) => {
        expect(data).toEqual({
            id: 10,
            userId: 2,
            groupId: 5,
            type: "expense_created",
            message: "Dinner expense was added"
        });

        done();
    });
    });
});