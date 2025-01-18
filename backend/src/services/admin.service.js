const { User, Provider, Plan, PlanSubscription, Appointment, SystemMetric } = require('../models');
const { Op } = require('sequelize');
const analyticsService = require('./analytics.service');
const os = require('os');

class AdminService {
  async getDashboardStats() {
    return analyticsService.getDashboardStats();
  }

  async getSystemHealth() {
    const cpuUsage = os.loadavg()[0];
    const totalMemory = os.totalmem();
    const freeMemory = os.freemem();
    const memoryUsage = ((totalMemory - freeMemory) / totalMemory) * 100;

    const lastHour = new Date(Date.now() - 60 * 60 * 1000);
    const errorRate = await SystemMetric.count({
      where: {
        name: 'error',
        createdAt: { [Op.gte]: lastHour }
      }
    });

    return {
      status: this.calculateSystemStatus(cpuUsage, memoryUsage, errorRate),
      metrics: {
        cpuUsage,
        memoryUsage,
        errorRate,
        uptime: os.uptime()
      }
    };
  }

  async getUserManagementStats() {
    const now = new Date();
    const lastWeek = new Date(now.setDate(now.getDate() - 7));

    const [totalUsers, newUsers, activeUsers] = await Promise.all([
      User.count(),
      User.count({ where: { createdAt: { [Op.gte]: lastWeek } } }),
      User.count({
        include: [{
          model: PlanSubscription,
          where: { status: 'active' }
        }]
      })
    ]);

    return {
      totalUsers,
      newUsers,
      activeUsers,
      conversionRate: (activeUsers / totalUsers) * 100
    };
  }

  async getProviderManagementStats() {
    const [
      totalProviders,
      activeProviders,
      averageRating
    ] = await Promise.all([
      Provider.count(),
      Provider.count({ where: { status: 'active' } }),
      Provider.findOne({
        attributes: [
          [sequelize.fn('AVG', sequelize.col('rating')), 'averageRating']
        ]
      })
    ]);

    return {
      totalProviders,
      activeProviders,
      averageRating: averageRating || 0,
      utilizationRate: (activeProviders / totalProviders) * 100
    };
  }

  async getRevenueStats(period = 'month') {
    const metrics = await PlanSubscription.findAll({
      attributes: [
        [sequelize.fn('DATE_TRUNC', period, sequelize.col('createdAt')), 'period'],
        [sequelize.fn('SUM', sequelize.col('amount')), 'revenue'],
        [sequelize.fn('COUNT', '*'), 'subscriptions']
      ],
      where: analyticsService.getPeriodWhere(period),
      group: [sequelize.fn('DATE_TRUNC', period, sequelize.col('createdAt'))]
    });

    return metrics;
  }

  async getAuditLog({ page = 1, limit = 10, type = null }) {
    const where = type ? { type } : {};
    const offset = (page - 1) * limit;

    const logs = await ActivityLog.findAndCountAll({
      where,
      limit,
      offset,
      order: [['createdAt', 'DESC']],
      include: [{ model: User, attributes: ['id', 'name', 'email'] }]
    });

    return {
      logs: logs.rows,
      total: logs.count,
      page,
      totalPages: Math.ceil(logs.count / limit)
    };
  }

  private calculateSystemStatus(cpuUsage, memoryUsage, errorRate) {
    if (cpuUsage > 90 || memoryUsage > 90 || errorRate > 100) {
      return 'critical';
    }
    if (cpuUsage > 70 || memoryUsage > 70 || errorRate > 50) {
      return 'warning';
    }
    return 'healthy';
  }
}

module.exports = new AdminService(); 