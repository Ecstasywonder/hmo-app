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
const PlanSubscription = require('./plan-subscription.model');
const PlanBenefit = require('./plan-benefit.model');
const Provider = require('./provider');
const Review = require('./review.model');
const BankAccount = require('./bankAccount.model');
const Payment = require('./payment.model');

// User associations
User.hasMany(Appointment);
User.hasMany(Subscription);
User.hasMany(EmailVerification);
User.hasMany(PasswordReset);
User.hasMany(LoginAttempt);
User.hasMany(ActivityLog);
User.hasMany(PlanSubscription, {
  foreignKey: 'userId',
  as: 'planSubscriptions'
});
User.belongsTo(Plan, {
  foreignKey: 'activePlanId',
  as: 'activePlan'
});

// Bank Account Associations
User.hasMany(BankAccount);
BankAccount.belongsTo(User);

// Payment Associations
User.hasMany(Payment);
Payment.belongsTo(User);
Plan.hasMany(Payment);
Payment.belongsTo(Plan);
BankAccount.hasMany(Payment);
Payment.belongsTo(BankAccount);

// Hospital associations
Hospital.hasMany(Appointment);
Appointment.belongsTo(Hospital);

// Plan associations
Plan.hasMany(Subscription);
Subscription.belongsTo(Plan);
Plan.hasMany(PlanSubscription, {
  foreignKey: 'planId',
  as: 'subscriptions'
});
Plan.hasMany(PlanBenefit, {
  foreignKey: 'planId',
  as: 'benefits'
});

// Provider Associations
Provider.hasMany(Plan, {
  foreignKey: 'providerId',
  as: 'plans'
});
Provider.hasMany(Hospital, {
  foreignKey: 'providerId',
  as: 'hospitals'
});
Provider.hasMany(Review, {
  foreignKey: 'providerId',
  as: 'reviews'
});

Plan.belongsTo(Provider, {
  foreignKey: 'providerId',
  as: 'provider'
});
Hospital.belongsTo(Provider, {
  foreignKey: 'providerId',
  as: 'provider'
});

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
  SystemMetric,
  PlanSubscription,
  PlanBenefit,
  Provider,
  Review,
  BankAccount,
  Payment
}; 