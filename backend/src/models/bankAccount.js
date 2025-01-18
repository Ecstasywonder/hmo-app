const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class BankAccount extends Model {}

BankAccount.init({
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
  accountName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  accountNumber: {
    type: DataTypes.STRING,
    allowNull: false
  },
  bankCode: {
    type: DataTypes.STRING,
    allowNull: false
  },
  bankName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  isVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  isDefault: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  lastVerifiedAt: {
    type: DataTypes.DATE
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {}
  }
}, {
  sequelize,
  modelName: 'BankAccount',
  tableName: 'bank_accounts',
  timestamps: true,
  paranoid: true,
  indexes: [
    {
      unique: true,
      fields: ['userId', 'accountNumber', 'bankCode']
    }
  ]
});

module.exports = BankAccount; 