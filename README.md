# SplitBill

SplitBill is a portfolio expense-sharing application inspired by expense-sharing platforms such as Splitwise.

The project is built to demonstrate practical backend development skills, including REST API design, authentication, relational database design, authorization, database transactions, real-time communication, automated testing, and Docker-based application setup.

> **Note:** SplitBill is a portfolio project and is not intended for production financial use.

## Key Features

* User registration and login
* JWT-based authentication
* Password hashing with bcrypt
* Group creation and member management
* Expense creation, updating, and deletion
* Equal expense splitting
* Runtime balance calculation
* Partial and complete settlements
* Notification system
* Real-time notifications using Socket.IO
* Group owner permissions
* Input validation and centralized error handling
* Authentication rate limiting
* Security headers with Helmet
* Automated unit and API testing
* Dockerized Node.js API and MySQL database


## Tech Stack

### Backend

* **Node.js** — JavaScript runtime
* **Express.js** — REST API framework
* **MySQL** — Relational database
* **mysql2** — MySQL client with Promise support
* **JWT** — Authentication
* **bcrypt** — Password hashing
* **Socket.IO** — Real-time communication

### Testing

* **Jest** — Unit testing
* **Supertest** — HTTP/API testing

### Security

* **Helmet** — Security-related HTTP headers
* **CORS** — Cross-origin request handling
* **express-rate-limit** — Authentication rate limiting

### DevOps

* **Docker** — Containerization
* **Docker Compose** — Multi-container application setup

### Development

* **Git / GitHub** — Version control and source code hosting
* **Raw SQL** — Database queries without an ORM

---

## Architecture

SplitBill follows a layered backend architecture:


Client
  │
  ▼
Routes
  │
  ▼
Controllers
  │
  ▼
Services
  │
  ▼
Repositories
  │
  ▼
MySQL


### Layer Responsibilities

**Routes**

Define API endpoints and connect HTTP requests to controllers.

**Controllers**

Handle HTTP-specific concerns such as request parameters, request validation, and response status codes.

**Services**

Contain the application's business logic, authorization rules, validations, and transaction-related operations.

**Repositories**

Handle database operations and SQL queries.

**MySQL**

Stores users, groups, members, expenses, expense splits, settlements, notifications, and notification recipients.

### Real-Time Notification Flow


Business Service
      │
      ▼
MySQL Transaction
      │
      ▼
COMMIT
      │
      ▼
Socket.IO
      │
      ▼
Connected Client


Database persistence happens before the Socket.IO notification is emitted. This prevents a real-time notification from being sent for a database operation that ultimately fails or is rolled back.


## Project Structure


splitbill-backend/
│
├── database/
│   └── schema.sql
│
├── src/
│   ├── config/
│   │   └── db.js
│   │
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── expense.controller.js
│   │   ├── group.controller.js
│   │   ├── notifications.controller.js
│   │   └── settlement.controller.js
│   │
│   ├── middleware/
│   │   ├── auth.middleware.js
│   │   └── error.middleware.js
│   │
│   ├── repositories/
│   │   ├── expense.repository.js
│   │   ├── group.repository.js
│   │   ├── notifications.repository.js
│   │   ├── settlement.repository.js
│   │   └── user.repository.js
│   │
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── expense.routes.js
│   │   ├── group.routes.js
│   │   ├── notifications.routes.js
│   │   └── settlement.routes.js
│   │
│   ├── services/
│   │   ├── auth.service.js
│   │   ├── expense.service.js
│   │   ├── group.service.js
│   │   ├── notifications.service.js
│   │   └── settlement.service.js
│   │
│   ├── socket/
│   │   ├── notification.socket.js
│   │   ├── socket.js
│   │   └── socket.manager.js
│   │
│   ├── utils/
│   │   ├── errors.js
│   │   └── jwt.js
│   │
│   ├── app.js
│   └── server.js
│
├── tests/
│   ├── app.test.js
│   ├── auth.service.test.js
│   ├── expense.service.test.js
│   ├── group.service.test.js
│   ├── jwt.test.js
│   ├── notification.service.test.js
│   ├── settlement.service.test.js
│   └── socket.test.js
│
├── .dockerignore
├── .env.example
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── package.json
├── package-lock.json
└── README.md


### Directory Responsibilities

| Directory       | Purpose                                                      |
| --------------- | ------------------------------------------------------------ |
| `controllers/`  | Handles HTTP requests and responses                          |
| `services/`     | Contains business logic and authorization rules              |
| `repositories/` | Contains MySQL queries and database operations               |
| `routes/`       | Defines API endpoints                                        |
| `middleware/`   | Authentication and centralized error handling                |
| `socket/`       | Socket.IO setup and real-time notification delivery          |
| `utils/`        | Shared utilities such as JWT handling and application errors |
| `config/`       | Database configuration                                       |
| `database/`     | Database schema and initialization SQL                       |
| `tests/`        | Jest unit tests and Supertest API tests                      |


