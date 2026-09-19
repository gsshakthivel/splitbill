import pool from "../config/db.js";
import AppError from "../utils/errors.js";
import { getGroupMember, getGroupMemberTransaction } from "../repositories/group.repository.js";
import { createExpense as createExpenseRepository, createExpenseSplit as createExpenseSplitRepository, 
    getExpensesByGroupId, getExpenseById as getExpenseByIdRepository, 
    getExpenseForUpdate as getExpenseForUpdateRepository, updateExpense as updateExpenseRepository, 
    deleteExpenseSplits as deleteExpenseSplitsRepository, deleteExpense as deleteExpenseRepository,
    getExpenseParticipants as getExpenseParticipantsRepository } from "../repositories/expense.repository.js";
import { createNotification as createNotificationRepository, createNotificationRecipient as createNotificationRecipientRepository } from "../repositories/notifications.repository.js";
import sendNotification from "../socket/notification.socket.js";

const createExpenseService = async (groupId, paidBy, amount, description, splitType, createdBy, splits) => {
    
        if (!Number.isInteger(paidBy) || paidBy <= 0) {
            throw new AppError("paidBy must be a positive integer", 400);
        }
        if (description === null || description === undefined || typeof description !== 'string' || description.trim().length === 0 || description.trim().length > 100 ) {
            throw new AppError("Description is required and must be 100 characters or less", 400);
        }
        if (typeof amount !== 'number' || Number.isFinite(amount) === false || amount <= 0 || !Number.isInteger(amount * 100) ) {
            throw new AppError("Amount is required and should be greater than 0", 400);
        }
        if (typeof splitType !== 'string' || splitType !== "equal") {
            throw new AppError("Invalid split type", 400);  
        }
        if(!Array.isArray(splits) || splits.length === 0) {
            throw new AppError("Splits members are required", 400);
        }
        const isValidSplits = splits.every(member => 
            member !== null && typeof member === "object" && !Array.isArray(member) 
            && Number.isInteger(member.userId) && member.userId > 0 );  
        if (!isValidSplits) {
            throw new AppError("Each split must contain a valid userId", 400);
        }

        const connection = await pool.getConnection();
        let transactionStarted = false;
        try {
            
        const userPermittedToCreateExpense = await getGroupMemberTransaction(connection, groupId, createdBy);
        if (userPermittedToCreateExpense.length === 0) {
            throw new AppError("You are not a part of this group", 403);
        }
        
        const paidByGroupMembers = await getGroupMemberTransaction(connection, groupId, paidBy);
        if (paidByGroupMembers.length === 0) {
            throw new AppError("The person who paid the amount is not a part of this group", 403);
        }
        for (const  member of splits) {
            const userSplits = await getGroupMemberTransaction(connection, groupId, member.userId);
            if (userSplits.length === 0) {
                throw new AppError("The person who is participating in splits is not a part of this group", 403);
            }       
            
        }
        const isMemberInSplits = splits.some(member => member.userId === createdBy);
        if(createdBy !== paidBy && !isMemberInSplits ) {
            throw new AppError("You are not authorized to create this expense", 403);
        }
        const userIds = splits.map(split => split.userId);
        const uniqueUserIds = new Set(userIds);
        if (uniqueUserIds.size !== userIds.length) {
            throw new AppError("Duplicate users in splits", 400);
        }
        const normalizedDescription = description.trim();

        await connection.beginTransaction();
        transactionStarted = true;

        const expense = await createExpenseRepository(connection, groupId, paidBy, amount, normalizedDescription, splitType, createdBy);
        if (splitType === "equal") {
            const totalPaise = amount * 100;
            const baseSharePaise = Math.floor(totalPaise / splits.length);
            const remainderPaise = totalPaise % splits.length;  
            
            for (let member = 0; member < splits.length; member++) {
                let shareAmount;
                if (member === splits.length - 1) {
                    shareAmount = (baseSharePaise + remainderPaise) / 100;
                } else {
                    shareAmount = baseSharePaise / 100;
                }
                await createExpenseSplitRepository(connection, expense.id, splits[member].userId, shareAmount);
            }
        }

        const recipients = [...uniqueUserIds].filter(userId => userId !== createdBy);
        const notificationMessage = `${normalizedDescription} expense of ₹${amount.toFixed(2)} was added to the group`;

        let notification;
        
        if (recipients.length > 0) {
            notification = await createNotificationRepository(connection, groupId, createdBy, "expense_created", notificationMessage);
            for (const recipient of recipients) {
                await createNotificationRecipientRepository(connection, notification.id, recipient);
            }
        }

        await connection.commit();

        for (const recipient of recipients) {
            sendNotification(recipient, {
                id: notification.id,
                userId: createdBy,
                groupId,
                expenseId: expense.id,
                type: "expense_created",
                message: notificationMessage
            });
        }

        return expense;
    } catch (error) {
        if (transactionStarted) {
            await connection.rollback();
        }
        throw error;
    } finally {
        connection.release();
    }
}   

