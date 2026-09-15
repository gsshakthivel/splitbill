import { findUserByEmail, createUser } from "../repositories/user.repository.js";
import bcrypt from "bcrypt";
import { generateToken } from "../utils/jwt.js";

const registerUser = async (name, email, password) => {
    const existingUser = await findUserByEmail(email);

    if(existingUser === null){
        const passwordHash = await bcrypt.hash(password, 10);
        const result = await createUser(name, email, passwordHash);
        return result;
    }
    return { message: "Email is already registered" };
}

const loginUser = async (email, password) => {
    const existingUser = await findUserByEmail(email);

    if(existingUser === null){
        return { message: "Invalid email or password" };
    }
    const passwordMatch = await bcrypt.compare(password, existingUser.password_hash);
    if(!passwordMatch){
        return { message: "Invalid email or password" };
    }
    return { id: existingUser.id, name: existingUser.name, email: existingUser.email, token: generateToken(existingUser.id) };
}

export { registerUser, loginUser };