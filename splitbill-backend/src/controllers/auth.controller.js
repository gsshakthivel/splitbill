import { registerUser, loginUser } from "../services/auth.service.js";
import AppError from "../utils/errors.js";

const register = async (req, res) => {
    const { name, email, password } = req.body;

    if (typeof name !== "string" || name.trim().length === 0) {
        throw new AppError("Name is required", 400);
    }

    if (typeof email !== "string" || email.trim().length === 0) {
        throw new AppError("Email is required", 400);
    }

    if (typeof password !== "string" || password.length < 8) {
       throw new AppError("Password must be at least 8 characters", 400);
    }
    
    const result = await registerUser(
        name.trim(),
        email.trim().toLowerCase(), 
        password
    );

    res.status(201).json(result);
};

const login = async (req, res) => {
    const { email, password } = req.body;
    
    const result = await loginUser(email, password);
    
    res.status(200).json(result);
};

export { register, login };