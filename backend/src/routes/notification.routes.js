const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const { authenticate } = require('../middleware/auth');

// All routes require authentication
router.use(authenticate);

// Get user's notifications with filters
router.get('/', notificationController.getNotifications);

// Mark notification as read
router.put('/:id/read', notificationController.markAsRead);

// Mark all notifications as read
router.put('/read-all', notificationController.markAllAsRead);

// Delete notification
router.delete('/:id', notificationController.deleteNotification);

// Get notification preferences
router.get('/preferences', notificationController.getPreferences);

// Update notification preferences
router.put('/preferences', notificationController.updatePreferences);

module.exports = router; 