import { getUserNotifications, markNotificationAsRead as markNotificationAsReadRepository, getUnreadNotificationCount as getUnreadNotificationCountRepository } from "../repositories/notifications.repository.js";
import AppError from "../utils/errors.js";

const getUserNotificationsService = async (userId) => {

    const notifications = await getUserNotifications(userId);
    return notifications;
};

const markNotificationAsReadService = async (notificationId, userId) => {

    const result = await markNotificationAsReadRepository(notificationId, userId);
    if (result.affectedRows === 0) {
        throw new AppError("Notification not found", 404);
    }

    return true;
};

const getUnreadNotificationCountService = async (userId) => {
    const unreadCount = await getUnreadNotificationCountRepository(userId);
    return unreadCount;
};

export { getUserNotificationsService, markNotificationAsReadService, getUnreadNotificationCountService };