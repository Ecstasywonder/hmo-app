const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const validateRequest = require('../middleware/validate-request');
const auth = require('../middleware/auth');
const securityService = require('../services/security.service');

const router = express.Router();

// Register user
router.post(
  '/register',
  [
    body('email').isEmail().withMessage('Enter a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    body('name').notEmpty().withMessage('Name is required'),
    validateRequest
  ],
  authController.register
);

// Login user
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Enter a valid email'),
    body('password').notEmpty().withMessage('Password is required'),
    validateRequest
  ],
  securityService.loginLimiter,
  authController.login
);

// Refresh token
router.post(
  '/refresh-token',
  [
    body('refreshToken').notEmpty().withMessage('Refresh token is required'),
    validateRequest
  ],
  authController.refreshToken
);

// Logout user
router.post('/logout', auth, authController.logout);

// Get current user
router.get('/me', auth, authController.getCurrentUser);

// Update user profile
router.put(
  '/profile',
  auth,
  [
    body('email').optional().isEmail().withMessage('Enter a valid email'),
    body('name').optional().notEmpty().withMessage('Name cannot be empty'),
    body('phone').optional().notEmpty().withMessage('Phone cannot be empty'),
    validateRequest
  ],
  authController.updateProfile
);

module.exports = router; 