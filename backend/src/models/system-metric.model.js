const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const SystemMetric = sequelize.define('SystemMetric', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  metricName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  value: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  unit: {
    type: DataTypes.STRING
  },
  timestamp: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  },
  category: {
    type: DataTypes.ENUM(
      'system',
      'application',
      'database',
      'api',
      'security',
      'business'
    ),
    allowNull: false
  },
  tags: {
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
      fields: ['metricName']
    },
    {
      fields: ['category']
    },
    {
      fields: ['timestamp']
    },
    {
      fields: ['metricName', 'timestamp']
    }
  ]
});

module.exports = SystemMetric; 