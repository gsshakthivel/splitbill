import { findUserByEmail, createUser } from "../repositories/user.repository.js";
import bcrypt from "bcrypt";
import { generateToken } from "../utils/jwt.js";
import AppError from "../utils/errors.js";

const registerUser = async (name, email, password) => {
    const existingUser = await findUserByEmail(email);

    if (existingUser !== null) {
        throw new AppError("Email is already registered", 409);
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const result = await createUser(name, email, passwordHash);

    return result;
};

const loginUser = async (email, password) => {
    const existingUser = await findUserByEmail(email);

    if (existingUser === null) {
        throw new AppError("Invalid email or password", 401);
    }

    const passwordMatch = await bcrypt.compare(
        password,
        existingUser.password_hash
    );

    if (!passwordMatch) {
        throw new AppError("Invalid email or password", 401);
    }

    return {
        id: existingUser.id,
        name: existingUser.name,
        email: existingUser.email,
        token: generateToken(existingUser.id)
    };
};

export { registerUser, loginUser };