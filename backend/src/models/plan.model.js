const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class Plan extends Model {}

Plan.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    unique: true
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
  interval: {
    type: DataTypes.ENUM('monthly', 'quarterly', 'annually'),
    defaultValue: 'annually'
  },
  coverage: {
    type: DataTypes.STRING,
    allowNull: false
  },
  maxBenefitAmount: {
    type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
  waitingPeriod: {
    type: DataTypes.INTEGER, // in days
    defaultValue: 0
  },
    features: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  benefits: {
    type: DataTypes.JSON,
    defaultValue: {}
  },
  exclusions: {
    type: DataTypes.JSON,
      defaultValue: []
    },
  rating: {
    type: DataTypes.DECIMAL(2, 1),
    defaultValue: 0
  },
  subscribers: {
    type: DataTypes.INTEGER,
    defaultValue: 0
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
  },
  isPopular: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  metadata: {
    type: DataTypes.JSON,
    defaultValue: {}
  }
}, {
  sequelize,
  modelName: 'Plan',
  tableName: 'plans',
  timestamps: true,
  paranoid: true // Enable soft deletes
});

module.exports = Plan; 