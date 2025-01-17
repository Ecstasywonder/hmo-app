const { User } = require('../models');
const emailService = require('./email.service');
const webpush = require('web-push');

// Configure web-push
webpush.setVapidDetails(
  'mailto:support@carelinkhmo.com',
  process.env.VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
);

class NotificationService {
  constructor() {
    this.notificationTypes = {
      APPOINTMENT_REMINDER: 'appointment_reminder',
      APPOINTMENT_CONFIRMATION: 'appointment_confirmation',
      APPOINTMENT_CANCELLATION: 'appointment_cancellation',
      SUBSCRIPTION_EXPIRING: 'subscription_expiring',
      SUBSCRIPTION_PAYMENT_FAILED: 'subscription_payment_failed',
      ACCOUNT_UPDATE: 'account_update',
      SECURITY_ALERT: 'security_alert',
      SYSTEM_MAINTENANCE: 'system_maintenance'
    };
  }

  async sendNotification(userId, type, data) {
    const user = await User.findByPk(userId);
    
    if (!user) {
      throw new Error('User not found');
    }

    // Prepare notification content
    const content = this.prepareNotificationContent(type, data);

    // Send notifications through all enabled channels
    await Promise.all([
      this.sendPushNotification(user, content),
      this.sendEmailNotification(user, content),
      this.saveNotificationToDatabase(user, content)
    ]);

    return true;
  }

  async sendBulkNotifications(userIds, type, data) {
    const users = await User.findAll({
      where: {
        id: userIds
      }
    });

    const content = this.prepareNotificationContent(type, data);

    // Send notifications in batches to avoid overwhelming the system
    const batchSize = 100;
    for (let i = 0; i < users.length; i += batchSize) {
      const batch = users.slice(i, i + batchSize);
      await Promise.all(
        batch.map(user =>
          Promise.all([
            this.sendPushNotification(user, content),
            this.sendEmailNotification(user, content),
            this.saveNotificationToDatabase(user, content)
          ])
        )
      );
    }

    return true;
  }

  prepareNotificationContent(type, data) {
    let title, message, action;

    switch (type) {
      case this.notificationTypes.APPOINTMENT_REMINDER:
        title = 'Appointment Reminder';
        message = `Your appointment with ${data.hospitalName} is scheduled for ${data.date} at ${data.time}`;
        action = `/appointments/${data.appointmentId}`;
        break;

      case this.notificationTypes.APPOINTMENT_CONFIRMATION:
        title = 'Appointment Confirmed';
        message = `Your appointment with ${data.hospitalName} has been confirmed`;
        action = `/appointments/${data.appointmentId}`;
        break;

      case this.notificationTypes.APPOINTMENT_CANCELLATION:
        title = 'Appointment Cancelled';
        message = `Your appointment with ${data.hospitalName} has been cancelled`;
        action = '/appointments';
        break;

      case this.notificationTypes.SUBSCRIPTION_EXPIRING:
        title = 'Subscription Expiring Soon';
        message = `Your subscription will expire in ${data.daysLeft} days. Please renew to continue enjoying our services.`;
        action = '/subscription';
        break;

      case this.notificationTypes.SUBSCRIPTION_PAYMENT_FAILED:
        title = 'Payment Failed';
        message = 'Your subscription payment has failed. Please update your payment method.';
        action = '/billing';
        break;

      case this.notificationTypes.ACCOUNT_UPDATE:
        title = 'Account Updated';
        message = `Your account ${data.field} has been updated successfully`;
        action = '/profile';
        break;

      case this.notificationTypes.SECURITY_ALERT:
        title = 'Security Alert';
        message = data.message;
        action = '/security';
        break;

      case this.notificationTypes.SYSTEM_MAINTENANCE:
        title = 'System Maintenance';
        message = 'The system will undergo maintenance. Some services may be unavailable.';
        action = '/status';
        break;

      default:
        title = 'Notification';
        message = data.message;
        action = '/';
    }

    return {
      type,
      title,
      message,
      action,
      timestamp: new Date(),
      data
    };
  }

  async sendPushNotification(user, content) {
    if (!user.pushSubscription) {
      return;
    }

    try {
      await webpush.sendNotification(
        user.pushSubscription,
        JSON.stringify({
          title: content.title,
          body: content.message,
          icon: '/icon.png',
          badge: '/badge.png',
          data: {
            action: content.action
          }
        })
      );
    } catch (error) {
      console.error('Push notification failed:', error);
      // If subscription is invalid, remove it
      if (error.statusCode === 410) {
        await user.update({ pushSubscription: null });
      }
    }
  }

  async sendEmailNotification(user, content) {
    if (!user.emailNotificationsEnabled) {
      return;
    }

    await emailService.transporter.sendMail({
      to: user.email,
      subject: content.title,
      html: `
        <h2>${content.title}</h2>
        <p>${content.message}</p>
        <p>Click <a href="${process.env.FRONTEND_URL}${content.action}">here</a> to view details.</p>
      `
    });
  }

  async saveNotificationToDatabase(user, content) {
    await user.createNotification({
      type: content.type,
      title: content.title,
      message: content.message,
      action: content.action,
      data: content.data,
      read: false
    });
  }

  async subscribeToPushNotifications(userId, subscription) {
    const user = await User.findByPk(userId);
    
    if (!user) {
      throw new Error('User not found');
    }

    await user.update({
      pushSubscription: subscription
    });

    return true;
  }

  async unsubscribeFromPushNotifications(userId) {
    const user = await User.findByPk(userId);
    
    if (!user) {
      throw new Error('User not found');
    }

    await user.update({
      pushSubscription: null
    });

    return true;
  }

  async markNotificationAsRead(userId, notificationId) {
    const notification = await Notification.findOne({
      where: {
        id: notificationId,
        userId
      }
    });

    if (!notification) {
      throw new Error('Notification not found');
    }

    await notification.update({
      read: true,
      readAt: new Date()
    });

    return notification;
  }

  async getUserNotifications(userId, filters = {}) {
    return await Notification.findAll({
      where: {
        userId,
        ...(filters.read !== undefined && { read: filters.read }),
        ...(filters.type && { type: filters.type })
      },
      order: [['createdAt', 'DESC']],
      limit: filters.limit || 50,
      offset: filters.offset || 0
    });
  }

  async clearUserNotifications(userId) {
    await Notification.destroy({
      where: {
        userId,
        read: true
      }
    });

    return true;
  }
}

module.exports = new NotificationService(); 