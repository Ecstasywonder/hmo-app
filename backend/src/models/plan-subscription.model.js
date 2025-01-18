const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class PlanSubscription extends Model {}

PlanSubscription.init({
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
  startDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  endDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('active', 'expired', 'cancelled', 'suspended'),
    defaultValue: 'active'
  },
  autoRenew: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded'),
    defaultValue: 'pending'
  },
  paymentMethod: {
    type: DataTypes.STRING
  },
  paymentReference: {
    type: DataTypes.STRING
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  currency: {
    type: DataTypes.STRING,
    defaultValue: 'NGN'
  },
  nextBillingDate: {
    type: DataTypes.DATE
  },
  cancelledAt: {
    type: DataTypes.DATE
  },
  cancellationReason: {
    type: DataTypes.STRING
  },
  metadata: {
    type: DataTypes.JSON,
    defaultValue: {}
  }
}, {
  sequelize,
  modelName: 'PlanSubscription',
  tableName: 'plan_subscriptions',
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
      fields: ['startDate']
    },
    {
      fields: ['endDate']
    }
  ]
});

module.exports = PlanSubscription; 