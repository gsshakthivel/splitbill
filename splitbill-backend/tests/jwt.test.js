import { generateToken, verifyToken } from "../src/utils/jwt.js";

test("generateToken should return a token", () => {
    const token = generateToken(1);

    expect(token).toBeDefined();
});

test("verifyToken should return the payload", () => {
    const token = generateToken(1);
    const payload = verifyToken(token);

    expect(payload).toBeDefined();
    expect(payload.id).toBe(1);
});

test("verifyToken should throw an error if the token is invalid", () => {
    const token = "invalid";

    expect(() => verifyToken(token)).toThrow();
});