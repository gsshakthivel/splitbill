import { getUserNotificationsService, markNotificationAsReadService, getUnreadNotificationCountService } from "../services/notifications.service.js";
import AppError from "../utils/errors.js";

const getUserNotifications = async (req, res) => {
    const userId = req.user.id;
    const notifications = await getUserNotificationsService(userId);
    return res.status(200).json({ message: "Notifications fetched successfully", data: notifications });
};

const markNotificationAsRead = async (req, res) => {
    const notificationId = req.params.notificationId;
    const userId = req.user.id;

    const notificationIdNumber = Number(notificationId);
    
    if (!Number.isInteger(notificationIdNumber) || notificationIdNumber <= 0) {
        throw new AppError("Invalid notificationId", 400);
    }

    const result = await markNotificationAsReadService(notificationIdNumber, userId);
    return res.status(200).json({ 
        message: "Notification marked as read successfully", 
        data: result 
    });
}

const getUnreadNotificationCount = async (req, res) => {
    const userId = req.user.id;
    const unreadCount = await getUnreadNotificationCountService(userId);
    return res.status(200).json({ message: "Unread count fetched successfully", data: unreadCount });
};

export { getUserNotifications, markNotificationAsRead, getUnreadNotificationCount };