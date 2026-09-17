import AppError from "../utils/errors.js";
import { getPairwiseBalance as getPairwiseBalanceRepository, createSettlement as createSettlementRepository,
         getUserSettlements as getUserSettlementsRepository } from "../repositories/settlement.repository.js";
import { getGroupMember } from "../repositories/group.repository.js";

const createSettlementService = async (groupId, toUserId, amount, fromUserId) => {
    const userIsGroupMember = await getGroupMember(groupId, fromUserId);
    if (userIsGroupMember.length === 0) {
        throw new AppError("You are not a member of this group", 403);
    }
    const toUserIsGroupMember = await getGroupMember(groupId, toUserId);
    if (toUserIsGroupMember.length === 0) {
        throw new AppError("The person you are trying to settle with is not a member of this group", 403);
    }
    if(toUserId === fromUserId) {
        throw new AppError("You cannot settle with yourself", 400);
    }
    if(typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0 || !Number.isInteger(amount * 100)) {
        throw new AppError("Invalid amount", 400);
    }
    const pairwiseBalance = await getPairwiseBalanceRepository(groupId, fromUserId, toUserId);
    
    if (pairwiseBalance.length === 0) {
        throw new AppError("You don't have any debt to settle with this user", 400);
    }
    const netDebt = Number(pairwiseBalance[0].net_debt);
    // netDebt can be negative, zero, or positive
    // If netDebt is positive, user owes the other user
    // If netDebt is negative, the other user owes this user
    // If netDebt is zero, there is no net debt between them
    
    if (netDebt <= 0) {
        throw new AppError("You don't have any debt to settle with this user", 400);
    }
    if (amount > netDebt) {
        throw new AppError("You cannot settle more than what you owe", 400);
    }
    const settlement = await createSettlementRepository(groupId, toUserId, amount, fromUserId);
    return settlement;      
}   

const getUserSettlementsService = async (groupId, userId) => {
    const userIsGroupMember = await getGroupMember(groupId, userId);
    if (userIsGroupMember.length === 0) {
        throw new AppError("You are not a member of this group", 403);
    }
    const settlements = await getUserSettlementsRepository(groupId);
    return settlements;
}

export { createSettlementService, getUserSettlementsService };