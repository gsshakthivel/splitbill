import { createGroupService, getGroupsService, addGroupMemberService, getGroupDetailsService, removeGroupMemberService, getGroupBalancesService } from "../services/group.service.js";
import AppError from "../utils/errors.js";

const createGroup = async (req, res) => {
    const { name } = req.body;
    const { id } = req.user;

    if (typeof name !== "string" || name.trim().length === 0) {
        throw new AppError("Group name is required", 400);
    }

    const result = await createGroupService(name.trim(), id);
    res.status(201).json(result);
}

const getGroups = async (req, res) => {
    const { id } = req.user;
    const result = await getGroupsService(id);
    res.status(200).json(result);
}   

const addGroupMember = async (req, res) => {
    const { groupId } = req.params;
    const { userId } = req.body;
    const { id } = req.user;

    const groupIdNumber = Number(groupId);

    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    const userIdNumber = Number(userId);

    if (!Number.isInteger(userIdNumber) || userIdNumber <= 0) {
        throw new AppError("Invalid userId", 400);
    }

    const result = await addGroupMemberService(groupIdNumber, userIdNumber, id);
    res.status(201).json(result);
}   

const getGroupDetails = async (req, res) => {
    const { groupId } = req.params;
    const { id } = req.user;

    const groupIdNumber = Number(groupId);

    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    const result = await getGroupDetailsService(groupIdNumber, id);
    res.status(200).json(result);
}

const removeGroupMember = async (req, res) => {
    const { groupId, userId } = req.params;
    const { id } = req.user;    

    const groupIdNumber = Number(groupId);

    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    const userIdNumber = Number(userId);

    if (!Number.isInteger(userIdNumber) || userIdNumber <= 0) {
        throw new AppError("Invalid userId", 400);
    }

    const result = await removeGroupMemberService(groupIdNumber, userIdNumber, id);
    res.status(200).json(result);
}

const getGroupBalances = async (req, res) => {
    const { groupId } = req.params;
    const { id } = req.user;

    const groupIdNumber = Number(groupId);

    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    const result = await getGroupBalancesService(groupIdNumber, id);
    res.status(200).json({
    message: "Group balances fetched successfully",
    data: result
});
}

export { createGroup, getGroups, addGroupMember, getGroupDetails, removeGroupMember, getGroupBalances };