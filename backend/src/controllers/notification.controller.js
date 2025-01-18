const notificationService = require('../services/notification.service');
const { catchAsync } = require('../utils/error');

class NotificationController {
  getNotifications = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const filters = {
      read: req.query.read === 'true',
      type: req.query.type,
      startDate: req.query.startDate,
      endDate: req.query.endDate,
      page: req.query.page,
      limit: req.query.limit
    };

    const result = await notificationService.getUserNotifications(userId, filters);
    res.json({
      success: true,
      data: result.notifications,
      pagination: result.pagination
    });
  });

  markAsRead = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    const notification = await notificationService.markAsRead(id, userId);
    res.json({
      success: true,
      data: notification
    });
  });

  markAllAsRead = catchAsync(async (req, res) => {
    const userId = req.user.id;

    await notificationService.markAllAsRead(userId);
    res.json({
      success: true,
      message: 'All notifications marked as read'
    });
  });

  deleteNotification = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    await notificationService.deleteNotification(id, userId);
    res.json({
      success: true,
      message: 'Notification deleted successfully'
    });
  });

  getPreferences = catchAsync(async (req, res) => {
    const userId = req.user.id;

    const preferences = await notificationService.getNotificationPreferences(userId);
    res.json({
      success: true,
      data: preferences
    });
  });

  updatePreferences = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const preferences = {
      email: req.body.email,
      push: req.body.push,
      emailTypes: req.body.emailTypes,
      pushTypes: req.body.pushTypes
    };

    // Validate preferences
    if (preferences.emailTypes && !Array.isArray(preferences.emailTypes)) {
      return res.status(400).json({
        success: false,
        error: 'emailTypes must be an array'
      });
    }

    if (preferences.pushTypes && !Array.isArray(preferences.pushTypes)) {
      return res.status(400).json({
        success: false,
        error: 'pushTypes must be an array'
      });
    }

    const updatedPreferences = await notificationService.updateNotificationPreferences(
      userId,
      preferences
    );

    res.json({
      success: true,
      data: updatedPreferences
    });
  });
}

module.exports = new NotificationController(); 