import pool from "../config/db.js";
import { createGroup as createGroupRepository, addUserToGroup, getGroupsByUserId as getGroupsByUserIdRepository, getGroupMember, addGroupMember as addGroupMemberRepository, getGroupDetailsByGroupId as getGroupDetailsByGroupIdRepository } from "../repositories/group.repository.js";
import { findUserById } from "../repositories/user.repository.js";
import AppError from "../utils/errors.js";

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
        const userPermittedToAddMember = await getGroupMember(groupId, currentUserId);
        if (userPermittedToAddMember.length === 0 || userPermittedToAddMember[0].role !== "owner") {
            throw new AppError("User not permitted to add member", 403);
        }
        const userExists = await findUserById(targetUserId);
        if (userExists === null) {
            throw new AppError("User not found", 404);
        }
        const targetUserExistsInGroup = await getGroupMember(groupId, targetUserId);
        if (targetUserExistsInGroup.length > 0) {
            throw new AppError("User already exists in group", 409);
        }
        const groupMember = await addGroupMemberRepository(groupId, targetUserId, "member", currentUserId);
        return groupMember;
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

export { createGroupService, getGroupsService, addGroupMemberService, getGroupDetailsService };
