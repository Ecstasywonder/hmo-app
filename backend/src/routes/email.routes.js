const express = require('express');
const { body } = require('express-validator');
const emailController = require('../controllers/email.controller');
const validateRequest = require('../middleware/validate-request');
const auth = require('../middleware/auth');

const router = express.Router();

// Email verification routes
router.post(
  '/verify/send',
  [
    auth,
    validateRequest
  ],
  emailController.sendVerificationEmail
);

router.post(
  '/verify/:token',
  [
    body('token').notEmpty().withMessage('Token is required'),
    validateRequest
  ],
  emailController.verifyEmail
);

// Password reset routes
router.post(
  '/password-reset/request',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    validateRequest
  ],
  emailController.requestPasswordReset
);

router.post(
  '/password-reset/verify',
  [
    body('token').notEmpty().withMessage('Token is required'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters')
      .matches(/\d/)
      .withMessage('Password must contain a number'),
    validateRequest
  ],
  emailController.resetPassword
);

// Email preferences
router.put(
  '/preferences',
  [
    auth,
    body('marketingEmails').optional().isBoolean(),
    body('appointmentReminders').optional().isBoolean(),
    body('subscriptionAlerts').optional().isBoolean(),
    validateRequest
  ],
  emailController.updateEmailPreferences
);

// Admin email routes
router.post(
  '/admin/broadcast',
  [
    auth,
    body('subject').notEmpty().withMessage('Subject is required'),
    body('content').notEmpty().withMessage('Content is required'),
    body('userFilter').optional().isObject(),
    validateRequest
  ],
  emailController.broadcastEmail
);

module.exports = router; 