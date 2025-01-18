const { User, Plan, PlanSubscription, Appointment, Provider, SystemMetric } = require('../models');
const { Op } = require('sequelize');

class AnalyticsService {
  async getDashboardStats() {
    const now = new Date();
    const lastMonth = new Date(now.setMonth(now.getMonth() - 1));

    const [
      totalUsers,
      activeSubscriptions,
      totalAppointments,
      totalProviders,
      monthlyRevenue,
      userGrowth
    ] = await Promise.all([
      User.count(),
      PlanSubscription.count({ where: { status: 'active' } }),
      Appointment.count(),
      Provider.count(),
      PlanSubscription.sum('amount', { 
        where: { 
          createdAt: { [Op.gte]: lastMonth },
          status: 'active'
        }
      }),
      this.calculateUserGrowth()
    ]);

    return {
      totalUsers,
      activeSubscriptions,
      totalAppointments,
      totalProviders,
      monthlyRevenue,
      userGrowth
    };
  }

  async getSubscriptionMetrics(period = 'month') {
    const metrics = await PlanSubscription.findAll({
      attributes: [
        'planId',
        [sequelize.fn('COUNT', '*'), 'total'],
        [sequelize.fn('SUM', sequelize.col('amount')), 'revenue']
      ],
      where: this.getPeriodWhere(period),
      group: ['planId'],
      include: [{ model: Plan, attributes: ['name'] }]
    });

    return metrics;
  }

  async getProviderMetrics() {
    const metrics = await Provider.findAll({
      attributes: [
        'id',
        'name',
        [sequelize.fn('COUNT', sequelize.col('appointments.id')), 'totalAppointments'],
        [sequelize.fn('AVG', sequelize.col('reviews.rating')), 'averageRating']
      ],
      include: [
        { model: Appointment, attributes: [] },
        { model: Review, attributes: [] }
      ],
      group: ['Provider.id']
    });

    return metrics;
  }

  async generateReport(type, period = 'month') {
    let report;
    switch (type) {
      case 'revenue':
        report = await this.generateRevenueReport(period);
        break;
      case 'usage':
        report = await this.generateUsageReport(period);
        break;
      case 'providers':
        report = await this.generateProviderReport(period);
        break;
      default:
        throw new Error('Invalid report type');
    }

    return report;
  }

  async trackMetric(name, value, metadata = {}) {
    await SystemMetric.create({
      name,
      value,
      metadata
    });
  }

  private async calculateUserGrowth() {
    const now = new Date();
    const lastMonth = new Date(now.setMonth(now.getMonth() - 1));
    const twoMonthsAgo = new Date(now.setMonth(now.getMonth() - 1));

    const [currentUsers, previousUsers] = await Promise.all([
      User.count({ where: { createdAt: { [Op.gte]: lastMonth } } }),
      User.count({ 
        where: { 
          createdAt: { 
            [Op.gte]: twoMonthsAgo,
            [Op.lt]: lastMonth
          } 
        } 
      })
    ]);

    const growth = previousUsers === 0 ? 100 : ((currentUsers - previousUsers) / previousUsers) * 100;
    return growth;
  }

  private getPeriodWhere(period) {
    const now = new Date();
    let startDate;

    switch (period) {
      case 'week':
        startDate = new Date(now.setDate(now.getDate() - 7));
        break;
      case 'month':
        startDate = new Date(now.setMonth(now.getMonth() - 1));
        break;
      case 'year':
        startDate = new Date(now.setFullYear(now.getFullYear() - 1));
        break;
      default:
        throw new Error('Invalid period');
    }

    return {
      createdAt: { [Op.gte]: startDate }
    };
  }
}

module.exports = new AnalyticsService(); 