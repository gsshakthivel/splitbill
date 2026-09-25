import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/repositories/notifications.repository.js", () => ({
    getUserNotifications: jest.fn(),
    markNotificationAsRead: jest.fn(),
    getUnreadNotificationCount: jest.fn()
}));

const {
    getUserNotificationsService,
    markNotificationAsReadService,
    getUnreadNotificationCountService
} = await import("../src/services/notifications.service.js");

const notificationRepository =
    await import("../src/repositories/notifications.repository.js");

beforeEach(() => {
    jest.clearAllMocks();
});

test("getUserNotificationsService should return user notifications", async () => {
    notificationRepository.getUserNotifications.mockResolvedValue([
        {
            id: 1,
            type: "expense_created",
            message: "Dinner expense was added"
        },
        {
            id: 2,
            type: "settlement_created",
            message: "Settlement received"
        }
    ]);

    const result = await getUserNotificationsService(10);

    expect(result).toEqual([
        {
            id: 1,
            type: "expense_created",
            message: "Dinner expense was added"
        },
        {
            id: 2,
            type: "settlement_created",
            message: "Settlement received"
        }
    ]);

    expect(notificationRepository.getUserNotifications)
        .toHaveBeenCalledWith(10);
});

test("markNotificationAsReadService should mark notification as read", async () => {
    notificationRepository.markNotificationAsRead
        .mockResolvedValue({
            affectedRows: 1
        });

    const result = await markNotificationAsReadService(100, 10);

    expect(result).toBe(true);

    expect(notificationRepository.markNotificationAsRead)
        .toHaveBeenCalledWith(100, 10);
});

test("markNotificationAsReadService should reject a missing notification", async () => {
    notificationRepository.markNotificationAsRead
        .mockResolvedValue({
            affectedRows: 0
        });

    await expect(
        markNotificationAsReadService(999, 10)
    ).rejects.toThrow("Notification not found");
});

test("getUnreadNotificationCountService should return unread count", async () => {
    notificationRepository.getUnreadNotificationCount
        .mockResolvedValue(5);

    const result = await getUnreadNotificationCountService(10);

    expect(result).toBe(5);

    expect(notificationRepository.getUnreadNotificationCount)
        .toHaveBeenCalledWith(10);
});