## Database Design

SplitBill uses **MySQL** as its relational database.

The database is designed around the core entities involved in expense sharing and follows a normalized relational structure.

### Main Tables

| Table                     | Purpose                                                           |
| ------------------------- | ----------------------------------------------------------------- |
| `users`                   | Stores user accounts and authentication information               |
| `` `groups` ``            | Stores expense-sharing groups                                     |
| `group_members`           | Represents the many-to-many relationship between users and groups |
| `expenses`                | Stores expenses created within groups                             |
| `expense_splits`          | Stores each user's share of an expense                            |
| `settlements`             | Stores payments made between group members                        |
| `notifications`           | Stores notification events                                        |
| `notification_recipients` | Tracks notification recipients and their read status              |

> **Note:** The `` `groups` `` table is referenced using backticks in SQL because `GROUPS` is a MySQL reserved keyword.

### Relationships


users
  │
  ├───────────────┐
  │               │
  ▼               ▼
`groups`      group_members
  │               │
  │               └── users
  │
  ├── expenses
  │      │
  │      └── expense_splits
  │
  ├── settlements
  │
  └── notifications
           │
           └── notification_recipients


### Database Design Decisions

* `group_members` is used to represent the many-to-many relationship between users and `` `groups` ``.
* Expense splits are stored separately from `expenses` because one expense can involve multiple users.
* Balances are calculated at runtime instead of being stored as a separate balance value.
* Foreign keys maintain relationships between related records.
* Unique constraints prevent duplicate data where required.
* `CHECK` constraints validate values such as positive expense and settlement amounts.
* Composite primary keys are used where the combination of columns uniquely identifies a relationship.
* Indexes are added to frequently queried columns to improve database query performance.
* Database transactions are used for operations that require multiple related database changes to succeed or fail together.

### Balance Calculation

A user's group balance is calculated using:

Balance = Total Paid - Total Owed - Total Received + Settlement Paid

Where:

- **Positive balance** → the user should receive money.
- **Negative balance** → the user owes money.
- **Zero balance** → the user's payments and obligations are settled.


## Authentication & Security

SplitBill uses **JWT-based authentication** to secure protected API endpoints.

### Authentication Flow


Register
   │
   ▼
Validate Input
   │
   ▼
Hash Password with bcrypt
   │
   ▼
Store User


Login
   │
   ▼
Find User
   │
   ▼
Compare Password with bcrypt
   │
   ▼
Generate JWT
   │
   ▼
Client

For protected requests:

Client
  │
  │ Authorization: Bearer <token>
  ▼
Authentication Middleware
  │
  ▼
Verify JWT
  │
  ▼
Attach User ID to Request
  │
  ▼
Controller / Service

### Security Measures

* Passwords are hashed using `bcrypt` before being stored in the database.
* JWTs are used to authenticate protected API requests.
* JWT secrets and database credentials are stored in environment variables.
* `.env` is excluded from version control.
* `.env.example` is provided as a configuration template.
* Authentication endpoints use rate limiting to reduce repeated authentication attempts.
* `Helmet` is used to set security-related HTTP headers.
* Request body size is limited to reduce unnecessarily large JSON payloads.
* Input validation is performed at the controller and service layers.
* Authorization rules are enforced in the service layer.
* A centralized error-handling middleware manages application errors.
* Unexpected server errors return a generic error message instead of exposing internal implementation details.
* Database queries use parameterized values to avoid SQL injection through user-provided input.
* Database transactions are used for operations that modify multiple related records.

### Environment Variables

Sensitive configuration is provided through environment variables instead of being hard-coded into the application.

Example:

DB_HOST=localhost
DB_PORT=3306
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=splitbill

JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=1d

PORT=5000

The actual `.env` file is kept local and is not committed to GitHub.


## Real-Time Notifications

SplitBill uses **Socket.IO** to deliver real-time notifications to connected users.

The database remains the source of truth for notifications, while Socket.IO acts as the real-time delivery layer.

### Notification Flow

id="5y8z0m"
Business Service
      │
      ▼
MySQL Transaction
      │
      ├── Create notification
      ├── Create notification recipients
      │
      ▼
COMMIT
      │
      ▼
Socket.IO
      │
      ▼
User-specific Socket Room
      │
      ▼
Connected Client


Socket notifications are emitted **only after the database transaction is successfully committed**.

This ensures that a real-time notification is not delivered for a database operation that later fails or is rolled back.

### User-Specific Rooms

When a client connects through Socket.IO, the JWT is verified during the socket authentication process.

After successful authentication, the socket joins a user-specific room:

