import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/config/db.js", () => ({
    default: {
        getConnection: jest.fn()
    }
}));

jest.unstable_mockModule("../src/repositories/group.repository.js", () => ({
    getGroupMember: jest.fn(),
    getGroupMemberTransaction: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/expense.repository.js", () => ({
    createExpense: jest.fn(),
    createExpenseSplit: jest.fn(),
    getExpensesByGroupId: jest.fn(),
    getExpenseById: jest.fn(),
    getExpenseForUpdate: jest.fn(),
    updateExpense: jest.fn(),
    deleteExpenseSplits: jest.fn(),
    deleteExpense: jest.fn(),
    getExpenseParticipants: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/notifications.repository.js", () => ({
    createNotification: jest.fn(),
    createNotificationRecipient: jest.fn()
}));

jest.unstable_mockModule("../src/socket/notification.socket.js", () => ({
    default: jest.fn()
}));

const {
    createExpenseService,
    getExpensesService,
    getExpenseByIdService,
    updateExpenseService,
    deleteExpenseService
} = await import("../src/services/expense.service.js");

const pool = (await import("../src/config/db.js")).default;

const groupRepository =
    await import("../src/repositories/group.repository.js");

const expenseRepository =
    await import("../src/repositories/expense.repository.js");

const notificationRepository =
    await import("../src/repositories/notifications.repository.js");

const { default: sendNotification } =
    await import("../src/socket/notification.socket.js");

beforeEach(() => {
    jest.clearAllMocks();
});

test("createExpenseService should create an expense with equal splits", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 1 }]);

    expenseRepository.createExpense.mockResolvedValue({
        id: 100,
        group_id: 1,
        paid_by: 1,
        amount: 100,
        description: "Dinner"
    });

    expenseRepository.createExpenseSplit.mockResolvedValue({});

    notificationRepository.createNotification.mockResolvedValue({ id: 500 });
    notificationRepository.createNotificationRecipient.mockResolvedValue({});

    const result = await createExpenseService(
        1,
        1,
        100,
        " Dinner ",
        "equal",
        1,
        [{ userId: 1 }, { userId: 2 }, { userId: 3 }]
    );

    expect(result).toEqual({
        id: 100,
        group_id: 1,
        paid_by: 1,
        amount: 100,
        description: "Dinner"
    });

    expect(expenseRepository.createExpenseSplit)
        .toHaveBeenCalledTimes(3);

    expect(expenseRepository.createExpenseSplit)
        .toHaveBeenNthCalledWith(
            1, connection, 100, 1, 33.33
        );

    expect(expenseRepository.createExpenseSplit)
        .toHaveBeenNthCalledWith(
            2, connection, 100, 2, 33.33
        );

    expect(expenseRepository.createExpenseSplit)
        .toHaveBeenNthCalledWith(
            3, connection, 100, 3, 33.34
        );

    expect(connection.commit).toHaveBeenCalled();
});

test("createExpenseService should reject an invalid amount", async () => {
    await expect(
        createExpenseService(
            1,
            1,
            -100,
            "Dinner",
            "equal",
            1,
            [{ userId: 1 }]
        )
    ).rejects.toThrow(
        "Amount is required and should be greater than 0"
    );

    expect(pool.getConnection).not.toHaveBeenCalled();
});

test("createExpenseService should reject a non-member creator", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([]);

    await expect(
        createExpenseService(
            1,
            1,
            100,
            "Dinner",
            "equal",
            10,
            [{ userId: 1 }]
        )
    ).rejects.toThrow("You are not a part of this group");

    expect(connection.commit).not.toHaveBeenCalled();
});

test("createExpenseService should reject duplicate users in splits", async () => {
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
        createExpenseService(
            1,
            1,
            100,
            "Dinner",
            "equal",
            1,
            [{ userId: 1 }, { userId: 1 }]
        )
    ).rejects.toThrow("Duplicate users in splits");

    expect(connection.beginTransaction).not.toHaveBeenCalled();
});

test("getExpensesService should reject a non-member", async () => {
    groupRepository.getGroupMember.mockResolvedValue([]);

    await expect(
        getExpensesService(1, 10)
    ).rejects.toThrow("You are not a part of this group");

    expect(expenseRepository.getExpensesByGroupId)
        .not.toHaveBeenCalled();
});

test("getExpenseByIdService should return expense with splits", async () => {
    groupRepository.getGroupMember.mockResolvedValue([
        { user_id: 10 }
    ]);

    expenseRepository.getExpenseById.mockResolvedValue([
        {
            expense_id: 100,
            description: "Dinner",
            group_id: 1,
            amount: 100,
            paid_by: 10,
            created_by: 10,
            split_type: "equal",
            created_at: "2026-09-19",
            user_id: 10,
            split_amount: 50
        },
        {
            expense_id: 100,
            description: "Dinner",
            group_id: 1,
            amount: 100,
            paid_by: 10,
            created_by: 10,
            split_type: "equal",
            created_at: "2026-09-19",
            user_id: 20,
            split_amount: 50
        }
    ]);

    const result = await getExpenseByIdService(1, 100, 10);

    expect(result).toEqual(expect.objectContaining({
        expenseId: 100,
        description: "Dinner",
        amount: 100,
        paidBy: 10
    }));

    expect(result.splits).toEqual([
        { userId: 10, amount: 50 },
        { userId: 20, amount: 50 }
    ]);
});

test("updateExpenseService should update an expense", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 10 }]);

    expenseRepository.getExpenseForUpdate.mockResolvedValue([
        { created_by: 10 }
    ]);

    expenseRepository.getExpenseParticipants
        .mockResolvedValue([10, 20]);

    expenseRepository.updateExpense.mockResolvedValue({
        id: 100,
        description: "Updated Dinner"
    });

    expenseRepository.deleteExpenseSplits.mockResolvedValue({});
    expenseRepository.createExpenseSplit.mockResolvedValue({});

    const result = await updateExpenseService(
        1,
        100,
        10,
        "Updated Dinner",
        100,
        10,
        "equal",
        [{ userId: 10 }, { userId: 20 }]
    );

    expect(result).toEqual({
        id: 100,
        description: "Updated Dinner"
    });

    expect(expenseRepository.updateExpense).toHaveBeenCalled();

    expect(expenseRepository.deleteExpenseSplits)
        .toHaveBeenCalledWith(connection, 100);

    expect(connection.commit).toHaveBeenCalled();
});

test("deleteExpenseService should delete an expense", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValue([{ user_id: 10 }]);

    expenseRepository.getExpenseForUpdate.mockResolvedValue([
        {
            created_by: 10,
            description: "Dinner",
            amount: 100
        }
    ]);

    expenseRepository.getExpenseParticipants
        .mockResolvedValue([10, 20]);

    expenseRepository.deleteExpenseSplits.mockResolvedValue({});
    expenseRepository.deleteExpense.mockResolvedValue(1);

    notificationRepository.createNotification
        .mockResolvedValue({ id: 500 });

    notificationRepository.createNotificationRecipient
        .mockResolvedValue({});

    const result = await deleteExpenseService(1, 100, 10);

    expect(result).toEqual({
        expenseId: 100
    });

    expect(expenseRepository.deleteExpenseSplits)
        .toHaveBeenCalledWith(connection, 100);

    expect(expenseRepository.deleteExpense)
        .toHaveBeenCalledWith(connection, 100);

    expect(connection.commit).toHaveBeenCalled();

    expect(sendNotification).toHaveBeenCalled();
});