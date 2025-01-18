const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class PlanBenefit extends Model {}

PlanBenefit.init({
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  planId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'plans',
      key: 'id'
    }
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false
  },
  coverage: {
    type: DataTypes.ENUM('full', 'partial', 'none'),
    defaultValue: 'full'
  },
  coverageDetails: {
    type: DataTypes.JSON,
    defaultValue: {}
  },
  limit: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  limitPeriod: {
    type: DataTypes.ENUM('per_visit', 'daily', 'weekly', 'monthly', 'yearly', 'lifetime'),
    allowNull: true
  },
  waitingPeriod: {
    type: DataTypes.INTEGER, // in days
    defaultValue: 0
  },
  requiresPreAuth: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  copayment: {
    type: DataTypes.DECIMAL(5, 2), // percentage
    defaultValue: 0
  },
  deductible: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  conditions: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  metadata: {
    type: DataTypes.JSON,
    defaultValue: {}
  }
}, {
  sequelize,
  modelName: 'PlanBenefit',
  tableName: 'plan_benefits',
  timestamps: true,
  indexes: [
    {
      fields: ['planId']
    },
    {
      fields: ['category']
    },
    {
      fields: ['coverage']
    }
  ]
});

// Define common benefit categories
PlanBenefit.CATEGORIES = {
  OUTPATIENT: 'outpatient',
  INPATIENT: 'inpatient',
  EMERGENCY: 'emergency',
  MATERNITY: 'maternity',
  DENTAL: 'dental',
  OPTICAL: 'optical',
  MENTAL_HEALTH: 'mental_health',
  PRESCRIPTION: 'prescription',
  PREVENTIVE: 'preventive',
  SPECIALIST: 'specialist',
  CHRONIC: 'chronic',
  REHABILITATION: 'rehabilitation'
};

module.exports = PlanBenefit; 