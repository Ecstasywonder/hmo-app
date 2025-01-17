const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const LoginAttempt = sequelize.define('LoginAttempt', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  success: {
    type: DataTypes.BOOLEAN,
    allowNull: false
  },
  ipAddress: {
    type: DataTypes.STRING
  },
  userAgent: {
    type: DataTypes.STRING
  },
  location: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  failureReason: {
    type: DataTypes.STRING
  }
}, {
  timestamps: true,
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['ipAddress']
    },
    {
      fields: ['createdAt']
    }
  ]
});

module.exports = LoginAttempt; 