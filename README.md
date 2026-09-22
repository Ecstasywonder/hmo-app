# HMO App — Healthcare Insurance Platform

**Full-stack healthcare insurance comparison platform demonstrating mobile application engineering, REST APIs, relational data and security controls.**

## Engineering highlights

- Flutter / Dart mobile client
- Node.js + Express REST API
- MySQL with Sequelize
- Database migrations and seeders
- JWT access and refresh tokens
- Email verification
- Optional two-factor authentication
- Helmet security headers
- Rate limiting
- CORS controls
- bcrypt password hashing
- Request validation
- Administrative workflows
- Standardized API error handling

## Product workflows

### Member experience

- HMO listing and comparison
- Hospital and doctor discovery
- Appointment booking and rescheduling
- User profile management
- Claims and health-record workflows

### Administration

- Dashboard and system statistics
- User management
- Hospital management
- Appointment management
- Claims management
- System configuration

## Architecture

Flutter / Dart → Node.js + Express REST API → MySQL

The API layer owns authentication, authorization, validation, security middleware, appointment workflows, hospital workflows and administrative workflows. Sequelize provides the relational model, migrations and seed data.

## Local development

Requirements: Node.js 14+, MySQL 8+, Flutter SDK 3+, npm or yarn.

Create a local database:

    CREATE DATABASE hmo_app;

Configure `backend/.env` from `backend/.env.example`, then:

    cd backend
    npm install
    npx sequelize-cli db:migrate
    npx sequelize-cli db:seed:all
    npm run dev

In another terminal:

    cd frontend
    flutter pub get
    flutter run

## API surface

Representative endpoints include `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh-token`, `GET /api/auth/me`, `GET /api/appointments`, `POST /api/appointments`, `GET /api/hospitals`, `GET /api/hospitals/:id/doctors`, `GET /api/admin/dashboard`, `GET /api/admin/users` and `GET /api/admin/claims`.

## Security and data handling

The application includes authentication, authorization, password hashing, validation, rate limiting, HTTP security headers, CORS controls, email verification and optional 2FA.

**Do not use real patient, health or financial information in development.**

This repository is a portfolio project and is not presented as a production healthcare system.

## Portfolio focus

**Mobile client → REST API → relational database → migrations → authentication → security controls → administrative workflows**

---

**Chinwendu Onyeani**  
Software / DevOps Engineer  
GitHub: https://github.com/Ecstasywonder  
Email: chinwenduonyeani@gmail.com
