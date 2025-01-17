const { sequelize } = require('../config/database');
const User = require('./user.model');
const Plan = require('./plan.model');
const Hospital = require('./hospital.model');
const Appointment = require('./appointment.model');
const Subscription = require('./subscription.model');
const EmailVerification = require('./email-verification.model');
const PasswordReset = require('./password-reset.model');
const LoginAttempt = require('./login-attempt.model');
const ActivityLog = require('./activity-log.model');
const SystemMetric = require('./system-metric.model');

// User associations
User.hasMany(Appointment);
User.hasMany(Subscription);
User.hasMany(EmailVerification);
User.hasMany(PasswordReset);
User.hasMany(LoginAttempt);
User.hasMany(ActivityLog);
Appointment.belongsTo(User);
Subscription.belongsTo(User);
EmailVerification.belongsTo(User);
PasswordReset.belongsTo(User);
LoginAttempt.belongsTo(User);
ActivityLog.belongsTo(User);

// Hospital associations
Hospital.hasMany(Appointment);
Appointment.belongsTo(Hospital);

// Plan associations
Plan.hasMany(Subscription);
Subscription.belongsTo(Plan);

module.exports = {
  sequelize,
  User,
  Plan,
  Hospital,
  Appointment,
  Subscription,
  EmailVerification,
  PasswordReset,
  LoginAttempt,
  ActivityLog,
  SystemMetric
}; 