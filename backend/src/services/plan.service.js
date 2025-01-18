const { Plan, PlanBenefit, PlanSubscription, User } = require('../models');
const { Op } = require('sequelize');
const { sendEmail } = require('../utils/email');

class PlanService {
  async getAllPlans(filters = {}) {
    try {
      const {
        minPrice,
        maxPrice,
        coverage,
        isActive = true
      } = filters;

      const where = { isActive };

      if (minPrice || maxPrice) {
        where.price = {};
        if (minPrice) where.price[Op.gte] = minPrice;
        if (maxPrice) where.price[Op.lte] = maxPrice;
      }

      if (coverage) {
        where.coverage = coverage;
      }

      const plans = await Plan.findAll({
        where,
        include: [{
          model: PlanBenefit,
          as: 'benefits',
          attributes: ['id', 'name', 'category', 'coverage', 'limit']
        }],
        order: [
          ['order', 'ASC'],
          ['price', 'ASC'],
          [{ model: PlanBenefit, as: 'benefits' }, 'order', 'ASC']
        ]
      });

      return plans;
    } catch (error) {
      throw new Error(`Error fetching plans: ${error.message}`);
    }
  }

  async getPlanById(planId) {
    try {
      const plan = await Plan.findByPk(planId, {
        include: [{
          model: PlanBenefit,
          as: 'benefits',
          where: { isActive: true }
        }]
      });

      if (!plan) {
        throw new Error('Plan not found');
      }

      return plan;
    } catch (error) {
      throw new Error(`Error fetching plan details: ${error.message}`);
    }
  }

  async comparePlans(planIds) {
    try {
      const plans = await Plan.findAll({
        where: {
          id: { [Op.in]: planIds },
          isActive: true
        },
        include: [{
          model: PlanBenefit,
          as: 'benefits',
          where: { isActive: true }
        }]
      });

      // Group benefits by category for easier comparison
      const comparisonData = plans.map(plan => {
        const benefitsByCategory = plan.benefits.reduce((acc, benefit) => {
          if (!acc[benefit.category]) {
            acc[benefit.category] = [];
          }
          acc[benefit.category].push(benefit);
          return acc;
        }, {});

        return {
          id: plan.id,
          name: plan.name,
          price: plan.price,
          coverage: plan.coverage,
          maxBenefitAmount: plan.maxBenefitAmount,
          waitingPeriod: plan.waitingPeriod,
          features: plan.features,
          benefits: benefitsByCategory
        };
      });

      return comparisonData;
    } catch (error) {
      throw new Error(`Error comparing plans: ${error.message}`);
    }
  }

  async subscribeToPlan(userId, planId, paymentDetails) {
    try {
      const [user, plan] = await Promise.all([
        User.findByPk(userId),
        Plan.findByPk(planId)
      ]);

      if (!user || !plan) {
        throw new Error('User or plan not found');
      }

      // TODO: Process payment here
      // const paymentResult = await processPayment(paymentDetails);

      // Calculate subscription period
      const startDate = new Date();
      const endDate = new Date();
      endDate.setFullYear(endDate.getFullYear() + 1);

      // Create subscription record
      const subscription = await PlanSubscription.create({
        userId,
        planId,
        startDate,
        endDate,
        status: 'active',
        paymentStatus: 'completed',
        paymentReference: 'payment_ref', // Replace with actual payment reference
        amount: plan.price,
        autoRenew: true,
        nextBillingDate: endDate
      });

      // Update user's active plan
      await user.update({ activePlanId: planId });

      // Send confirmation email
      await sendEmail({
        to: user.email,
        subject: 'Plan Subscription Confirmation',
        template: 'plan-subscription',
        data: {
          userName: user.firstName,
          planName: plan.name,
          startDate: startDate.toLocaleDateString(),
          endDate: endDate.toLocaleDateString(),
          amount: plan.price
        }
      });

      return subscription;
    } catch (error) {
      throw new Error(`Error subscribing to plan: ${error.message}`);
    }
  }

  async cancelSubscription(subscriptionId, userId, reason) {
    try {
      const subscription = await PlanSubscription.findOne({
        where: {
          id: subscriptionId,
          userId,
          status: 'active'
        }
      });

      if (!subscription) {
        throw new Error('Active subscription not found');
      }

      // Update subscription status
      await subscription.update({
        status: 'cancelled',
        cancelledAt: new Date(),
        cancellationReason: reason,
        autoRenew: false
      });

      // Send cancellation email
      const user = await User.findByPk(userId);
      await sendEmail({
        to: user.email,
        subject: 'Plan Subscription Cancelled',
        template: 'plan-cancellation',
        data: {
          userName: user.firstName,
          subscriptionId: subscription.id,
          cancelDate: new Date().toLocaleDateString()
        }
      });

      return subscription;
    } catch (error) {
      throw new Error(`Error cancelling subscription: ${error.message}`);
    }
  }

  async getUserSubscriptionHistory(userId) {
    try {
      const subscriptions = await PlanSubscription.findAll({
        where: { userId },
        include: [{
          model: Plan,
          as: 'plan',
          attributes: ['name', 'coverage', 'price']
        }],
        order: [['createdAt', 'DESC']]
      });

      return subscriptions;
    } catch (error) {
      throw new Error(`Error fetching subscription history: ${error.message}`);
    }
  }

  async getPlanBenefits(planId) {
    try {
      const benefits = await PlanBenefit.findAll({
        where: {
          planId,
          isActive: true
        },
        order: [
          ['category', 'ASC'],
          ['order', 'ASC']
        ]
      });

      return benefits;
    } catch (error) {
      throw new Error(`Error fetching plan benefits: ${error.message}`);
    }
  }
}

module.exports = new PlanService(); 