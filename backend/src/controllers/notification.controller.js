const { User, Notification } = require('../models');
const { Op } = require('sequelize');

// User Notification Functions
exports.getUserNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
      limit: 50
    });
    res.json(notifications);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getUnreadNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: {
        userId: req.user.id,
        isRead: false
      },
      order: [['createdAt', 'DESC']]
    });
    res.json(notifications);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    notification.isRead = true;
    await notification.save();

    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.update(
      { isRead: true },
      {
        where: {
          userId: req.user.id,
          isRead: false
        }
      }
    );

    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteNotification = async (req, res) => {
  try {
    const result = await Notification.destroy({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!result) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification deleted' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Admin Notification Functions
exports.sendNotification = async (req, res) => {
  try {
    const { userId, type, title, message, priority, scheduledFor, data } = req.body;

    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const notification = await Notification.create({
      userId,
      type,
      title,
      message,
      priority: priority || 'medium',
      scheduledFor: scheduledFor || null,
      data: data || {}
    });

    res.status(201).json(notification);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.broadcastNotification = async (req, res) => {
  try {
    const { type, title, message, priority, userFilter } = req.body;

    // Build user filter
    let whereClause = {};
    if (userFilter) {
      if (userFilter.role) whereClause.role = userFilter.role;
      if (userFilter.isActive !== undefined) whereClause.isActive = userFilter.isActive;
    }

    const users = await User.findAll({
      where: whereClause,
      attributes: ['id']
    });

    const notifications = await Promise.all(
      users.map(user =>
        Notification.create({
          userId: user.id,
          type,
          title,
          message,
          priority: priority || 'medium'
        })
      )
    );

    res.status(201).json({
      message: `Notification broadcast to ${notifications.length} users`,
      count: notifications.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getScheduledNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: {
        scheduledFor: {
          [Op.ne]: null,
          [Op.gt]: new Date()
        }
      },
      include: [{
        model: User,
        attributes: ['name', 'email']
      }],
      order: [['scheduledFor', 'ASC']]
    });

    res.json(notifications);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.cancelScheduledNotification = async (req, res) => {
  try {
    const notification = await Notification.findOne({
      where: {
        id: req.params.id,
        scheduledFor: {
          [Op.ne]: null,
          [Op.gt]: new Date()
        }
      }
    });

    if (!notification) {
      return res.status(404).json({ message: 'Scheduled notification not found' });
    }

    await notification.destroy();
    res.json({ message: 'Scheduled notification cancelled' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
}; 