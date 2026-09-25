import request from "supertest";
import app from "../src/app.js";

test("GET /health should return 200", async () => {
    const response = await request(app)
        .get("/health");

    expect(response.statusCode).toBe(200);
});

test("POST /api/v1/auth/register should reject missing fields", async () => {
    const response = await request(app)
        .post("/api/v1/auth/register")
        .send({});

    expect(response.statusCode).toBe(400);
});