import { Router } from "express";
import rateLimit from "express-rate-limit";
import authenticate from "../middleware/auth.middleware.js";
import { getUserProfile, register, login } from "../controllers/auth.controller.js";

const router = Router();

const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    limit: 20, // limit each IP to 20 requests per windowMs
    message: { message: "Too many authentication attempts. Please try again later." }
});

router.get("/profile", authenticate, getUserProfile);

router.post("/register", authLimiter, register);

router.post("/login", authLimiter, login);


export default router;