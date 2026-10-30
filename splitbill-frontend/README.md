# SplitBill – Flutter Frontend

The Flutter frontend for **SplitBill**, a full-stack expense-sharing application inspired by Splitwise. It allows users to manage groups, track shared expenses, view balances, settle debts, and receive real-time notifications.

The application communicates with a Node.js and Express.js backend through REST APIs and Socket.IO.

## Features

- **Authentication:** User registration, login, and secure token storage.
- **Group Management:** Create groups, view group details, manage members, edit and delete groups.
- **Expense Management:** Add, edit, delete, and view shared expenses.
- **Expense Splitting:** Support for shared expense splits and individual shares.
- **Balance Tracking:** View group balances and overall outstanding amounts.
- **Settlements:** Record payments and view settlement history.
- **Notifications:** Receive real-time notifications and view notification history.
- **Responsive UI:** Flutter-based interface supporting mobile and web platforms.

## Tech Stack

|      Technology        |          Purpose                    |
|         ---            |            ---                      |
| Flutter                | Cross-platform UI development       |
| Dart                   | Application programming language    |
| Riverpod               | State management                    |
| Dio                    | REST API communication              |
| GoRouter               | Application navigation and routing  |
| Flutter Secure Storage | Secure authentication token storage |
| Socket.IO Client       | Real-time communication             |
| intl                   | Date and number formatting          |

## Project Architecture

The frontend follows a **feature-based architecture**, separating data handling from presentation logic.


lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── core/
│   │   ├── errors/
│   │   │   └── api_exception.dart
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   ├── socket/
│   │   │   └── socket_service.dart
│   │   └── storage/
│   │       └── secure_storage_service.dart
│   └── router/
│       └── app_router.dart
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── models/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── notifiers/
    │       ├── providers/
    │       └── screens/
    │
    ├── expenses/
    │   ├── data/
    │   │   ├── models/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── notifiers/
    │       ├── providers/
    │       └── screens/
    │
    ├── groups/
    │   ├── data/
    │   │   ├── models/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── notifiers/
    │       ├── providers/
    │       └── screens/
    │
    ├── home/
    │   ├── data/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── notifiers/
    │       ├── providers/
    │       └── screens/
    │
    ├── notifications/
    │   ├── data/
    │   │   ├── models/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── providers/
    │       └── screens/
    │
    └── settlements/
        ├── data/
        │   ├── models/
        │   └── repositories/
        └── presentation/
            ├── notifiers/
            ├── providers/
            └── screens/

assets/
└── branding/
    ├── app_icon.png
    └── splitbill_splash.png


### Architecture Overview

- **Data Layer:** Contains models and repositories responsible for handling application data and communicating with backend APIs.
- **Presentation Layer:** Contains screens, Riverpod providers, and notifiers responsible for UI and application state.
- **Core Layer:** Contains shared services for API communication, secure storage, socket communication, and error handling.
- **Routing:** GoRouter manages application navigation and route handling.

## State Management

The application uses **Riverpod** for state management.

- Providers expose application state and dependencies.
- Notifiers manage state changes and user actions.
- `ConsumerWidget` and `ConsumerStatefulWidget` allow UI components to react to provider changes.
- Provider invalidation and refresh mechanisms keep relevant data updated after operations.

## API Integration

The application uses **Dio** for communicating with the backend REST API.

The API client provides methods for:

- GET
- POST
- PUT
- PATCH
- DELETE

Authentication tokens are retrieved from secure storage and automatically attached to authenticated requests through a Dio interceptor.

API errors are handled centrally and converted into application-level exceptions.

### Backend Configuration

The frontend currently uses the deployed backend by default:

baseUrl: 'https://splitbill-7uls.onrender.com/api/v1',

For local backend development, update the base URL in:

lib/app/core/network/api_client.dart

For example:

baseUrl: 'http://localhost:5000/api/v1',

Use the appropriate host address when testing on a physical device or emulator. `localhost` on a device refers to that device itself, not your development computer.

## Authentication

- JWT-based authentication.
- Password-based login and registration through the backend.
- Secure token storage using Flutter Secure Storage.
- Automatic token attachment to authenticated API requests.
- Authentication state management using Riverpod.

## Real-Time Communication

The application uses **Socket.IO Client** for real-time notifications.

- WebSocket transport is used for communication.
- Authentication tokens are passed during socket connection.
- Automatic reconnection is enabled.
- Incoming notification events are handled by the notification flow.
- Socket connections are disposed when the associated Riverpod service provider is disposed.

## Getting Started

### Prerequisites

Install the following:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code
- Android emulator or physical device
- Git

Verify your Flutter installation:

flutter doctor

### Clone the Repository

git clone https://github.com/gsshakthivel/splitbill.git

Navigate to the frontend directory:

cd splitbill/splitbill-frontend

### Install Dependencies

flutter pub get

### Run the Application

For the default connected device:

flutter run

To list available devices:

flutter devices

To run on a specific device:

flutter run -d <device-id>

### Run on Web

flutter run -d chrome

The application uses the deployed backend URL by default, so the backend does not need to be running locally when using that configuration.

## Build

### Android APK

flutter build apk --release

### Android App Bundle

flutter build appbundle --release

### Flutter Web

flutter build web --release


## Testing and Code Analysis

Run Flutter static analysis:

flutter analyze

Run automated tests:

flutter test

## Deployment

The Flutter Web application is deployed using **GitHub Pages**.

The project uses GitHub Actions for automated web builds and deployment.

Every push to `feature/sept-26/1` triggers the GitHub Actions workflow. The workflow installs dependencies, runs static analysis and automated tests, builds the Flutter Web application with the `/splitbill/` base path, and deploys it to GitHub Pages.

The backend is deployed separately, and the frontend communicates with it through the configured API and Socket.IO endpoints.

## Related Documentation

- [Full-Stack Project Documentation](../README.md)
- [Backend Documentation](../splitbill-backend/README.md)

## Author

**Shakthivel Swaminathan**

GitHub: [gsshakthivel](https://github.com/gsshakthivel)

Repository: [SplitBill](https://github.com/gsshakthivel/splitbill)