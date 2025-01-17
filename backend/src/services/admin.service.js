const { User, Appointment, Hospital, Plan, Subscription, ActivityLog, Claim, MedicalRecord, Setting } = require('../models');
const { Op } = require('sequelize');

class AdminService {
  // Dashboard methods
  async getDashboardStats() {
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

    const [
      totalUsers,
      activeUsers,
      totalHospitals,
      totalAppointments,
      monthlyAppointments,
      totalSubscriptions,
      activeSubscriptions,
      recentActivities
    ] = await Promise.all([
      // User statistics
      User.count(),
      User.count({ where: { status: 'active' } }),

      // Hospital statistics
      Hospital.count(),

      // Appointment statistics
      Appointment.count(),
      Appointment.count({
        where: {
          createdAt: {
            [Op.between]: [startOfMonth, endOfMonth]
          }
        }
      }),

      // Subscription statistics
      Subscription.count(),
      Subscription.count({ where: { status: 'active' } }),

      // Recent activities
      ActivityLog.findAll({
        limit: 10,
        order: [['createdAt', 'DESC']],
        include: [{ model: User, attributes: ['name', 'email'] }]
      })
    ]);

    // Get revenue statistics
    const revenueStats = await this.getRevenueStats();

    // Get user growth trend
    const userGrowth = await this.getUserGrowthTrend();

    // Get appointment distribution
    const appointmentDistribution = await this.getAppointmentDistribution();

    return {
      users: {
        total: totalUsers,
        active: activeUsers,
        growth: userGrowth
      },
      hospitals: {
        total: totalHospitals
      },
      appointments: {
        total: totalAppointments,
        monthly: monthlyAppointments,
        distribution: appointmentDistribution
      },
      subscriptions: {
        total: totalSubscriptions,
        active: activeSubscriptions
      },
      revenue: revenueStats,
      recentActivities
    };
  }

