import { Router } from "express";
import { getUserNotifications, markNotificationAsRead, getUnreadNotificationCount } from "../controllers/notifications.controller.js";
import authenticate from "../middleware/auth.middleware.js";

const router = Router();

router.get("/", authenticate, getUserNotifications);

router.get("/unread-count", authenticate, getUnreadNotificationCount);

router.patch("/:notificationId/read", authenticate, markNotificationAsRead);

export default router;