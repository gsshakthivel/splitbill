import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/config/db.js", () => ({
    default: {
        getConnection: jest.fn()
    }
}));

jest.unstable_mockModule("../src/repositories/settlement.repository.js", () => ({
    getPairwiseBalance: jest.fn(),
    createSettlement: jest.fn(),
    getUserSettlements: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/group.repository.js", () => ({
    getGroupMember: jest.fn(),
    getGroupMemberTransaction: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/notifications.repository.js", () => ({
    createNotification: jest.fn(),
    createNotificationRecipient: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/user.repository.js", () => ({
    findUserById: jest.fn()
}));

jest.unstable_mockModule("../src/socket/notification.socket.js", () => ({
    default: jest.fn()
}));

const {
    createSettlementService,
    getUserSettlementsService
} = await import("../src/services/settlement.service.js");

const pool = (await import("../src/config/db.js")).default;

const settlementRepository =
    await import("../src/repositories/settlement.repository.js");

const groupRepository =
    await import("../src/repositories/group.repository.js");

const notificationRepository =
    await import("../src/repositories/notifications.repository.js");

const { findUserById } =
    await import("../src/repositories/user.repository.js");

const { default: sendNotification } =
    await import("../src/socket/notification.socket.js");

beforeEach(() => {
    jest.clearAllMocks();
});

test("createSettlementService should create a settlement", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    settlementRepository.getPairwiseBalance
        .mockResolvedValue([{ net_debt: 500 }]);

    findUserById.mockResolvedValue({
        id: 1,
        name: "Shakthivel"
    });

    settlementRepository.createSettlement
        .mockResolvedValue({
            id: 100,
            group_id: 1,
            from_user_id: 1,
            to_user_id: 2,
            amount: 200
        });

    notificationRepository.createNotification
        .mockResolvedValue({ id: 500 });

    notificationRepository.createNotificationRecipient
        .mockResolvedValue({});

    const result = await createSettlementService(
        1,
        2,
        200,
        1
    );

    expect(result).toEqual({
        id: 100,
        group_id: 1,
        from_user_id: 1,
        to_user_id: 2,
        amount: 200
    });

    expect(settlementRepository.createSettlement)
        .toHaveBeenCalledWith(
            connection,
            1,
            2,
            200,
            1
        );

    expect(connection.commit).toHaveBeenCalled();

    expect(sendNotification).toHaveBeenCalledWith(
        2,
        expect.objectContaining({
            groupId: 1,
            settlementId: 100,
            type: "settlement_created"
        })
    );
});

test("createSettlementService should reject self settlement", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    await expect(
        createSettlementService(1, 1, 100, 1)
    ).rejects.toThrow(
        "You cannot settle with yourself"
    );

    expect(settlementRepository.createSettlement)
        .not.toHaveBeenCalled();
});

test("createSettlementService should reject when there is no debt", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    settlementRepository.getPairwiseBalance
        .mockResolvedValue([]);

    await expect(
        createSettlementService(1, 2, 100, 1)
    ).rejects.toThrow(
        "You don't have any debt to settle with this user"
    );

    expect(settlementRepository.createSettlement)
        .not.toHaveBeenCalled();
});

test("createSettlementService should reject when there is no positive debt", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    settlementRepository.getPairwiseBalance
        .mockResolvedValue([{ net_debt: -200 }]);

    await expect(
        createSettlementService(1, 2, 100, 1)
    ).rejects.toThrow(
        "You don't have any debt to settle with this user"
    );

    expect(settlementRepository.createSettlement)
        .not.toHaveBeenCalled();
});

test("createSettlementService should reject an amount greater than the debt", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    settlementRepository.getPairwiseBalance
        .mockResolvedValue([{ net_debt: 500 }]);

    await expect(
        createSettlementService(1, 2, 600, 1)
    ).rejects.toThrow(
        "You cannot settle more than what you owe"
    );

    expect(settlementRepository.createSettlement)
        .not.toHaveBeenCalled();
});

test("createSettlementService should reject an invalid amount", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    await expect(
        createSettlementService(1, 2, -100, 1)
    ).rejects.toThrow("Invalid amount");

    expect(settlementRepository.getPairwiseBalance)
        .not.toHaveBeenCalled();
});

test("getUserSettlementsService should return settlement history", async () => {
    groupRepository.getGroupMember.mockResolvedValue([
        { user_id: 1 }
    ]);

    settlementRepository.getUserSettlements
        .mockResolvedValue([
            {
                id: 100,
                from_user_id: 1,
                to_user_id: 2,
                amount: 200
            }
        ]);

    const result = await getUserSettlementsService(1, 1);

    expect(result).toEqual([
        {
            id: 100,
            from_user_id: 1,
            to_user_id: 2,
            amount: 200
        }
    ]);

    expect(settlementRepository.getUserSettlements)
        .toHaveBeenCalledWith(1);
});