const getExpensesService = async (groupId, userId) => {
    const groupMember = await getGroupMember(groupId, userId);
    if (groupMember.length === 0) {
        throw new AppError("You are not a part of this group", 403);
    }
    const expenses = await getExpensesByGroupId(groupId, userId);
    return expenses;
}

const getExpenseByIdService = async (groupId, expenseId, userId) => {
    const groupMember = await getGroupMember(groupId, userId);
    if (groupMember.length === 0) {
        throw new AppError("You are not a part of this group", 403);
    }
    const expense = await getExpenseByIdRepository(groupId, expenseId);
    if (expense.length === 0) {
        throw new AppError("Expense not found", 404);
    }
    const response = {
        expenseId: expense[0].expense_id,
        description: expense[0].description,
        groupId: expense[0].group_id,
        amount: expense[0].amount,
        paidBy: expense[0].paid_by,
        createdBy: expense[0].created_by,
        splitType: expense[0].split_type,
        createdAt: expense[0].created_at,

        splits: expense.map((row) => ({
            userId: row.user_id,
            amount: row.split_amount
        }))
    };

    return response;
}

const updateExpenseService = async (groupId, expenseId, userId, description, amount, paidBy, splitType, splits) => {
    if (description === null || description === undefined || typeof description !== 'string' || description.trim().length === 0 || description.trim().length > 100 ) {
            throw new AppError("Description is required and should be less than 100 characters", 400);
        }
        if (typeof amount !== 'number' || Number.isFinite(amount) === false || amount <= 0 || !Number.isInteger(amount * 100) ) {
            throw new AppError("Amount is required and should be greater than 0", 400);
        }
        if (!Number.isInteger(paidBy) || paidBy <= 0) {
            throw new AppError("paidBy must be a positive integer", 400);
        }
        if (typeof splitType !== 'string' || splitType !== "equal") {
            throw new AppError("Invalid split type", 400);  
        }
        if(!Array.isArray(splits) || splits.length === 0) {
            throw new AppError("Splits members are required", 400);
        }
        const isValidSplits = splits.every(member => 
            member !== null && typeof member === "object" && !Array.isArray(member) 
            && Number.isInteger(member.userId) && member.userId > 0 );  
        if (!isValidSplits) {
            throw new AppError("Each split must contain a valid userId", 400);
        }

    const connection = await pool.getConnection();
    let transactionStarted = false;
    try {
        const userPermittedToUpdateExpense = await getGroupMemberTransaction(connection, groupId, userId);
        if (userPermittedToUpdateExpense.length === 0) {
            throw new AppError("You are not a part of this group", 403);
        }
        const expense = await getExpenseForUpdateRepository(connection, groupId, expenseId);
        if (expense.length === 0) {
            throw new AppError("Expense not found", 404);
        }
        if (expense[0].created_by !== userId) {
            throw new AppError("You are not authorized to update this expense", 403);
        }  
        
        const paidByGroupMembers = await getGroupMemberTransaction(connection, groupId, paidBy);
        if (paidByGroupMembers.length === 0) {
            throw new AppError("The person who paid the amount is not a part of this group", 403);
        }
        for (const  member of splits) {
            const userSplits = await getGroupMemberTransaction(connection, groupId, member.userId);
            if (userSplits.length === 0) {
                throw new AppError("The person who is participating in splits is not a part of this group", 403);
            }       
            
        }

        const userIds = splits.map(split => split.userId);
        const uniqueUserIds = new Set(userIds);
        if (uniqueUserIds.size !== userIds.length) {
            throw new AppError("Duplicate users in splits", 400);
        }

        const isUserInSplits = uniqueUserIds.has(userId);

        if (userId !== paidBy && !isUserInSplits) {
            throw new AppError("You must be the payer or a participant in the expense", 403);
        }

        const existingParticipants = await getExpenseParticipantsRepository(connection, expenseId);
           
        const normalizedDescription = description.trim();

        const socketNotifications = [];

        await connection.beginTransaction();
        transactionStarted = true;

        const updatedExpense = await updateExpenseRepository(connection, groupId, expenseId, paidBy, amount, normalizedDescription, splitType, userId);

        await deleteExpenseSplitsRepository(connection, expenseId);
        if (splitType === "equal") {
            
            const totalPaise = amount * 100;
            const baseSharePaise = Math.floor(totalPaise / splits.length);
            const remainderPaise = totalPaise % splits.length;
            for (let member = 0; member < splits.length; member++) {
                let shareAmount;
                if (member === splits.length - 1) {
                    shareAmount = (baseSharePaise + remainderPaise) / 100;
                } else {
                    shareAmount = baseSharePaise / 100;
                }
                await createExpenseSplitRepository(connection, expenseId, splits[member].userId, shareAmount);
            }
        }

        const removedParticipants = existingParticipants.filter(id => !uniqueUserIds.has(id));
        const addedParticipants = [...uniqueUserIds].filter(id => !existingParticipants.includes(id));
        const unchangedParticipants = [...uniqueUserIds].filter(id => existingParticipants.includes(id));

        const updatedRecipients = unchangedParticipants.filter(id => id !== userId);
        const addedRecipients = addedParticipants.filter(id => id !== userId);
        const removedRecipients = removedParticipants.filter(id => id !== userId);

        const addedRecipientsNotificationMessage = `You were added to the ${normalizedDescription} expense of ₹${amount.toFixed(2)}`;
        const updatedRecipientsNotificationMessage = `${normalizedDescription} expense of ₹${amount.toFixed(2)} was updated in the group`;
        const removedRecipientsNotificationMessage = `You were removed from the ${normalizedDescription} expense of ₹${amount.toFixed(2)}`;
        
        if(addedRecipients.length > 0) {
            const notification = await createNotificationRepository(connection, groupId, userId, "expense_participant_added", addedRecipientsNotificationMessage);
            for (const recipient of addedRecipients) {
                await createNotificationRecipientRepository(connection, notification.id, recipient);

                socketNotifications.push({
                    recipient,
                    notification: {
                        id: notification.id,
                        userId,
                        groupId,
                        expenseId,
                        type: "expense_participant_added",
                        message: addedRecipientsNotificationMessage
                    }
                });
            }
        }
        if(updatedRecipients.length > 0) {
            const notification = await createNotificationRepository(connection, groupId, userId, "expense_updated", updatedRecipientsNotificationMessage);
            for (const recipient of updatedRecipients) {
                await createNotificationRecipientRepository(connection, notification.id, recipient);

                socketNotifications.push({
                    recipient,
                    notification: {
                        id: notification.id,
                        userId,
                        groupId,
                        expenseId,
                        type: "expense_updated",
                        message: updatedRecipientsNotificationMessage
                    }
                });
            }
        }
        if(removedRecipients.length > 0) {
            const notification = await createNotificationRepository(connection, groupId, userId, "expense_participant_removed", removedRecipientsNotificationMessage);
            for (const recipient of removedRecipients) {
                await createNotificationRecipientRepository(connection, notification.id, recipient);

                socketNotifications.push({
                    recipient,
                    notification: {
                        id: notification.id,
                        userId,
                        groupId,
                        expenseId,
                        type: "expense_participant_removed",
                        message: removedRecipientsNotificationMessage
                    }
                });
            }
        }

        await connection.commit();

        socketNotifications.forEach(({ recipient, notification }) => {
            sendNotification(recipient, notification);
        });
        
        return updatedExpense;
    } catch (error) {
        if (transactionStarted) {
            await connection.rollback();
        }
        throw error;
    } finally {
        connection.release();
    }
    
}   

