import pool from "../config/db.js";

const createNotification = async (connection, groupId, createdBy, type, message) => {
    const query = `INSERT INTO notifications (group_id, created_by, type, message) VALUES (?, ?, ?, ?);`;
    const [result] = await connection.execute(query, [groupId, createdBy, type, message]);
    return {
        id: result.insertId,
        groupId,
        createdBy,
        type,
        message
    };
}

const createNotificationRecipient = async (connection, notificationId, recipientUserId) => {
    const query = `INSERT INTO notification_recipients (notification_id, recipient_user_id) VALUES (?, ?);`;
    const [result] = await connection.execute(query, [notificationId, recipientUserId]);
    return {
        id: result.insertId,
        notificationId,
        recipientUserId
    };
}

const getUserNotifications = async (userId) => {
    const query = `SELECT n.id, n.group_id, n.created_by, n.type, n.message, n.created_at, nr.read_at 
        FROM notifications AS n
        JOIN notification_recipients AS nr
            ON n.id = nr.notification_id
        WHERE nr.recipient_user_id = ?
        ORDER BY n.created_at DESC`;

    const [result] = await pool.execute(query, [userId]);

    return result;
};

const markNotificationAsRead = async (notificationId, userId) => {
    const query = `UPDATE notification_recipients SET read_at = COALESCE(read_at, CURRENT_TIMESTAMP) WHERE notification_id = ? AND recipient_user_id = ?;`;
    const [result] = await pool.execute(query, [notificationId, userId]);
    return result;
};

const getUnreadNotificationCount = async (userId) => {
    const query = `SELECT COUNT(*) AS unread_count 
        FROM notification_recipients
        WHERE recipient_user_id = ? AND read_at IS NULL;`;
    const [result] = await pool.execute(query, [userId]);
    return result[0].unread_count;
};

export { createNotification, createNotificationRecipient, getUserNotifications, markNotificationAsRead, getUnreadNotificationCount };