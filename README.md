# SplitBill

**A full-stack expense-sharing application inspired by Splitwise.**

SplitBill helps users manage shared expenses, track group balances, record settlements, and receive real-time notifications.

This portfolio project demonstrates full-stack development using Flutter, Node.js, Express.js, MySQL, and Socket.IO. It focuses on practical backend concepts such as REST API design, JWT authentication, authorization, relational database design, transactions, and real-time communication.

> **Note:** SplitBill is a portfolio project and is not intended for production financial use.

## Features

- User registration and login with JWT authentication
- Secure password hashing using bcrypt
- Create, update, and delete expense-sharing groups
- Add and remove group members
- Create, update, and delete expenses
- Equal expense splitting
- Group balance calculation
- Partial and complete settlements
- Settlement history
- In-app notification history
- Real-time notifications using Socket.IO
- Group owner-based permissions
- Persistent authentication
- Responsive Flutter interface
- API validation and centralized error handling

## Screenshots

<!-- Add application screenshots here when ready. -->

## Tech Stack

|         Layer           |          Technologies             |
|          ---            |              ---                  |
| Frontend                | Flutter, Dart                     |
| State Management        | Riverpod                          |
| Navigation              | GoRouter                          |
| HTTP Client             | Dio                               |
| Backend                 | Node.js, Express.js               |
| Database                | MySQL                             |
| Database Client         | mysql2                            |
| Authentication          | JWT, bcrypt                       |
| Real-time Communication | Socket.IO                         |
| API Documentation       | OpenAPI 3.0, Swagger UI           |
| Testing                 | Jest, Supertest                   |
| Security                | Helmet, CORS, express-rate-limit  |
| Logging                 | Pino                              |
| Containerization        | Docker, Docker Compose            |
| Deployment              | Render, Aiven MySQL, GitHub Pages |
| CI/CD                   | GitHub Actions                    |

## Architecture

SplitBill uses a Flutter client that communicates with a Node.js REST API. MySQL stores application data, while Socket.IO delivers real-time notifications to connected users.

                  Flutter Application
                         |
                  Riverpod / Dio
                         |
                    REST API
                         |
                  Node.js / Express
                         |
             Routes → Controllers
                         |
                      Services
                         |
                    Repositories
                         |
                       MySQL

                  Socket.IO
                       |
              Real-time Notifications
                       |
                 Flutter Client

### Frontend

The Flutter application is organized by feature and separates data access, state management, and presentation.

- **Riverpod:** Application state management.
- **Dio:** HTTP requests and API integration.
- **GoRouter:** Application navigation and authentication redirects.
- **Flutter Secure Storage:** Secure storage of authentication tokens.
- **Socket.IO Client:** Real-time notification handling.

### Backend

The backend follows a layered architecture:

- **Routes:** Define API endpoints.
- **Controllers:** Handle HTTP requests and responses.
- **Services:** Implement business logic, validation, authorization, and transactions.
- **Repositories:** Handle SQL queries and database operations.
- **Middleware:** Handle authentication and centralized errors.
- **Socket:** Manage authenticated Socket.IO connections and notification delivery.

### Database

MySQL is used as the relational database. The main entities include:

- Users
- Groups
- Group members
- Expenses
- Expense splits
- Settlements
- Notifications
- Notification recipients

Balances are calculated at runtime rather than stored as separate balance records.

## Real-Time Notifications

Socket.IO is used to deliver notifications to authenticated users.

The backend persists notifications in MySQL before emitting them through Socket.IO. Authenticated connections join user-specific rooms, allowing notifications to be delivered to the intended users.

This keeps the database as the source of truth while providing real-time updates to connected clients.

## Repository Structure

splitbill/
│
├── splitbill-frontend/
│   ├── lib/
│   ├── assets/
│   ├── test/
│   └── README.md
│
├── splitbill-backend/
│   ├── database/
│   ├── docs/
│   ├── src/
│   ├── tests/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── README.md
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
└── README.md

## Getting Started

You can run the frontend and backend independently during local development.

### Prerequisites

Install the following:

- Git
- Flutter SDK
- Dart SDK
- Node.js and npm
- MySQL

Docker Desktop is optional if you prefer running the backend and database using Docker Compose.

### 1. Clone the Repository

git clone https://github.com/gsshakthivel/splitbill.git
cd splitbill

### 2. Set Up the Backend

cd splitbill-backend
npm install

Create a MySQL database and configure the backend environment variables.

DB_HOST=localhost
DB_PORT=3306
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=splitbill

DB_SSL=false
DB_SSL_CA=./certs/ca.pem

JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=1d

PORT=5000

Execute the database schema:

database/schema.sql

Start the backend:

npm start

The API will be available at:

http://localhost:5000

Swagger documentation:

http://localhost:5000/api-docs

Health check:

http://localhost:5000/health

### 3. Set Up the Frontend

Open another terminal:

cd splitbill-frontend
flutter pub get
flutter run

For Flutter Web:

flutter run -d chrome

The frontend API configuration is maintained in the API client. Update its base URL when connecting to a locally running backend.

For a physical Android device, use the development machine's reachable local network address instead of `localhost`.

## Running with Docker

The backend includes Docker and Docker Compose configuration for running the Node.js API and MySQL database together.

From the backend directory:

docker compose up --build

Stop the containers:

docker compose down

Refer to the backend README for Docker configuration and database details.

## Testing

### Backend

cd splitbill-backend
npm test

The backend test suite uses Jest and Supertest.

### Frontend

cd splitbill-frontend
flutter analyze
flutter test

## Deployment

The project uses separate deployment workflows for the frontend and backend.

|  Component     |    Hosting   |
|   ---          |     ---      |
| Flutter Web    | GitHub Pages |
| Backend API    | Render       |
| MySQL Database | Aiven        |

**Production API:**  
https://splitbill-7uls.onrender.com

**API Base URL:**  
https://splitbill-7uls.onrender.com/api/v1

The Flutter Web application is built and deployed to GitHub Pages through GitHub Actions. The backend is containerized with Docker and deployed to Render, using Aiven MySQL with TLS enabled.

## Detailed Documentation

For implementation details, setup instructions, and technical documentation, refer to:

- [Frontend Documentation](./splitbill-frontend/README.md)
- [Backend Documentation](./splitbill-backend/README.md)

## Future Improvements

- Additional expense split types, such as percentage-based and custom splits
- More integration and end-to-end tests
- Improved application monitoring and observability
- Further performance and scalability improvements

## Author

**Shakthivel Swaminathan**

GitHub: [@gsshakthivel](https://github.com/gsshakthivel)


*Built as a hands-on full-stack portfolio project to demonstrate application development, backend engineering, database design, and real-time communication.*
