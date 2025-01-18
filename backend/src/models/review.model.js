const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class Review extends Model {}

Review.init({
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
  providerId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'providers',
      key: 'id'
    }
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  isVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
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
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    defaultValue: 'pending'
  },
  rejectionReason: {
    type: DataTypes.STRING,
    allowNull: true
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {}
  }
}, {
  sequelize,
  modelName: 'Review',
  tableName: 'reviews',
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['providerId']
    },
    {
      fields: ['rating']
    },
    {
      fields: ['status']
    }
  ],
  hooks: {
    afterCreate: async (review) => {
      // Update provider rating and review count
      const provider = await review.getProvider();
      const reviews = await provider.getReviews();
      
      const totalRating = reviews.reduce((sum, r) => sum + r.rating, 0);
      const averageRating = totalRating / reviews.length;
      
      await provider.update({
        rating: averageRating,
        reviewCount: reviews.length
      });
    }
  }
});

module.exports = Review; 