const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class Payment extends Model {}

Payment.init({
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  planId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'plans',
      key: 'id'
    }
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  currency: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'NGN'
  },
  paymentMethod: {
    type: DataTypes.ENUM('card', 'bank_transfer', 'debit', 'ussd'),
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded', 'cancelled'),
    allowNull: false,
    defaultValue: 'pending'
  },
  transactionRef: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  }
}, {
  sequelize,
  modelName: 'Payment',
  tableName: 'payments',
  timestamps: true,
  paranoid: true
});

module.exports = Payment;