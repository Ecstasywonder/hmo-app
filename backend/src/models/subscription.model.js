const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Subscription = sequelize.define('Subscription', {
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
  planId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Plans',
      key: 'id'
    }
  },
  startDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  endDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('active', 'expired', 'cancelled'),
    defaultValue: 'active'
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'completed', 'failed'),
    defaultValue: 'pending'
  },
  paymentMethod: {
    type: DataTypes.STRING
  },
  transactionId: {
    type: DataTypes.STRING
  },
  autoRenew: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  lastRenewalDate: {
    type: DataTypes.DATE
  },
  nextRenewalDate: {
    type: DataTypes.DATE
  },
  cancellationReason: {
    type: DataTypes.TEXT
  }
}, {
  timestamps: true,
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['planId']
    },
    {
      fields: ['status']
    },
    {
      fields: ['endDate']
    }
  ]
});

module.exports = Subscription; 