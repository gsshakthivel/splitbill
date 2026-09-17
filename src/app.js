import express from "express";
import authRoutes from "./routes/auth.routes.js";
import groupRoutes from "./routes/group.routes.js";
import notificationRoutes from "./routes/notifications.routes.js";
import errorHandler from "./middleware/error.middleware.js";

const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
    res.status(200).json({
        status: "ok",
        message: "SplitBill API is running"
    });
});

app.use("/api/v1/auth", authRoutes);

app.use("/api/v1/groups", groupRoutes);

app.use("/api/v1/notifications", notificationRoutes);

app.use(errorHandler);

export default app;