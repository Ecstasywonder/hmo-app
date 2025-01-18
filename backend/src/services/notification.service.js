const { Notification, NotificationPreference, User } = require('../models');
const { Op } = require('sequelize');
const { sendEmail } = require('../utils/email');
// const { sendPushNotification } = require('../utils/push-notification'); // TODO: Implement push notifications

class NotificationService {
  async getUserNotifications(userId, filters = {}) {
    try {
      const {
        read,
        type,
        startDate,
        endDate,
        page = 1,
        limit = 20
      } = filters;

      const where = { userId };

      if (read !== undefined) {
        where.read = read;
      }

      if (type) {
        where.type = type;
      }

      if (startDate && endDate) {
        where.createdAt = {
          [Op.between]: [new Date(startDate), new Date(endDate)]
        };
      }

      const offset = (page - 1) * limit;

      const { rows: notifications, count } = await Notification.findAndCountAll({
        where,
        order: [['createdAt', 'DESC']],
        limit,
        offset
      });

      return {
        notifications,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error fetching notifications: ${error.message}`);
    }
  }

  async createNotification(data) {
    try {
      const {
        userId,
        type,
        title,
        message,
        data: notificationData,
        priority = 'normal'
      } = data;

      // Get user's notification preferences
      const preferences = await NotificationPreference.findOne({
        where: { userId }
      });

      // Create notification record
      const notification = await Notification.create({
        userId,
        type,
        title,
        message,
        data: notificationData,
        priority,
        read: false
      });

      // Send notifications based on user preferences
      if (preferences) {
        if (preferences.email && preferences.emailTypes.includes(type)) {
          await this._sendEmailNotification(userId, notification);
        }

        if (preferences.push && preferences.pushTypes.includes(type)) {
          await this._sendPushNotification(userId, notification);
        }
      }

      return notification;
    } catch (error) {
      throw new Error(`Error creating notification: ${error.message}`);
    }
  }

  async markAsRead(notificationId, userId) {
    try {
      const notification = await Notification.findOne({
        where: {
          id: notificationId,
          userId
        }
      });

      if (!notification) {
        throw new Error('Notification not found');
      }

      await notification.update({ read: true });
      return notification;
    } catch (error) {
      throw new Error(`Error marking notification as read: ${error.message}`);
    }
  }

  async markAllAsRead(userId) {
    try {
      await Notification.update(
        { read: true },
        {
          where: {
            userId,
            read: false
          }
        }
      );

      return true;
    } catch (error) {
      throw new Error(`Error marking all notifications as read: ${error.message}`);
    }
  }

  async deleteNotification(notificationId, userId) {
    try {
      const notification = await Notification.findOne({
        where: {
          id: notificationId,
          userId
        }
      });

      if (!notification) {
        throw new Error('Notification not found');
      }

      await notification.destroy();
      return true;
    } catch (error) {
      throw new Error(`Error deleting notification: ${error.message}`);
    }
  }

  async getNotificationPreferences(userId) {
    try {
      const preferences = await NotificationPreference.findOne({
        where: { userId }
      });

      if (!preferences) {
        // Create default preferences if none exist
        return this.updateNotificationPreferences(userId, {
          email: true,
          push: true,
          emailTypes: ['appointment', 'medical_record', 'prescription', 'billing'],
          pushTypes: ['appointment', 'medical_record', 'prescription', 'billing']
        });
      }

      return preferences;
    } catch (error) {
      throw new Error(`Error fetching notification preferences: ${error.message}`);
    }
  }

  async updateNotificationPreferences(userId, preferences) {
    try {
      const {
        email,
        push,
        emailTypes,
        pushTypes
      } = preferences;

      const [userPreferences] = await NotificationPreference.upsert({
        userId,
        email,
        push,
        emailTypes,
        pushTypes
      });

      return userPreferences;
    } catch (error) {
      throw new Error(`Error updating notification preferences: ${error.message}`);
    }
  }

  // Private helper methods
  async _sendEmailNotification(userId, notification) {
    try {
      const user = await User.findByPk(userId);
      if (!user || !user.email) return;

      await sendEmail({
        to: user.email,
        subject: notification.title,
        template: 'notification',
        data: {
          userName: user.firstName,
          title: notification.title,
          message: notification.message,
          actionUrl: this._getActionUrl(notification)
        }
      });
    } catch (error) {
      console.error('Error sending email notification:', error);
    }
  }

  async _sendPushNotification(userId, notification) {
    try {
      const user = await User.findByPk(userId);
      if (!user || !user.pushToken) return;

      // TODO: Implement push notification sending
      // await sendPushNotification({
      //   token: user.pushToken,
      //   title: notification.title,
      //   body: notification.message,
      //   data: notification.data
      // });
    } catch (error) {
      console.error('Error sending push notification:', error);
    }
  }

  _getActionUrl(notification) {
    // Generate appropriate URL based on notification type and data
    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
    
    switch (notification.type) {
      case 'appointment':
        return `${baseUrl}/appointments/${notification.data?.appointmentId}`;
      case 'medical_record':
        return `${baseUrl}/medical-records/${notification.data?.recordId}`;
      case 'prescription':
        return `${baseUrl}/prescriptions/${notification.data?.prescriptionId}`;
      case 'billing':
        return `${baseUrl}/billing/${notification.data?.billId}`;
      default:
        return baseUrl;
    }
  }
}

module.exports = new NotificationService(); 