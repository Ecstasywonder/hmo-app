const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class Provider extends Model {}

Provider.init({
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
  logo: {
    type: DataTypes.STRING,
    allowNull: true
  },
  website: {
    type: DataTypes.STRING,
    allowNull: true,
    validate: {
      isUrl: true
    }
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: false
  },
  address: {
    type: DataTypes.STRING,
    allowNull: false
  },
  city: {
    type: DataTypes.STRING,
    allowNull: false
  },
  state: {
    type: DataTypes.STRING,
    allowNull: false
  },
  rating: {
    type: DataTypes.FLOAT,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 5
    }
  },
  reviewCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  subscriberCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  yearEstablished: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: {
      min: 1900,
      max: new Date().getFullYear()
    }
  },
  licenseNumber: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  features: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  coverage: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  operatingHours: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  socialMedia: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  documents: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  isVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  verifiedAt: {
    type: DataTypes.DATE,
    allowNull: true
  },
  verifiedBy: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'users',
      key: 'id'
    }
  }
}, {
  sequelize,
  modelName: 'Provider',
  tableName: 'providers',
  paranoid: true,
  indexes: [
    {
      fields: ['name']
    },
    {
      fields: ['city']
    },
    {
      fields: ['state']
    },
    {
      fields: ['rating']
    },
    {
      fields: ['isActive']
    }
  ]
});

module.exports = Provider; 