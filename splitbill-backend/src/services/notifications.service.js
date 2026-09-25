import { getUserNotifications, markNotificationAsRead as markNotificationAsReadRepository, getUnreadNotificationCount as getUnreadNotificationCountRepository } from "../repositories/notifications.repository.js";
import AppError from "../utils/errors.js";

const getUserNotificationsService = async (userId) => {

    if (!Number.isInteger(userId) || userId <= 0) {
        throw new AppError("Invalid userId", 400);
    }

    const notifications = await getUserNotifications(userId);
    return notifications;
};

const markNotificationAsReadService = async (notificationId, userId) => {

    if (!Number.isInteger(notificationId) || notificationId <= 0) {
        throw new AppError("Invalid notificationId", 400);
    }

    if (!Number.isInteger(userId) || userId <= 0) {
        throw new AppError("Invalid userId", 400);
    }

    const result = await markNotificationAsReadRepository(notificationId, userId);
    if (result.affectedRows === 0) {
        throw new AppError("Notification not found", 404);
    }

    return true;
};

const getUnreadNotificationCountService = async (userId) => {
    
    if (!Number.isInteger(userId) || userId <= 0) {
        throw new AppError("Invalid userId", 400);
    }

    const unreadCount = await getUnreadNotificationCountRepository(userId);
    return unreadCount;
};

export { getUserNotificationsService, markNotificationAsReadService, getUnreadNotificationCountService };