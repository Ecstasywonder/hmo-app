const { Plan, Subscription } = require('../models');
const { Op } = require('sequelize');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

class PlanService {
  async createPlan(data) {
    // Create Stripe product and price
    const stripeProduct = await stripe.products.create({
      name: data.name,
      description: data.description
    });

    const stripePrice = await stripe.prices.create({
      product: stripeProduct.id,
      unit_amount: Math.round(data.price * 100), // Convert to cents
      currency: 'usd',
      recurring: {
        interval: data.billingCycle || 'month'
      }
    });

    // Create plan in database
    return await Plan.create({
      name: data.name,
      description: data.description,
      price: data.price,
      features: data.features || [],
      coverage: data.coverage || [],
      billingCycle: data.billingCycle || 'month',
      status: 'active',
      maxDependents: data.maxDependents || 0,
      waitingPeriod: data.waitingPeriod || 0,
      stripeProductId: stripeProduct.id,
      stripePriceId: stripePrice.id
    });
  }

  async updatePlan(id, data) {
    const plan = await Plan.findByPk(id);
    
    if (!plan) {
      throw new Error('Plan not found');
    }

    // Update Stripe product if name or description changed
    if (data.name || data.description) {
      await stripe.products.update(plan.stripeProductId, {
        name: data.name || plan.name,
        description: data.description || plan.description
      });
    }

    // If price changed, create new Stripe price
    if (data.price && data.price !== plan.price) {
      const stripePrice = await stripe.prices.create({
        product: plan.stripeProductId,
        unit_amount: Math.round(data.price * 100),
        currency: 'usd',
        recurring: {
          interval: data.billingCycle || plan.billingCycle
        }
      });
      data.stripePriceId = stripePrice.id;
    }

    // Update plan in database
    await plan.update({
      name: data.name || plan.name,
      description: data.description || plan.description,
      price: data.price || plan.price,
      features: data.features || plan.features,
      coverage: data.coverage || plan.coverage,
      billingCycle: data.billingCycle || plan.billingCycle,
      status: data.status || plan.status,
      maxDependents: data.maxDependents || plan.maxDependents,
      waitingPeriod: data.waitingPeriod || plan.waitingPeriod,
      stripePriceId: data.stripePriceId || plan.stripePriceId
    });

    return plan;
  }

  async getAllPlans(filters = {}) {
    const where = {
      status: 'active',
      ...(filters.priceRange && {
        price: {
          [Op.between]: filters.priceRange
        }
      }),
      ...(filters.billingCycle && {
        billingCycle: filters.billingCycle
      })
    };

    return await Plan.findAll({
      where,
      order: [['price', 'ASC']]
    });
  }

  async getPlanDetails(id) {
    const plan = await Plan.findByPk(id);
    
    if (!plan) {
      throw new Error('Plan not found');
    }

    // Get subscription statistics
    const subscriptionStats = await Subscription.findAll({
      where: { planId: id },
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['status'],
      raw: true
    });

    // Get monthly subscription trends
    const monthlyTrends = await Subscription.findAll({
      where: {
        planId: id,
        createdAt: {
          [Op.gte]: new Date(new Date().setMonth(new Date().getMonth() - 12))
        }
      },
      attributes: [
        [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'month'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt'))],
      order: [[sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'ASC']],
      raw: true
    });

    return {
      ...plan.toJSON(),
      subscriptionStats,
      monthlyTrends
    };
  }

  async comparePlans(planIds) {
    const plans = await Plan.findAll({
      where: {
        id: { [Op.in]: planIds },
        status: 'active'
      }
    });

    // Create comparison matrix
    const comparisonMatrix = {
      basic: {},
      features: {},
      coverage: {}
    };

    plans.forEach(plan => {
      // Basic comparison
      comparisonMatrix.basic[plan.id] = {
        name: plan.name,
        price: plan.price,
        billingCycle: plan.billingCycle,
        maxDependents: plan.maxDependents,
        waitingPeriod: plan.waitingPeriod
      };

      // Features comparison
      plan.features.forEach(feature => {
        if (!comparisonMatrix.features[feature.name]) {
          comparisonMatrix.features[feature.name] = {};
        }
        comparisonMatrix.features[feature.name][plan.id] = feature.included;
      });

      // Coverage comparison
      plan.coverage.forEach(item => {
        if (!comparisonMatrix.coverage[item.service]) {
          comparisonMatrix.coverage[item.service] = {};
        }
        comparisonMatrix.coverage[item.service][plan.id] = item.limit;
      });
    });

    return comparisonMatrix;
  }

  async deactivatePlan(id) {
    const plan = await Plan.findByPk(id);
    
    if (!plan) {
      throw new Error('Plan not found');
    }

    // Archive Stripe product
    await stripe.products.update(plan.stripeProductId, {
      active: false
    });

    // Update plan status
    await plan.update({
      status: 'inactive'
    });

    return true;
  }
}

module.exports = new PlanService(); 