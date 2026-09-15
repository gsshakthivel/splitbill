import { Router } from "express";
import { createGroup, getGroups, addGroupMember, getGroupDetails } from "../controllers/group.controller.js";
import authenticate from "../middleware/auth.middleware.js";

const router = Router();

router.post("/", authenticate, createGroup);

router.get("/", authenticate, getGroups);

router.post("/:groupId/members", authenticate, addGroupMember);

router.get("/:groupId", authenticate, getGroupDetails);

export default router;