const { Provider, Hospital, Plan, Review, User } = require('../models');
const { Op } = require('sequelize');

class ProviderService {
  async getAllProviders(filters = {}) {
    try {
      const {
        name,
        city,
        state,
        rating,
        minPlans,
        maxPlans,
        page = 1,
        limit = 10
      } = filters;

      const where = { isActive: true };

      if (name) {
        where.name = { [Op.iLike]: `%${name}%` };
      }

      if (city) {
        where.city = { [Op.iLike]: `%${city}%` };
      }

      if (state) {
        where.state = { [Op.iLike]: `%${state}%` };
      }

      if (rating) {
        where.rating = { [Op.gte]: rating };
      }

      const offset = (page - 1) * limit;

      const { rows: providers, count } = await Provider.findAndCountAll({
        where,
        include: [{
          model: Plan,
          as: 'plans',
          attributes: ['id', 'name', 'price', 'coverage'],
          where: minPlans || maxPlans ? {
            price: {
              ...(minPlans && { [Op.gte]: minPlans }),
              ...(maxPlans && { [Op.lte]: maxPlans })
            }
          } : undefined
        }, {
          model: Hospital,
          as: 'hospitals',
          attributes: ['id', 'name', 'city', 'state']
        }],
        order: [
          ['rating', 'DESC'],
          ['name', 'ASC']
        ],
        limit,
        offset,
        distinct: true
      });

      return {
        providers,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error fetching providers: ${error.message}`);
    }
  }

  async getProviderById(providerId) {
    try {
      const provider = await Provider.findByPk(providerId, {
        include: [
          {
            model: Plan,
            as: 'plans',
            attributes: ['id', 'name', 'price', 'coverage', 'features', 'benefits']
          },
          {
            model: Hospital,
            as: 'hospitals',
            attributes: ['id', 'name', 'address', 'city', 'state', 'rating']
          },
          {
            model: Review,
            as: 'reviews',
            include: [{
              model: User,
              as: 'user',
              attributes: ['id', 'firstName', 'lastName', 'avatar']
            }],
            limit: 5,
            order: [['createdAt', 'DESC']]
          }
        ]
      });

      if (!provider) {
        throw new Error('Provider not found');
      }

      // Get provider stats
      const stats = await this._getProviderStats(providerId);

      return {
        ...provider.toJSON(),
        stats
      };
    } catch (error) {
      throw new Error(`Error fetching provider details: ${error.message}`);
    }
  }

  async getProviderReviews(providerId, page = 1, limit = 10) {
    try {
      const offset = (page - 1) * limit;

      const { rows: reviews, count } = await Review.findAndCountAll({
        where: { providerId },
        include: [{
          model: User,
          as: 'user',
          attributes: ['id', 'firstName', 'lastName', 'avatar']
        }],
        order: [['createdAt', 'DESC']],
        limit,
        offset
      });

      return {
        reviews,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error fetching provider reviews: ${error.message}`);
    }
  }

  async addProviderReview(providerId, userId, data) {
    try {
      const { rating, comment } = data;

      // Check if user has an active plan with this provider
      const hasActivePlan = await this._checkUserHasActivePlan(userId, providerId);
      if (!hasActivePlan) {
        throw new Error('Only users with active plans can review providers');
      }

      const review = await Review.create({
        providerId,
        userId,
        rating,
        comment
      });

      // Update provider average rating
      await this._updateProviderRating(providerId);

      return review;
    } catch (error) {
      throw new Error(`Error adding provider review: ${error.message}`);
    }
  }

  async getProviderPlans(providerId) {
    try {
      const plans = await Plan.findAll({
        where: {
          providerId,
          isActive: true
        },
        order: [
          ['price', 'ASC']
        ]
      });

      return plans;
    } catch (error) {
      throw new Error(`Error fetching provider plans: ${error.message}`);
    }
  }

  async getProviderHospitals(providerId, filters = {}) {
    try {
      const {
        city,
        state,
        rating,
        page = 1,
        limit = 10
      } = filters;

      const where = {
        providerId,
        isActive: true
      };

      if (city) {
        where.city = { [Op.iLike]: `%${city}%` };
      }

      if (state) {
        where.state = { [Op.iLike]: `%${state}%` };
      }

      if (rating) {
        where.rating = { [Op.gte]: rating };
      }

      const offset = (page - 1) * limit;

      const { rows: hospitals, count } = await Hospital.findAndCountAll({
        where,
        order: [
          ['rating', 'DESC'],
          ['name', 'ASC']
        ],
        limit,
        offset
      });

      return {
        hospitals,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error fetching provider hospitals: ${error.message}`);
    }
  }

  // Private helper methods
  async _getProviderStats(providerId) {
    try {
      const [
        plansCount,
        hospitalsCount,
        subscribersCount,
        averageRating
      ] = await Promise.all([
        Plan.count({ where: { providerId, isActive: true } }),
        Hospital.count({ where: { providerId, isActive: true } }),
        User.count({
          include: [{
            model: Plan,
            as: 'activePlan',
            where: { providerId }
          }]
        }),
        Review.findOne({
          where: { providerId },
          attributes: [
            [sequelize.fn('AVG', sequelize.col('rating')), 'averageRating']
          ]
        })
      ]);

      return {
        plansCount,
        hospitalsCount,
        subscribersCount,
        averageRating: averageRating?.getDataValue('averageRating') || 0
      };
    } catch (error) {
      throw new Error(`Error fetching provider stats: ${error.message}`);
    }
  }

  async _checkUserHasActivePlan(userId, providerId) {
    const user = await User.findByPk(userId, {
      include: [{
        model: Plan,
        as: 'activePlan',
        where: { providerId },
        required: true
      }]
    });

    return !!user;
  }

  async _updateProviderRating(providerId) {
    const avgRating = await Review.findOne({
      where: { providerId },
      attributes: [
        [sequelize.fn('AVG', sequelize.col('rating')), 'averageRating']
      ]
    });

    await Provider.update(
      { rating: avgRating.getDataValue('averageRating') },
      { where: { id: providerId } }
    );
  }
}

module.exports = new ProviderService(); 