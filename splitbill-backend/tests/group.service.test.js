import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/config/db.js", () => ({
    default: {
        getConnection: jest.fn()
    }
}));

jest.unstable_mockModule("../src/repositories/group.repository.js", () => ({
    createGroup: jest.fn(),
    addUserToGroup: jest.fn(),
    getGroupsByUserId: jest.fn(),
    getGroupMember: jest.fn(),
    addGroupMember: jest.fn(),
    getGroupDetailsByGroupId: jest.fn(),
    hasUserExpensesInGroup: jest.fn(),
    removeGroupMember: jest.fn(),
    getGroupBalances: jest.fn(),
    getGroupMemberTransaction: jest.fn(),
    getGroupByIdForUpdate: jest.fn(),
    updateGroupName: jest.fn(),
    hasGroupFinancialRecords: jest.fn(),
    deleteGroupNotificationRecipients: jest.fn(),
    deleteGroupNotifications: jest.fn(),
    deleteGroupMembers: jest.fn(),
    deleteGroup: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/user.repository.js", () => ({
    findUserById: jest.fn()
}));

jest.unstable_mockModule("../src/repositories/notifications.repository.js", () => ({
    createNotification: jest.fn(),
    createNotificationRecipient: jest.fn()
}));

jest.unstable_mockModule("../src/socket/notification.socket.js", () => ({
    default: jest.fn()
}));

const {
    createGroupService,
    getGroupsService,
    addGroupMemberService,
    getGroupDetailsService,
    removeGroupMemberService,
    getGroupBalancesService,
    updateGroupService,
    deleteGroupService
} = await import("../src/services/group.service.js");

const pool = (await import("../src/config/db.js")).default;

const groupRepository =
    await import("../src/repositories/group.repository.js");

const { findUserById } =
    await import("../src/repositories/user.repository.js");

const notificationRepository =
    await import("../src/repositories/notifications.repository.js");

const { default: sendNotification } =
    await import("../src/socket/notification.socket.js");


beforeEach(() => {
    jest.clearAllMocks();
});


test("createGroupService should create a group and add the creator as owner", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.createGroup.mockResolvedValue({
        id: 1,
        name: "Trip",
        created_by: 10
    });

    const result = await createGroupService("Trip", 10);

    expect(result).toEqual({
        id: 1,
        name: "Trip",
        created_by: 10
    });

    expect(groupRepository.addUserToGroup).toHaveBeenCalledWith(
        connection,
        1,
        10,
        "owner",
        10
    );

    expect(connection.commit).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("getGroupsService should return groups for a user", async () => {
    groupRepository.getGroupsByUserId.mockResolvedValue([
        { id: 1, name: "Trip" },
        { id: 2, name: "Office" }
    ]);

    const result = await getGroupsService(10);

    expect(result).toEqual([
        { id: 1, name: "Trip" },
        { id: 2, name: "Office" }
    ]);

    expect(groupRepository.getGroupsByUserId)
        .toHaveBeenCalledWith(10);
});

test("addGroupMemberService should allow owner to add a member", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValueOnce([{ role: "owner" }])
        .mockResolvedValueOnce([]);

    findUserById.mockResolvedValue({
        id: 20,
        name: "User 2"
    });

    groupRepository.addGroupMember.mockResolvedValue({
        group_id: 1,
        user_id: 20,
        role: "member"
    });

    notificationRepository.createNotification.mockResolvedValue({
        id: 100
    });

    const result = await addGroupMemberService(1, 20, 10);

    expect(result).toEqual({
        group_id: 1,
        user_id: 20,
        role: "member"
    });

    expect(connection.commit).toHaveBeenCalled();

    expect(sendNotification).toHaveBeenCalledWith(
        20,
        expect.objectContaining({
            groupId: 1,
            type: "member_added"
        })
    );
});

test("addGroupMemberService should reject a non-owner", async () => {
    const connection = {
        getConnection: jest.fn(),
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "member" }
    ]);

    await expect(
        addGroupMemberService(1, 20, 10)
    ).rejects.toThrow("User not permitted to add member");

    expect(findUserById).not.toHaveBeenCalled();
    expect(connection.commit).not.toHaveBeenCalled();
});

test("getGroupDetailsService should reject a non-member", async () => {
    groupRepository.getGroupMember.mockResolvedValue([]);

    await expect(
        getGroupDetailsService(1, 10)
    ).rejects.toThrow("User not permitted to view group details");

    expect(groupRepository.getGroupDetailsByGroupId)
        .not.toHaveBeenCalled();
});

test("removeGroupMemberService should remove a member", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValueOnce([{ role: "owner" }])
        .mockResolvedValueOnce([{ user_id: 20 }]);

    groupRepository.hasUserExpensesInGroup
        .mockResolvedValue(false);

    groupRepository.removeGroupMember.mockResolvedValue({
        affectedRows: 1
    });

    notificationRepository.createNotification.mockResolvedValue({
        id: 101
    });

    const result = await removeGroupMemberService(1, 20, 10);

    expect(result).toEqual({
        message: "Group member removed successfully"
    });

    expect(connection.commit).toHaveBeenCalled();

    expect(sendNotification).toHaveBeenCalledWith(
        20,
        expect.objectContaining({
            groupId: 1,
            type: "member_removed"
        })
    );
});

test("removeGroupMemberService should reject member with expense history", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupMemberTransaction
        .mockResolvedValueOnce([{ role: "owner" }])
        .mockResolvedValueOnce([{ user_id: 20 }]);

    groupRepository.hasUserExpensesInGroup
        .mockResolvedValue(true);

    await expect(
        removeGroupMemberService(1, 20, 10)
    ).rejects.toThrow(
        "Cannot remove member with existing expense history"
    );

    expect(groupRepository.removeGroupMember)
        .not.toHaveBeenCalled();

    expect(connection.commit).not.toHaveBeenCalled();
});

