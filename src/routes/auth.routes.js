import { Router } from "express";
import { register, login } from "../controllers/auth.controller.js";
import rateLimit from "express-rate-limit";

const router = Router();

const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    limit: 20, // limit each IP to 20 requests per windowMs
    message: { message: "Too many authentication attempts. Please try again later." }
});

router.post("/register", authLimiter, register);

router.post("/login", authLimiter, login);

export default router;