const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Plan = sequelize.define('Plan', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    duration: {
      type: DataTypes.INTEGER, // in months
      allowNull: false
    },
    features: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    coverage: {
      type: DataTypes.JSONB,
      allowNull: false
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  });

  Plan.associate = (models) => {
    Plan.hasMany(models.Subscription, {
      foreignKey: 'planId',
      as: 'subscriptions'
    });
  };

  return Plan;
}; 