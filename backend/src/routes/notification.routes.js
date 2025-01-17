const express = require('express');
const { body } = require('express-validator');
const notificationController = require('../controllers/notification.controller');
const validateRequest = require('../middleware/validate-request');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');

const router = express.Router();

// User notification routes
router.get('/user', auth, notificationController.getUserNotifications);
router.get('/user/unread', auth, notificationController.getUnreadNotifications);
router.put('/user/:id/read', auth, notificationController.markAsRead);
router.put('/user/read-all', auth, notificationController.markAllAsRead);
router.delete('/user/:id', auth, notificationController.deleteNotification);

// Admin notification routes
router.post(
  '/send',
  [
    auth,
    admin,
    body('userId').isUUID().withMessage('Valid user ID is required'),
    body('type').isIn([
      'appointment_reminder',
      'subscription_expiry',
      'payment_due',
      'plan_update',
      'system_notification'
    ]).withMessage('Invalid notification type'),
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('message').trim().notEmpty().withMessage('Message is required'),
    body('priority').optional().isIn(['low', 'medium', 'high']),
    body('scheduledFor').optional().isISO8601(),
    validateRequest
  ],
  notificationController.sendNotification
);

router.post(
  '/broadcast',
  [
    auth,
    admin,
    body('type').isIn([
      'appointment_reminder',
      'subscription_expiry',
      'payment_due',
      'plan_update',
      'system_notification'
    ]).withMessage('Invalid notification type'),
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('message').trim().notEmpty().withMessage('Message is required'),
    body('priority').optional().isIn(['low', 'medium', 'high']),
    body('userFilter').optional().isObject(),
    validateRequest
  ],
  notificationController.broadcastNotification
);

// Scheduled notifications
router.get('/scheduled', [auth, admin], notificationController.getScheduledNotifications);
router.delete('/scheduled/:id', [auth, admin], notificationController.cancelScheduledNotification);

module.exports = router; 