  async getRevenueStats() {
    const today = new Date();
    const startOfYear = new Date(today.getFullYear(), 0, 1);

    // Get monthly revenue
    const monthlyRevenue = await Subscription.findAll({
      where: {
        createdAt: {
          [Op.gte]: startOfYear
        }
      },
      attributes: [
        [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'month'],
        [sequelize.fn('SUM', sequelize.col('amount')), 'total']
      ],
      group: [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt'))],
      order: [[sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'ASC']],
      raw: true
    });

    // Get revenue by plan
    const revenueByPlan = await Subscription.findAll({
      where: {
        status: 'active'
      },
      include: [{ model: Plan, attributes: ['name'] }],
      attributes: [
        'planId',
        [sequelize.fn('SUM', sequelize.col('amount')), 'total']
      ],
      group: ['planId', 'Plan.name'],
      raw: true
    });

    return {
      monthly: monthlyRevenue,
      byPlan: revenueByPlan
    };
  }

  async getUserGrowthTrend() {
    const today = new Date();
    const startOfYear = new Date(today.getFullYear(), 0, 1);

    return await User.findAll({
      where: {
        createdAt: {
          [Op.gte]: startOfYear
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
  }

  async getAppointmentDistribution() {
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

    // Get distribution by status
    const byStatus = await Appointment.findAll({
      where: {
        createdAt: {
          [Op.between]: [startOfMonth, endOfMonth]
        }
      },
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['status'],
      raw: true
    });

    // Get distribution by hospital
    const byHospital = await Appointment.findAll({
      where: {
        createdAt: {
          [Op.between]: [startOfMonth, endOfMonth]
        }
      },
      include: [{ model: Hospital, attributes: ['name'] }],
      attributes: [
        'hospitalId',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['hospitalId', 'Hospital.name'],
      limit: 5,
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']],
      raw: true
    });

    return {
      byStatus,
      byHospital
    };
  }

  // Claims management methods
  async getClaims({ page = 1, limit = 10, status, userId }) {
    const offset = (page - 1) * limit;
    const where = {
      ...(status && { status }),
      ...(userId && { userId })
    };

    const [claims, total] = await Promise.all([
      Claim.findAll({
        where,
        include: [
          { model: User, attributes: ['name', 'email'] },
          { model: Hospital, attributes: ['name'] }
        ],
        limit,
        offset,
        order: [['createdAt', 'DESC']]
      }),
      Claim.count({ where })
    ]);

    return {
      claims,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  async getClaimDetails(id) {
    const claim = await Claim.findByPk(id, {
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Hospital, attributes: ['name'] },
        { model: MedicalRecord }
      ]
    });

    if (!claim) {
      throw new Error('Claim not found');
    }

    return claim;
  }

  async updateClaim(id, data) {
    const claim = await Claim.findByPk(id);

    if (!claim) {
      throw new Error('Claim not found');
    }

    await claim.update({
      status: data.status,
      approvedAmount: data.approvedAmount,
      notes: data.notes,
      processedBy: data.adminId,
      processedAt: new Date()
    });

    return claim;
  }

  // Medical records methods
  async getMedicalRecords({ page = 1, limit = 10, userId, verified }) {
    const offset = (page - 1) * limit;
    const where = {
      ...(userId && { userId }),
      ...(verified !== undefined && { verified })
    };

    const [records, total] = await Promise.all([
      MedicalRecord.findAll({
        where,
        include: [
          { model: User, attributes: ['name', 'email'] },
          { model: Hospital, attributes: ['name'] }
        ],
        limit,
        offset,
        order: [['createdAt', 'DESC']]
      }),
      MedicalRecord.count({ where })
    ]);

    return {
      records,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  async getMedicalRecordDetails(id) {
    const record = await MedicalRecord.findByPk(id, {
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Hospital, attributes: ['name'] }
      ]
    });

    if (!record) {
      throw new Error('Medical record not found');
    }

    return record;
  }

  async verifyMedicalRecord(id, verified, notes) {
    const record = await MedicalRecord.findByPk(id);

    if (!record) {
      throw new Error('Medical record not found');
    }

    await record.update({
      verified,
      verificationNotes: notes,
      verifiedAt: new Date()
    });

    return record;
  }

  // Settings methods
  async getSettings() {
    const settings = await Setting.findAll();
    return settings.reduce((acc, setting) => {
      acc[setting.key] = setting.value;
      return acc;
    }, {});
  }

  async updateSettings(data) {
    const updates = Object.entries(data).map(([key, value]) =>
      Setting.upsert({ key, value })
    );

    await Promise.all(updates);
    return this.getSettings();
  }

  // System health methods
  async getSystemHealth() {
    const metrics = await SystemMetric.findAll({
      where: {
        createdAt: {
          [Op.gte]: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
        }
      },
      order: [['createdAt', 'DESC']],
      raw: true
    });

    return {
      metrics,
      status: this.calculateSystemStatus(metrics)
    };
  }

  calculateSystemStatus(metrics) {
    if (!metrics.length) {
      return 'unknown';
    }

    const latestMetrics = metrics[0];
    const cpuUsage = latestMetrics.cpuUsage || 0;
    const memoryUsage = latestMetrics.memoryUsage || 0;
    const errorRate = latestMetrics.errorRate || 0;

    if (cpuUsage > 90 || memoryUsage > 90 || errorRate > 5) {
      return 'critical';
    }

    if (cpuUsage > 70 || memoryUsage > 70 || errorRate > 1) {
      return 'warning';
    }

    return 'healthy';
  }

  // Admin notifications
  async getAdminNotifications() {
    return await Notification.findAll({
      where: {
        type: {
          [Op.in]: [
            'system_alert',
            'security_alert',
            'payment_alert',
            'user_report'
          ]
        }
      },
      order: [['createdAt', 'DESC']],
      limit: 50
    });
  }
}

module.exports = new AdminService(); 