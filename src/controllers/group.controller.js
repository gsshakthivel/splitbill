import { createGroupService, getGroupsService, addGroupMemberService, getGroupDetailsService } from "../services/group.service.js";

const createGroup = async (req, res) => {
    const { name } = req.body;
    const { id } = req.user;
    const result = await createGroupService(name, id);
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
    const result = await addGroupMemberService(groupId, userId, id);
    res.status(201).json(result);
}   

const getGroupDetails = async (req, res) => {
    const { groupId } = req.params;
    const { id } = req.user;
    const result = await getGroupDetailsService(groupId, id);
    res.status(200).json(result);
}

export { createGroup, getGroups, addGroupMember, getGroupDetails };