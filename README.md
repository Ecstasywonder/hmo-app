# HMO App — Healthcare Insurance Platform

HMO App is a full-stack healthcare insurance comparison platform built with **Flutter**, **Node.js/Express**, and **MySQL**.

The project demonstrates full-stack application development across a mobile frontend, REST API backend, relational database, authentication, security controls, migrations, and administrative workflows.

## Engineering Highlights

- Flutter/Dart mobile frontend
- Node.js + Express REST API
- MySQL persistence with Sequelize
- Database migrations and seeders
- JWT authentication with refresh tokens
- Email verification
- Optional two-factor authentication
- Helmet security headers
- Rate limiting
- CORS protection
- Password hashing with bcrypt
- Request validation
- Administrative API workflows
- Standardized API error responses

## Product Features

### User

- HMO listing and comparison
- Appointment booking
- User dashboard and profile management
- Claims and health records
- Secure authentication

### Administration

- Dashboard and system statistics
- User management
- Hospital management
- Appointment management
- Claims management
- System configuration

## Architecture

The project separates the Flutter client from the Node.js/Express API and relational data layer.

**Frontend:** Flutter / Dart

**Backend:** Node.js / Express

**Database:** MySQL

**ORM & migrations:** Sequelize

**Authentication:** JWT + refresh tokens

**Security:** Helmet, rate limiting, CORS, bcrypt, email verification, optional 2FA, request validation

## Local Development

### Prerequisites

- Node.js 14+
- MySQL 8+
- Flutter SDK 3.0+
- npm or yarn

### Backend

```bash
git clone https://github.com/Ecstasywonder/hmo-app
cd backend
npm install
```

Create a local MySQL database:

```sql
CREATE DATABASE hmo_app;
```

Configure the environment using `.env.example`, then run:

```bash
npx sequelize-cli db:migrate
npx sequelize-cli db:seed:all
npm run dev
```

### Flutter Frontend

```bash
cd frontend
flutter pub get
flutter run
```

Ensure the emulator/device can reach the backend API using the configured base URL.

## API Reference

### Authentication

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh-token`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `PUT /api/auth/profile`

### Appointments

- `GET /api/appointments`
- `POST /api/appointments`
- `GET /api/appointments/:id`
- `PUT /api/appointments/:id`
- `DELETE /api/appointments/:id`
- `GET /api/appointments/history`
- `POST /api/appointments/:id/reschedule`
- `POST /api/appointments/:id/confirm`

### Hospitals

- `GET /api/hospitals`
- `GET /api/hospitals/:id`
- `GET /api/hospitals/specialties`
- `GET /api/hospitals/:id/doctors`
- `GET /api/hospitals/:id/time-slots`

### Administration

- `GET /api/admin/dashboard`
- `GET /api/admin/users`
- `GET /api/admin/hospitals`
- `GET /api/admin/appointments`
- `GET /api/admin/claims`
- `GET /api/admin/settings`

## Security

The backend includes:

- JWT authentication and refresh tokens
- Password hashing
- Email verification
- Optional two-factor authentication
- Helmet HTTP security headers
- Rate limiting
- CORS controls
- Request validation

The project is intended for development and portfolio demonstration. Do not use real patient or health data in a development environment.

## Engineering Practices

**API development → database design → migrations → authentication → security controls → administrative workflows → reproducible local setup**

## Author

**Chinwendu Onyeani**  
Software / DevOps Engineer

GitHub: https://github.com/Ecstasywonder  
Email: chinwenduonyeani@gmail.com
