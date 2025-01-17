const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Setting = sequelize.define('Setting', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  key: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  value: {
    type: DataTypes.JSONB,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  category: {
    type: DataTypes.ENUM(
      'general',
      'security',
      'email',
      'payment',
      'notification',
      'appointment',
      'system'
    ),
    allowNull: false
  },
  isPublic: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  lastModifiedBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  }
}, {
  timestamps: true,
  indexes: [
    {
      fields: ['key'],
      unique: true
    },
    {
      fields: ['category']
    }
  ]
});

// Default settings
Setting.DEFAULTS = {
  // General settings
  'site.name': {
    value: 'CareLink HMO',
    category: 'general',
    isPublic: true,
    description: 'Site name'
  },
  'site.description': {
    value: 'Your trusted healthcare partner',
    category: 'general',
    isPublic: true,
    description: 'Site description'
  },

  // Security settings
  'security.passwordPolicy': {
    value: {
      minLength: 8,
      requireUppercase: true,
      requireLowercase: true,
      requireNumbers: true,
      requireSpecialChars: true
    },
    category: 'security',
    isPublic: true,
    description: 'Password policy settings'
  },
  'security.loginAttempts': {
    value: {
      maxAttempts: 5,
      lockoutDuration: 30 // minutes
    },
    category: 'security',
    isPublic: false,
    description: 'Login attempt settings'
  },

  // Email settings
  'email.fromName': {
    value: 'CareLink HMO',
    category: 'email',
    isPublic: false,
    description: 'Email sender name'
  },
  'email.fromAddress': {
    value: 'noreply@carelinkhmo.com',
    category: 'email',
    isPublic: false,
    description: 'Email sender address'
  },

  // Payment settings
  'payment.currency': {
    value: 'USD',
    category: 'payment',
    isPublic: true,
    description: 'Default currency'
  },
  'payment.taxRate': {
    value: 0.1,
    category: 'payment',
    isPublic: true,
    description: 'Tax rate'
  },

  // Notification settings
  'notification.emailEnabled': {
    value: true,
    category: 'notification',
    isPublic: false,
    description: 'Enable email notifications'
  },
  'notification.pushEnabled': {
    value: true,
    category: 'notification',
    isPublic: false,
    description: 'Enable push notifications'
  },

  // Appointment settings
  'appointment.slotDuration': {
    value: 30,
    category: 'appointment',
    isPublic: true,
    description: 'Appointment slot duration in minutes'
  },
  'appointment.advanceBooking': {
    value: 30,
    category: 'appointment',
    isPublic: true,
    description: 'Maximum days in advance for booking'
  },

  // System settings
  'system.maintenance': {
    value: {
      enabled: false,
      message: 'System is under maintenance'
    },
    category: 'system',
    isPublic: true,
    description: 'System maintenance settings'
  },
  'system.version': {
    value: '1.0.0',
    category: 'system',
    isPublic: true,
    description: 'System version'
  }
};

// Hook to initialize default settings
Setting.afterSync(async () => {
  try {
    const count = await Setting.count();
    if (count === 0) {
      const defaults = Object.entries(Setting.DEFAULTS).map(([key, data]) => ({
        key,
        ...data
      }));
      await Setting.bulkCreate(defaults);
    }
  } catch (error) {
    console.error('Error initializing default settings:', error);
  }
});

module.exports = Setting; 