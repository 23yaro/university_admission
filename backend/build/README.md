# University Admission Backend Service

This is the backend service for the University Admission system, built with Dart Frog and PostgreSQL.

## Prerequisites

- Dart SDK (>=3.0.0)
- PostgreSQL (>=12.0)
- Dart Frog CLI

## Setup

1. Install dependencies:
```bash
dart pub get
```

2. Set up PostgreSQL:
   - Create a new database named `university_admission`
   - Update the database connection settings in `lib/config/database.dart` if needed

3. Generate JSON serialization code:
```bash
dart run build_runner build
```

## Running the Server

To start the development server:
```bash
dart_frog dev
```

The server will start on `http://localhost:8080` by default.

## API Endpoints

### Authentication

- `POST /auth/register` - Register a new user
  - Body: `{ "email": "string", "password": "string", "role": "applicant" | "admin" }`

- `POST /auth/login` - Login user
  - Body: `{ "email": "string", "password": "string" }`

### Applications

- `POST /applications/submit` - Submit a new application
  - Requires authentication
  - Form data with files and application details

- `GET /applications` - List all applications (admin only)
  - Requires admin authentication

## File Storage

Uploaded files are stored in the `uploads` directory. Make sure this directory is writable by the application.

## Security

- All endpoints except `/auth/*` require JWT authentication
- Passwords are hashed using BCrypt
- File uploads are validated and stored with unique names
- Admin-only endpoints are protected by role-based access control 