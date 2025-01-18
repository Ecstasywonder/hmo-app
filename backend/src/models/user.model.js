const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
  name: {
      type: DataTypes.STRING,
    allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
      isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
    allowNull: false
  },
  phone: {
    type: DataTypes.STRING
    },
    role: {
    type: DataTypes.ENUM('user', 'admin', 'hospital_admin'),
      defaultValue: 'user'
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
  isEmailVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  lastLoginAt: {
      type: DataTypes.DATE
  },
  marketingEmails: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  appointmentReminders: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  subscriptionAlerts: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  profileImage: {
    type: DataTypes.STRING
  },
  address: {
    type: DataTypes.STRING
  },
  dateOfBirth: {
    type: DataTypes.DATEONLY
  },
  gender: {
    type: DataTypes.ENUM('male', 'female', 'other')
  },
  emergencyContact: {
    type: DataTypes.JSONB,
    defaultValue: {}
    }
  }, {
    timestamps: true,
  indexes: [
    {
      fields: ['email']
    },
    {
      fields: ['role']
    },
    {
      fields: ['isActive']
    }
  ]
});

module.exports = User; 