id="v6ib4h"
user:<userId>


For example:

id="4rj2qf"
user:15


Notifications can then be delivered only to the intended user room.

### Supported Notification Events

The application currently supports notifications for events such as:

* `expense_created`
* `expense_updated`
* `expense_participant_added`
* `expense_participant_removed`
* `expense_deleted`
* `settlement_created`
* `member_added`
* `member_removed`

### Notification Persistence

Notifications are persisted in MySQL before being delivered through Socket.IO.

The notification system provides APIs for:

GET   /api/v1/notifications
GET   /api/v1/notifications/unread-count
PATCH /api/v1/notifications/:notificationId/read

This allows notifications to remain available even when a user is not connected through Socket.IO.


## Production Reliability

- Structured application logging using Pino.
- Graceful shutdown handling for the HTTP server, Socket.IO, and MySQL connection pool.
- Environment-based configuration for local and production environments.
- Centralized error handling for unexpected application errors.


## API Endpoints

The SplitBill backend exposes RESTful API endpoints under the `/api/v1` prefix.

### Authentication

| Method | Endpoint                | Description                          | Auth |
| ------ | ----------------------- | ------------------------------------ | ---- |
| `POST` | `/api/v1/auth/register` | Register a new user                  | No   |
| `POST` | `/api/v1/auth/login`    | Authenticate a user and return a JWT | No   |

### Groups

| Method   | Endpoint                                  | Description                           | Auth |
| -------- | ----------------------------------------- | ------------------------------------- | ---- |
| `POST`   | `/api/v1/groups`                          | Create a group                        | JWT  |
| `GET`    | `/api/v1/groups`                          | Get groups for the authenticated user | JWT  |
| `GET`    | `/api/v1/groups/:groupId`                 | Get group details                     | JWT  |
| `POST`   | `/api/v1/groups/:groupId/members`         | Add a member to a group               | JWT  |
| `DELETE` | `/api/v1/groups/:groupId/members/:userId` | Remove a member from a group          | JWT  |

### Expenses

| Method   | Endpoint                                      | Description              | Auth |
| -------- | --------------------------------------------- | ------------------------ | ---- |
| `POST`   | `/api/v1/groups/:groupId/expenses`            | Create an expense        | JWT  |
| `GET`    | `/api/v1/groups/:groupId/expenses`            | Get expenses for a group | JWT  |
| `GET`    | `/api/v1/groups/:groupId/expenses/:expenseId` | Get expense details      | JWT  |
| `PUT`    | `/api/v1/groups/:groupId/expenses/:expenseId` | Update an expense        | JWT  |
| `DELETE` | `/api/v1/groups/:groupId/expenses/:expenseId` | Delete an expense        | JWT  |

### Balances

| Method | Endpoint                           | Description                      | Auth |
| ------ | ---------------------------------- | -------------------------------- | ---- |
| `GET`  | `/api/v1/groups/:groupId/balances` | Calculate current group balances | JWT  |

### Settlements

| Method | Endpoint                              | Description            | Auth |
| ------ | ------------------------------------- | ---------------------- | ---- |
| `POST` | `/api/v1/groups/:groupId/settlements` | Create a settlement    | JWT  |
| `GET`  | `/api/v1/groups/:groupId/settlements` | Get settlement history | JWT  |

### Notifications

| Method  | Endpoint                                     | Description                                  | Auth |
| ------- | -------------------------------------------- | -------------------------------------------- | ---- |
| `GET`   | `/api/v1/notifications`                      | Get notifications for the authenticated user | JWT  |
| `GET`   | `/api/v1/notifications/unread-count`         | Get unread notification count                | JWT  |
| `PATCH` | `/api/v1/notifications/:notificationId/read` | Mark a notification as read                  | JWT  |

### Health Check

| Method | Endpoint  | Description                      | Auth |
| ------ | --------- | -------------------------------- | ---- |
| `GET`  | `/health` | Check whether the API is running | No   |

Protected endpoints require a JWT in the request header:
Authorization: Bearer <token>


## Testing

SplitBill uses **Jest** for unit testing and **Supertest** for HTTP/API testing.

### Test Coverage Areas

The test suite covers important application behavior including:

* Authentication service
* JWT token generation and verification
* Group service
* Expense service
* Settlement service
* Notification service
* Socket.IO authentication and connection handling
* API health check
* API request validation

### Test Structure

id="6zq7ca"
tests/
├── app.test.js
├── auth.service.test.js
├── expense.service.test.js
├── group.service.test.js
├── jwt.test.js
├── notification.service.test.js
├── settlement.service.test.js
└── socket.test.js


### Running Tests

Install dependencies:

npm install

Run the test suite:

npm test

The current test suite contains **41 tests across 8 test suites**.

### Testing Approach

