require('dotenv').config();

module.exports = {
  JWT_SECRET: process.env.JWT_SECRET || 'your-secret-key',
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'your-refresh-secret-key',
  JWT_ACCESS_EXPIRATION: process.env.JWT_ACCESS_EXPIRATION || '15m',
  JWT_REFRESH_EXPIRATION: process.env.JWT_REFRESH_EXPIRATION || '7d',
  JWT_RESET_PASSWORD_EXPIRATION: process.env.JWT_RESET_PASSWORD_EXPIRATION || '1h',
  JWT_VERIFY_EMAIL_EXPIRATION: process.env.JWT_VERIFY_EMAIL_EXPIRATION || '24h'
}; 