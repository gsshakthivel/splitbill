import { jest } from "@jest/globals";

jest.unstable_mockModule("bcrypt", () => ({
    default: {
        hash: jest.fn(),
        compare: jest.fn()
    }
}));

jest.unstable_mockModule("../src/repositories/user.repository.js", () => ({
    findUserByEmail: jest.fn(),
    createUser: jest.fn()
})); 

jest.unstable_mockModule("../src/utils/jwt.js", () => ({
    generateToken: jest.fn()
}));

const { registerUser, loginUser } = await import("../src/services/auth.service.js");

beforeEach(() => {
    jest.clearAllMocks();
});

const { findUserByEmail, createUser } = await import("../src/repositories/user.repository.js");
const { default: bcrypt } = await import("bcrypt");
const { generateToken } = await import("../src/utils/jwt.js");

test("registerUser should create a new user", async () => {
    findUserByEmail.mockResolvedValue(null);

    bcrypt.hash.mockResolvedValue("hashed-password");

    createUser.mockResolvedValue({
        id: 1,
        name: "Shakthivel",
        email: "test@example.com"
    });

    const result = await registerUser(
        "Shakthivel",
        "test@example.com",
        "password123"
    ); 
    
    expect(result).toEqual({
        id: 1,
        name: "Shakthivel",
        email: "test@example.com"
    }); 
    
    expect(createUser).toHaveBeenCalledWith(
        "Shakthivel",
        "test@example.com",
        expect.any(String)
    );
});

test("registerUser should reject an already registered email", async () => {
    findUserByEmail.mockResolvedValue({
        id: 1,
        name: "Shakthivel",
        email: "test@example.com"
    });
    
    await expect(
        registerUser(
            "Shakthivel",
            "test@example.com",
            "password123"
        )
    ).rejects.toMatchObject({
        statusCode: 409,
        message: "Email is already registered"
    });
        
    expect(findUserByEmail).toHaveBeenCalledWith("test@example.com");
    expect(createUser).not.toHaveBeenCalled();
});

test("loginUser should return a token for valid credentials", async () => {
    findUserByEmail.mockResolvedValue({
        id: 1,
        name: "Shakthivel",
        email: "test@example.com",
        password_hash: "hashed-password"
    });

    bcrypt.compare.mockResolvedValue(true);

    generateToken.mockReturnValue("token");

    const result = await loginUser(
        "test@example.com",
        "password123"
    );

    expect(result).toEqual({
        id: 1,
        name: "Shakthivel",
        email: "test@example.com",
        token: "token"
    });

    expect(findUserByEmail).toHaveBeenCalledWith("test@example.com");

    expect(bcrypt.compare).toHaveBeenCalledWith(
        "password123",
        "hashed-password"
    );

    expect(generateToken).toHaveBeenCalledWith(1);
});

test("loginUser should reject an unknown email", async () => {
    findUserByEmail.mockResolvedValue(null);

    await expect(
    loginUser("test@example.com", "password123")
    ).rejects.toMatchObject({
        statusCode: 401,
        message: "Invalid email or password"
    });

    expect(findUserByEmail).toHaveBeenCalledWith("test@example.com");

    expect(bcrypt.compare).not.toHaveBeenCalled();

    expect(generateToken).not.toHaveBeenCalled();
});

test("loginUser should reject an incorrect password", async () => {
    findUserByEmail.mockResolvedValue({
        id: 1,
        name: "Shakthivel",
        email: "test@example.com",
        password_hash: "hashed-password"
    });

    bcrypt.compare.mockResolvedValue(false);

    await expect(
    loginUser("test@example.com", "wrong-password")
    ).rejects.toMatchObject({
        statusCode: 401,
        message: "Invalid email or password"
    });

    expect(bcrypt.compare).toHaveBeenCalledWith(
        "wrong-password",
        "hashed-password"
    );

    expect(generateToken).not.toHaveBeenCalled();
});