test("getGroupBalancesService should return group balances", async () => {
    groupRepository.getGroupMember.mockResolvedValue([
        { user_id: 10 }
    ]);

    groupRepository.getGroupBalances.mockResolvedValue([
        { user_id: 10, balance: 500 },
        { user_id: 20, balance: -500 }
    ]);

    const result = await getGroupBalancesService(1, 10);

    expect(result).toEqual([
        { userId: 10, balance: 500 },
        { userId: 20, balance: -500 }
    ]);

    expect(groupRepository.getGroupBalances)
        .toHaveBeenCalledWith(1);
});

// ==================== UPDATE GROUP TESTS ====================

test("updateGroupService should update group name when requested by owner", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "owner" }
    ]);

    groupRepository.updateGroupName.mockResolvedValue({
        affectedRows: 1
    });

    const result = await updateGroupService(1, "Updated Trip", 10);

    expect(result).toEqual({
        id: 1,
        name: "Updated Trip",
        createdBy: 10
    });

    expect(groupRepository.updateGroupName).toHaveBeenCalledWith(
        connection,
        1,
        "Updated Trip"
    );

    expect(connection.commit).toHaveBeenCalled();
    expect(connection.rollback).not.toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("updateGroupService should reject a non-owner", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "member" }
    ]);

    await expect(
        updateGroupService(1, "Updated Trip", 20)
    ).rejects.toThrow("User not permitted to update this group");

    expect(groupRepository.updateGroupName).not.toHaveBeenCalled();
    expect(connection.commit).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("updateGroupService should reject when group does not exist", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([]);

    await expect(
        updateGroupService(999, "Updated Trip", 10)
    ).rejects.toThrow("Group not found");

    expect(groupRepository.getGroupMemberTransaction).not.toHaveBeenCalled();
    expect(groupRepository.updateGroupName).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("updateGroupService should rollback when updating group fails", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "owner" }
    ]);

    groupRepository.updateGroupName.mockRejectedValue(
        new Error("Database update failed")
    );

    await expect(
        updateGroupService(1, "Updated Trip", 10)
    ).rejects.toThrow("Database update failed");

    expect(connection.commit).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

// ==================== DELETE GROUP TESTS ====================

test("deleteGroupService should delete an empty group when requested by owner", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "owner" }
    ]);

    groupRepository.hasGroupFinancialRecords.mockResolvedValue(false);

    groupRepository.deleteGroup.mockResolvedValue({
        affectedRows: 1
    });

    const result = await deleteGroupService(1, 10);

    expect(result).toEqual({
        message: "Group deleted successfully"
    });

    expect(
        groupRepository.deleteGroupNotificationRecipients
    ).toHaveBeenCalledWith(connection, 1);

    expect(
        groupRepository.deleteGroupNotifications
    ).toHaveBeenCalledWith(connection, 1);

    expect(
        groupRepository.deleteGroupMembers
    ).toHaveBeenCalledWith(connection, 1);

    expect(groupRepository.deleteGroup).toHaveBeenCalledWith(
        connection,
        1
    );

    expect(connection.commit).toHaveBeenCalled();
    expect(connection.rollback).not.toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("deleteGroupService should reject a non-owner", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "member" }
    ]);

    await expect(
        deleteGroupService(1, 20)
    ).rejects.toThrow("User not permitted to delete this group");

    expect(groupRepository.hasGroupFinancialRecords).not.toHaveBeenCalled();
    expect(groupRepository.deleteGroup).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("deleteGroupService should reject when group does not exist", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([]);

    await expect(
        deleteGroupService(999, 10)
    ).rejects.toThrow("Group not found");

    expect(groupRepository.getGroupMemberTransaction).not.toHaveBeenCalled();
    expect(groupRepository.hasGroupFinancialRecords).not.toHaveBeenCalled();
    expect(groupRepository.deleteGroup).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("deleteGroupService should reject deletion when group has expenses", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "owner" }
    ]);

    groupRepository.hasGroupFinancialRecords.mockResolvedValue(true);

    await expect(
        deleteGroupService(1, 10)
    ).rejects.toThrow(
        "Cannot delete a group with existing expenses or settlements"
    );

    expect(groupRepository.deleteGroup).not.toHaveBeenCalled();
    expect(connection.commit).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("deleteGroupService should reject deletion when group has settlements", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "owner" }
    ]);

    groupRepository.hasGroupFinancialRecords.mockResolvedValue(true);

    await expect(
        deleteGroupService(1, 10)
    ).rejects.toThrow(
        "Cannot delete a group with existing expenses or settlements"
    );

    expect(groupRepository.deleteGroup).not.toHaveBeenCalled();
    expect(connection.commit).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});

test("deleteGroupService should rollback when group deletion fails", async () => {
    const connection = {
        beginTransaction: jest.fn(),
        commit: jest.fn(),
        rollback: jest.fn(),
        release: jest.fn()
    };

    pool.getConnection.mockResolvedValue(connection);

    groupRepository.getGroupByIdForUpdate.mockResolvedValue([
        { id: 1, name: "Trip", created_by: 10 }
    ]);

    groupRepository.getGroupMemberTransaction.mockResolvedValue([
        { role: "owner" }
    ]);

    groupRepository.hasGroupFinancialRecords.mockResolvedValue(false);

    groupRepository.deleteGroup.mockRejectedValue(
        new Error("Database deletion failed")
    );

    await expect(
        deleteGroupService(1, 10)
    ).rejects.toThrow("Database deletion failed");

    expect(connection.commit).not.toHaveBeenCalled();
    expect(connection.rollback).toHaveBeenCalled();
    expect(connection.release).toHaveBeenCalled();
});