Service-level tests use mocked repositories and dependencies where appropriate, allowing business logic to be tested independently from the database.

API tests use **Supertest** to send HTTP requests to the Express application and verify responses such as status codes and validation behavior.


## Local Setup

### Prerequisites

Make sure the following are installed:

* Node.js
* npm
* MySQL

### 1. Clone the Repository

git clone https://github.com/gsshakthivel/splitbill.git
cd splitbill/splitbill-backend

### 2. Install Dependencies

npm install

### 3. Create the Database

Create a MySQL database named:

CREATE DATABASE splitbill;

Then execute the schema:
database/schema.sql

This creates the required tables, relationships, constraints, and indexes.

### 4. Configure Environment Variables

Create a `.env` file in the project root:

DB_HOST=localhost
DB_PORT=3306
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=splitbill

JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=1d

PORT=5000

### 5. Start the Server

npm start

The API will be available at:
http://localhost:5000

### 6. Verify the API

Open:
http://localhost:5000/health

A successful response should look like:

{
  "status": "ok",
  "message": "SplitBill API is running"
}


## Docker Setup

SplitBill can be run as a multi-container application using Docker Compose.

The Docker setup runs:

* **Node.js + Express API** in one container
* **MySQL** in a separate container

### Prerequisites

Install:

* Docker Desktop
* Docker Compose

### Start the Application

From the project root:

docker compose up --build

This builds the API image and starts both the API and MySQL services.

The API will be available at:

http://localhost:5000

### Verify Running Containers
docker compose ps

The API and MySQL containers should be running.

### Stop the Application

docker compose down

This stops and removes the containers while preserving the MySQL data stored in the Docker volume.

### Reset the Database

To remove the containers **and** the persisted MySQL volume:

docker compose down -v

> **Warning:** `docker compose down -v` removes the MySQL Docker volume and therefore deletes the database data stored in that volume.

### Database Initialization

The Docker MySQL service uses:

database/schema.sql

as an initialization script.

When a new MySQL data volume is created, the schema is automatically executed and the required database tables are created.

### Docker Architecture

Host Machine
     │
     │ localhost:5000
     ▼
┌─────────────────────────────┐
│         Docker              │
│                             │
│  ┌──────────────────────┐   │
│  │    splitbill-api     │   │
│  │ Node.js + Express    │   │
│  └──────────┬───────────┘   │
│             │               │
│       Docker Network        │
│             │               │
│  ┌──────────▼───────────┐   │
│  │   splitbill-mysql    │   │
│  │       MySQL          │   │
│  └──────────────────────┘   │
│             │               │
│       mysql_data volume     │
└─────────────────────────────┘

The API connects to MySQL using the Docker Compose service name:

DB_HOST=mysql

The MySQL container does not need to expose port `3306` to the host machine because the API communicates with it through the internal Docker network.

### Docker Healthcheck

The MySQL service includes a healthcheck. The API depends on MySQL being healthy before starting:

depends_on:
  mysql:
    condition: service_healthy

This helps prevent the API from starting before MySQL is ready to accept connections.


## Environment Variables

SplitBill uses environment variables for database configuration, JWT authentication, and server configuration.

Create a `.env` file in the project root and configure the following variables:

DB_HOST=localhost
DB_PORT=3306
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=splitbill

JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=1d

PORT=5000

### Variable Description

| Variable         | Description                         |
| ---------------- | ----------------------------------- |
| `DB_HOST`        | MySQL server hostname               |
| `DB_PORT`        | MySQL server port                   |
| `DB_USER`        | MySQL username                      |
| `DB_PASSWORD`    | MySQL password                      |
| `DB_NAME`        | MySQL database name                 |
| `JWT_SECRET`     | Secret used to sign and verify JWTs |
| `JWT_EXPIRES_IN` | JWT expiration duration             |
| `PORT`           | Port on which the API server runs   |

An `.env.example` file is included in the repository as a configuration template.

The actual `.env` file contains environment-specific values and secrets, so it is excluded from Git version control.


## Deployment

The backend is deployed using Docker.

- **Application hosting:** Render
- **Database:** Aiven MySQL
- **Containerization:** Docker
- **Production configuration:** Render environment variables
- **Database connection:** TLS/SSL enabled for the production MySQL connection
- **Health check:** `/health`

The same codebase is used for local and production environments. Local development uses a `.env` file, while production configuration is provided through the deployment platform.


## Future Improvements

The following features may be considered for future versions of SplitBill:

* Support for additional expense split types such as percentage-based and custom splits.
* Flutter client application integration with the backend API and Socket.IO notifications.
* Improved API documentation using OpenAPI/Swagger.
* Automated CI/CD workflows using GitHub Actions.
* Additional integration and end-to-end tests.
* Application monitoring and centralized log aggregation.