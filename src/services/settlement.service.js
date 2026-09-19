import AppError from "../utils/errors.js";
import { getPairwiseBalance as getPairwiseBalanceRepository, createSettlement as createSettlementRepository,
         getUserSettlements as getUserSettlementsRepository } from "../repositories/settlement.repository.js";
import { getGroupMember, getGroupMemberTransaction } from "../repositories/group.repository.js";
import { createNotification as createNotificationRepository, createNotificationRecipient as createNotificationRecipientRepository } from "../repositories/notifications.repository.js";
import { findUserById } from "../repositories/user.repository.js";
import pool from "../config/db.js";
import sendNotification from "../socket/notification.socket.js";

const createSettlementService = async (groupId, toUserId, amount, fromUserId) => {

    if (!Number.isInteger(groupId) || groupId <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    if (!Number.isInteger(toUserId) || toUserId <= 0) {
        throw new AppError("Invalid toUserId", 400);
    }

    if (!Number.isInteger(fromUserId) || fromUserId <= 0) {
        throw new AppError("Invalid fromUserId", 400);
    }

    const connection = await pool.getConnection();
    let transactionStarted = false;
    
    try {   
        
    const userIsGroupMember = await getGroupMemberTransaction(connection, groupId, fromUserId);
    if (userIsGroupMember.length === 0) {
        throw new AppError("You are not a member of this group", 403);
    }
    const toUserIsGroupMember = await getGroupMemberTransaction(connection, groupId, toUserId);
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

    const fromUserExists = await findUserById(fromUserId);
    if (fromUserExists === null) {
        throw new AppError("User not found", 404);
    }
    const fromUserName = fromUserExists.name;

    await connection.beginTransaction();
    transactionStarted = true;

    const settlement = await createSettlementRepository(connection, groupId, toUserId, amount, fromUserId);
     
    const notifyUser = await createNotificationRepository(connection, groupId, fromUserId, "settlement_created", `${fromUserName}  has settled and paid you ₹${amount.toFixed(2)}`);
    await createNotificationRecipientRepository(connection, notifyUser.id, toUserId);
    
    await connection.commit();

    sendNotification(toUserId, {
        id: notifyUser.id,
        userId: fromUserId,
        groupId,
        settlementId: settlement.id,
        type: "settlement_created",
        message: `${fromUserName} has settled and paid you ₹${amount.toFixed(2)}`
    });

    return settlement;      
    } catch (error) {
        if (transactionStarted) {
            await connection.rollback();
        }
        throw error;
    } finally {
        connection.release();
    }
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