const deleteExpenseService = async (groupId, expenseId, userId) => {
    const connection = await pool.getConnection();
    let transactionStarted = false;

    try {
        const groupMember = await getGroupMemberTransaction(connection, groupId, userId);
        if (groupMember.length === 0) {
            throw new AppError("You are not a part of this group", 403);
        }
        const expense = await getExpenseForUpdateRepository(connection, groupId, expenseId);
        if (expense.length === 0) {
                throw new AppError("Expense not found", 404);
        }
        if (expense[0].created_by !== userId) {
            throw new AppError("You are not authorized to delete this expense", 403);
        }

        const existingParticipants = await getExpenseParticipantsRepository(connection, expenseId);
        const notificationRecipients = existingParticipants.filter(id => id !== userId);
    
        await connection.beginTransaction();
        transactionStarted = true;

        await deleteExpenseSplitsRepository(connection, expenseId);
        const deletedRows = await deleteExpenseRepository(connection, expenseId);
        if (deletedRows !== 1) {
            throw new AppError("Expense could not be deleted", 500);
        }

        const normalizedDescription = expense[0].description.trim();
        const message = `${normalizedDescription} expense of ₹${Number(expense[0].amount).toFixed(2)} was deleted from the group`;
        let notification;

        if (notificationRecipients.length > 0) {
            
            notification = await createNotificationRepository(connection, groupId, userId, "expense_deleted", message);
            for (const recipient of notificationRecipients) {
                await createNotificationRecipientRepository(connection, notification.id, recipient);
            }
        }

        await connection.commit();

        if (notificationRecipients.length > 0) {
            for (const recipient of notificationRecipients) {
                sendNotification(recipient, {
                    id: notification.id,
                    userId,
                    groupId,
                    expenseId,
                    type: "expense_deleted",
                    message
                });
            }
        }

        return { expenseId };
    } catch (error) {
        if (transactionStarted) {
            await connection.rollback();
        }
        throw error;
    } finally {
        connection.release();
    }
}

export { createExpenseService, getExpensesService, getExpenseByIdService, updateExpenseService, deleteExpenseService };
