const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ActivityLog = sequelize.define('ActivityLog', {
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
  action: {
    type: DataTypes.STRING,
    allowNull: false
  },
  details: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  ipAddress: {
    type: DataTypes.STRING
  },
  userAgent: {
    type: DataTypes.STRING
  },
  resourceType: {
    type: DataTypes.STRING
  },
  resourceId: {
    type: DataTypes.UUID
  },
  status: {
    type: DataTypes.ENUM('success', 'failure', 'pending'),
    defaultValue: 'success'
  },
  duration: {
    type: DataTypes.INTEGER // in milliseconds
  },
  errorDetails: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {}
  }
}, {
  timestamps: true,
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['action']
    },
    {
      fields: ['resourceType', 'resourceId']
    },
    {
      fields: ['createdAt']
    },
    {
      fields: ['status']
    }
  ]
});

module.exports = ActivityLog; 