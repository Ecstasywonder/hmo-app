const { User, Subscription, Appointment, ActivityLog, LoginAttempt } = require('../models');
const { Op } = require('sequelize');
const emailService = require('./email.service');
const cron = require('node-cron');

class MonitoringService {
  constructor() {
    this.initializeScheduledTasks();
  }

  initializeScheduledTasks() {
    // Daily tasks
    cron.schedule('0 0 * * *', () => this.runDailyMaintenance());
    
    // Hourly tasks
    cron.schedule('0 * * * *', () => this.runHourlyChecks());
    
    // Weekly tasks
    cron.schedule('0 0 * * 0', () => this.runWeeklyMaintenance());
    
    // Every 5 minutes
    cron.schedule('*/5 * * * *', () => this.checkSystemHealth());
  }

  async runDailyMaintenance() {
    try {
      await Promise.all([
        this.cleanupOldLogs(),
        this.checkExpiredSubscriptions(),
        this.sendAppointmentReminders(),
        this.generateDailyReport(),
        this.cleanupUnverifiedAccounts()
      ]);
    } catch (error) {
      console.error('Daily maintenance failed:', error);
      await this.notifyAdmins('Daily Maintenance Failed', error.message);
    }
  }

  async runHourlyChecks() {
    try {
      await Promise.all([
        this.checkDatabaseConnections(),
        this.monitorAPIPerformance(),
        this.checkStorageUsage(),
        this.updateSystemMetrics()
      ]);
    } catch (error) {
      console.error('Hourly checks failed:', error);
      await this.notifyAdmins('Hourly Checks Failed', error.message);
    }
  }

  async runWeeklyMaintenance() {
    try {
      await Promise.all([
        this.generateWeeklyReport(),
        this.archiveOldData(),
        this.optimizeDatabases(),
        this.checkSecurityUpdates()
      ]);
    } catch (error) {
      console.error('Weekly maintenance failed:', error);
      await this.notifyAdmins('Weekly Maintenance Failed', error.message);
    }
  }

  async checkSystemHealth() {
    const metrics = {
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      uptime: process.uptime(),
      timestamp: new Date()
    };

    // Check if metrics exceed thresholds
    if (metrics.memory.heapUsed > 1024 * 1024 * 1024) { // 1GB
      await this.notifyAdmins('High Memory Usage', JSON.stringify(metrics.memory));
    }

    return metrics;
  }

  async cleanupOldLogs() {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    
    await Promise.all([
      ActivityLog.destroy({
        where: {
          createdAt: { [Op.lt]: thirtyDaysAgo }
        }
      }),
      LoginAttempt.destroy({
        where: {
          createdAt: { [Op.lt]: thirtyDaysAgo }
        }
      })
    ]);
  }

  async checkExpiredSubscriptions() {
    const expiredSubscriptions = await Subscription.findAll({
      where: {
        status: 'active',
        endDate: { [Op.lt]: new Date() }
      },
      include: [{ model: User }]
    });

    for (const subscription of expiredSubscriptions) {
      subscription.status = 'expired';
      await subscription.save();

      // Notify user
      await emailService.transporter.sendMail({
        to: subscription.User.email,
        subject: 'Subscription Expired',
        html: `Your subscription has expired. Please renew to continue accessing our services.`
      });
    }
  }

  async sendAppointmentReminders() {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);

    const appointments = await Appointment.findAll({
      where: {
        date: tomorrow,
        status: 'confirmed'
      },
      include: [
        { model: User },
        { model: Hospital }
      ]
    });

    for (const appointment of appointments) {
      await emailService.transporter.sendMail({
        to: appointment.User.email,
        subject: 'Appointment Reminder',
        html: `
          <h2>Appointment Reminder</h2>
          <p>This is a reminder for your appointment tomorrow at ${appointment.time} with ${appointment.Hospital.name}.</p>
          <p>Please arrive 15 minutes before your scheduled time.</p>
        `
      });
    }
  }

  async cleanupUnverifiedAccounts() {
    const twoDaysAgo = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000);
    
    await User.destroy({
      where: {
        isEmailVerified: false,
        createdAt: { [Op.lt]: twoDaysAgo }
      }
    });
  }

  async checkDatabaseConnections() {
    try {
      await Promise.all([
        this.sequelize.authenticate(),
        this.redisClient.ping()
      ]);
    } catch (error) {
      await this.notifyAdmins('Database Connection Error', error.message);
      throw error;
    }
  }

  async monitorAPIPerformance() {
    // Implement API performance monitoring logic
    // This could include checking response times, error rates, etc.
  }

  async checkStorageUsage() {
    // Implement storage usage monitoring
    // This could include checking disk space, file counts, etc.
  }

  async updateSystemMetrics() {
    const metrics = await this.collectSystemMetrics();
    await this.storeMetrics(metrics);
  }

  async generateWeeklyReport() {
    const report = await this.generateSystemReport('weekly');
    await this.notifyAdmins('Weekly System Report', report);
  }

  async archiveOldData() {
    // Implement data archiving logic
    // This could include moving old records to archive tables
  }

  async optimizeDatabases() {
    // Implement database optimization logic
    // This could include running VACUUM, analyzing tables, etc.
  }

  async checkSecurityUpdates() {
    // Implement security update checks
    // This could include checking for package updates, security advisories, etc.
  }

  async notifyAdmins(subject, message) {
    const admins = await User.findAll({
      where: { role: 'admin' }
    });

    for (const admin of admins) {
      await emailService.transporter.sendMail({
        to: admin.email,
        subject: `[System Alert] ${subject}`,
        html: `
          <h2>${subject}</h2>
          <pre>${message}</pre>
          <p>Time: ${new Date().toISOString()}</p>
        `
      });
    }
  }

  async collectSystemMetrics() {
    return {
      activeUsers: await User.count({ where: { isActive: true } }),
      activeSubscriptions: await Subscription.count({ where: { status: 'active' } }),
      pendingAppointments: await Appointment.count({ where: { status: 'pending' } }),
      systemLoad: process.cpuUsage(),
      memoryUsage: process.memoryUsage(),
      timestamp: new Date()
    };
  }

  async storeMetrics(metrics) {
    // Implement metric storage logic
    // This could include storing in a time-series database or analytics platform
  }

  async generateSystemReport(period) {
    // Implement report generation logic
    // This could include aggregating metrics, generating charts, etc.
  }
}

module.exports = new MonitoringService(); 