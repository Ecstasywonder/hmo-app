# 🏥 HMO App

**HMO App** is a full-stack health insurance comparison platform built with **Flutter** (frontend) and **Node.js + MySQL** (backend). The app improves healthcare access for underserved communities by allowing users to browse, compare, and subscribe to HMO packages. It also supports booking appointments, managing user profiles, and accessing hospital services in one place.

---

## 🌐 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js + Express
- **Database**: MySQL
- **ORM**: Sequelize
- **Authentication**: JWT with Refresh Tokens
- **Security**: Helmet, Rate Limiting, CORS
- **Dev Tools**: Sequelize CLI, dotenv

---

## ✨ Features

### User-Facing

- 🏥 **HMO Listing & Comparison**
- 📅 **Appointment Booking**
- 📂 **User Dashboard & Profile Management**
- 🧾 **Claims and Health Records**
- 🔐 **Secure Login and Signup**

### Admin-Facing

- 📊 **Admin Dashboard**
- 🗃️ **Manage Users, Appointments, and Hospitals**
- ⚙️ **System Configuration**

---

## 📦 Prerequisites

- **Node.js** (v14+)
- **MySQL** (v8+)
- **Flutter SDK** (v3.0+ recommended)
- **npm** or **yarn**

---

## 🛠️ Backend Setup

1. **Clone the repository**:

git clone <https://github.com/Ecstasywonder/hmo-app>
cd backend

2. **Install backend dependencies**:

npm install

3. **Create a MySQL database**:

CREATE DATABASE hmo_app;

4. **Configure environment variables**:

- Copy `.env.example` to `.env`
- Update with your credentials

5. **Run migrations**:

npx sequelize-cli db:migrate

6. *(Optional)* **Seed sample data**:

npx sequelize-cli db:seed:all

7. **Start the backend server**:

npm run dev   # Development
npm start     # Production

---

## 📱 Flutter Frontend Setup

1. **Navigate to the Flutter directory**:

cd frontend

2. **Install packages**:

flutter pub get

3. **Run the app**:

flutter run

> Ensure your emulator/device is running, and the backend API is accessible via the correct base URL.

---

## 📚 API Reference

**Authentication**

- `POST /api/auth/register` – Register a user
- `POST /api/auth/login` – Login
- `POST /api/auth/refresh-token` – Refresh token
- `POST /api/auth/logout` – Logout
- `GET /api/auth/me` – Get profile
- `PUT /api/auth/profile` – Update profile

**Appointments**

- `GET /api/appointments` – List appointments
- `POST /api/appointments` – Book appointment
- `GET /api/appointments/:id` – Appointment details
- `PUT /api/appointments/:id` – Update
- `DELETE /api/appointments/:id` – Cancel
- `GET /api/appointments/history` – History
- `POST /api/appointments/:id/reschedule` – Reschedule
- `POST /api/appointments/:id/confirm` – Confirm

**Hospitals**

- `GET /api/hospitals` – List
- `GET /api/hospitals/:id` – Details
- `GET /api/hospitals/specialties` – Specialties
- `GET /api/hospitals/:id/doctors` – Doctors
- `GET /api/hospitals/:id/time-slots` – Time slots

**Admin**

- `GET /api/admin/dashboard` – Stats
- `GET /api/admin/users` – All users
- `GET /api/admin/hospitals` – All hospitals
- `GET /api/admin/appointments` – All appointments
- `GET /api/admin/claims` – All claims
- `GET /api/admin/settings` – System settings

---

## 🔐 Security Features

- JWT-based Authentication + Refresh Tokens
- Rate Limiting and CORS Protection
- Password Hashing (bcrypt)
- Email Verification
- Two-Factor Authentication (Optional)
- Request Validation
- Helmet HTTP Security Headers

---

## ❌ Error Format

All errors follow this standard format:

{
  "error": "Brief message",
  "details": "Verbose description (dev only)"
}

---

## 🤝 Contributing

Open-source contributions are wlcomed!

1. Fork the repository  
2. Create a new branch (`feature/your-feature`)  
3. Commit and push your changes  
4. Open a Pull Request with a clear description

---

## 💬 Contact

Got questions or suggestions?  
Start a conversation via [GitHub Issues](https://github.com/hmo-app/issues) or email the maintainer at <chinwenduonyeani@gmail.com>
