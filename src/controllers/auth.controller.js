import { registerUser, loginUser } from "../services/auth.service.js";

const register = async (req, res) => {
    const { name, email, password } = req.body;
    
    const result = await registerUser(name, email, password);

    res.status(201).json(result);
};

const login = async (req, res) => {
    const { email, password } = req.body;
    
    const result = await loginUser(email, password);
    
    res.status(200).json(result);
};

export { register, login };