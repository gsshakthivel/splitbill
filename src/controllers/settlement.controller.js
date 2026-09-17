import { createSettlementService, getUserSettlementsService } from "../services/settlement.service.js";
import AppError from "../utils/errors.js";

const createSettlement = async (req, res) => {
    const { groupId } = req.params;
    const { id } = req.user;
    const { toUserId, amount } = req.body;

    const groupIdNumber = Number(groupId);
    const toUserIdNumber = Number(toUserId);

    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    if (!Number.isInteger(toUserIdNumber) || toUserIdNumber <= 0) {
        throw new AppError("Invalid toUserId", 400);
    }

    if (typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0 || !Number.isInteger(amount * 100)) {
        throw new AppError("Invalid amount", 400);
    }   
    
    const result = await createSettlementService(groupIdNumber, toUserIdNumber, amount, id);
    res.status(201).json({ "message": "Settlement created successfully", "data": result });
}

const getUserSettlements = async (req, res) => {
    const { groupId } = req.params;
    const { id } = req.user;

    const groupIdNumber = Number(groupId);
    if (!Number.isInteger(groupIdNumber) || groupIdNumber <= 0) {
        throw new AppError("Invalid groupId", 400);
    }

    const result = await getUserSettlementsService(groupIdNumber, id);
    res.status(200).json({ "message": "Settlements fetched successfully", "data": result });
}

export { createSettlement, getUserSettlements };
