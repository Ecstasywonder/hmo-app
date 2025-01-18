# HMO App Backend

This is the backend server for the HMO application. It provides APIs for user management, appointments, hospitals, and more.

## Prerequisites

- Node.js (v14 or higher)
- MySQL (v8 or higher)
- npm or yarn

## Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd backend
```

2. Install dependencies:

```bash
npm install
```

3. Create a MySQL database:

```sql
CREATE DATABASE hmo_app;
```

4. Configure environment variables:

- Copy `.env.example` to `.env`
- Update the values in `.env` with your configuration

5. Run database migrations:

```bash
npx sequelize-cli db:migrate
```

6. (Optional) Seed the database with sample data:

```bash
npx sequelize-cli db:seed:all
```

## Running the Server

### Development

```bash
npm run dev
```

### Production

```bash
npm start
```

## API Documentation

### Authentication

- POST /api/auth/register - Register a new user
- POST /api/auth/login - Login user
- POST /api/auth/refresh-token - Refresh access token
- POST /api/auth/logout - Logout user
- GET /api/auth/me - Get current user
- PUT /api/auth/profile - Update user profile

### Appointments

- GET /api/appointments - Get user's appointments
- POST /api/appointments - Book new appointment
- GET /api/appointments/:id - Get appointment details
- PUT /api/appointments/:id - Update appointment
- DELETE /api/appointments/:id - Cancel appointment
- GET /api/appointments/history - Get appointment history
- POST /api/appointments/:id/reschedule - Reschedule appointment
- POST /api/appointments/:id/confirm - Confirm appointment

### Hospitals

- GET /api/hospitals - Get list of hospitals
- GET /api/hospitals/:id - Get hospital details
- GET /api/hospitals/specialties - Get available specialties
- GET /api/hospitals/:id/doctors - Get hospital doctors
- GET /api/hospitals/:id/time-slots - Get available time slots

### Admin

- GET /api/admin/dashboard - Get admin dashboard stats
- GET /api/admin/users - Get all users
- GET /api/admin/hospitals - Get all hospitals
- GET /api/admin/appointments - Get all appointments
- GET /api/admin/claims - Get all claims
- GET /api/admin/settings - Get system settings

## Security Features

- JWT-based authentication with refresh tokens
- Rate limiting
- Password hashing
- Account locking after failed attempts
- Email verification
- Two-factor authentication (optional)
- Request validation
- CORS protection
- Helmet security headers

## Error Handling

The API uses standard HTTP status codes and returns errors in the following format:

```json
{
  "error": "Error message",
  "details": "Detailed error message (only in development)"
}
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
