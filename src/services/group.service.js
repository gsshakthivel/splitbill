import pool from "../config/db.js";
import { createGroup as createGroupRepository, addUserToGroup, getGroupsByUserId as getGroupsByUserIdRepository,
     getGroupMember, addGroupMember as addGroupMemberRepository, getGroupDetailsByGroupId as getGroupDetailsByGroupIdRepository, 
     hasUserExpensesInGroup, removeGroupMember as removeGroupMemberRepository,
     getGroupBalances as getGroupBalancesRepository, 
     getGroupMemberTransaction} from "../repositories/group.repository.js";
import { findUserById } from "../repositories/user.repository.js";
import { createNotification as createNotificationRepository, createNotificationRecipient as createNotificationRecipientRepository } from "../repositories/notifications.repository.js";
import AppError from "../utils/errors.js";
import sendNotification from "../socket/notification.socket.js";

const createGroupService = async (name, userId) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const group = await createGroupRepository(connection, name, userId);
        await addUserToGroup(connection, group.id, userId, "owner", userId);
        await connection.commit();
        return group;
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

const getGroupsService = async (userId) => {
        const groups = await getGroupsByUserIdRepository(userId);
        return groups;
}

const addGroupMemberService = async (groupId, targetUserId, currentUserId) => {
    const connection = await pool.getConnection();
    let transactionStarted = false;
    try {
        const userPermittedToAddMember = await getGroupMemberTransaction(connection, groupId, currentUserId);
        if (userPermittedToAddMember.length === 0 || userPermittedToAddMember[0].role !== "owner") {
            throw new AppError("User not permitted to add member", 403);
        }
        const userExists = await findUserById(targetUserId);
        if (userExists === null) {
            throw new AppError("User not found", 404);
        }
        const targetUserExistsInGroup = await getGroupMemberTransaction(connection, groupId, targetUserId);
        if (targetUserExistsInGroup.length > 0) {
            throw new AppError("User already exists in group", 409);
        }

        await connection.beginTransaction();
        transactionStarted = true;
        const groupMember = await addGroupMemberRepository(connection, groupId, targetUserId, "member", currentUserId);
        
        const notifyTargetUser = await createNotificationRepository(connection, groupId, currentUserId, "member_added", `You were added to the group`);
        await createNotificationRecipientRepository(connection, notifyTargetUser.id, targetUserId);
        
        await connection.commit();

        sendNotification(targetUserId, {
            id: notifyTargetUser.id,
            userId: currentUserId,
            groupId,
            type: "member_added",
            message: `You were added to the group`
        });

        return groupMember;
    } catch (error) {
        if(transactionStarted) {
            await connection.rollback();
        }
        throw error;
    } finally {
        connection.release();
    }
}

const getGroupDetailsService = async (groupId, currentUserId) => {
        const currentUserMembership = await getGroupMember(groupId, currentUserId);
        if (currentUserMembership.length === 0) {
            throw new AppError("User not permitted to view group details", 403);
        }
        const groupDetails = await getGroupDetailsByGroupIdRepository(groupId);
        const group = groupDetails[0];
        const members = groupDetails.map(member => ({
            user_id: member.user_id,
            username: member.username,
            role: member.role
        }));
        return {
            id: group.id,
            name: group.name,
            createdBy: group.created_by,
            members: members
        };
}

const removeGroupMemberService = async (groupId, targetUserId, currentUserId) => {
    const connection = await pool.getConnection();
    let transactionStarted = false;
    try {
    const requesterMembership = await getGroupMemberTransaction(connection, groupId, currentUserId);
    if (requesterMembership.length === 0 || requesterMembership[0].role !== "owner") {
        throw new AppError("User not permitted to remove member", 403);
    }

    if (String(targetUserId) === String(currentUserId)) {
        throw new AppError("Owner cannot remove themselves from the group", 400);
    }

    const targetUserMembership = await getGroupMemberTransaction(connection, groupId, targetUserId);
    if (targetUserMembership.length === 0) {
        throw new AppError("User is not a member of this group", 404);
    }

    const hasExpenses = await hasUserExpensesInGroup(groupId, targetUserId);
    if (hasExpenses) {
        throw new AppError("Cannot remove member with existing expense history", 409);
    }

    await connection.beginTransaction();
    transactionStarted = true;

    const deletedMember = await removeGroupMemberRepository(connection, groupId, targetUserId);

    if (deletedMember.affectedRows !== 1) {
        throw new AppError("Member could not be removed", 500);
    }

    const notifyTargetUser = await createNotificationRepository(connection, groupId, currentUserId, "member_removed", `You were removed from the group`);
    await createNotificationRecipientRepository(connection, notifyTargetUser.id, targetUserId);

    await connection.commit();

    sendNotification(targetUserId, {
        id: notifyTargetUser.id,
        userId: currentUserId,
        groupId,
        type: "member_removed",
        message: `You were removed from the group`
    });

    return { message: "Group member removed successfully" };
    } catch (error) {
        if(transactionStarted) {
            await connection.rollback();
        }
        throw error;
    } finally {
        connection.release();
    }
}

const getGroupBalancesService = async (groupId, currentUserId) => {
    const currentUserMembership = await getGroupMember(groupId, currentUserId);
    if (currentUserMembership.length === 0) {
        throw new AppError("User not permitted to view group balances", 403);
    }
    const groupBalances = await getGroupBalancesRepository(groupId);
    const balanceResult = groupBalances.map(balance => ({
        userId: balance.user_id,
        balance: balance.balance
    }));
    return balanceResult;
}

export { createGroupService, getGroupsService, addGroupMemberService, getGroupDetailsService, removeGroupMemberService, getGroupBalancesService };
