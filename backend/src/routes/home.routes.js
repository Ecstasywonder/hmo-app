const express = require('express');
const router = express.Router();
const homeController = require('../controllers/home.controller');
const { authenticate } = require('../middleware/auth');

// Apply authentication middleware to all routes
router.use(authenticate);

// Get dashboard data including user info, active plan, and quick stats
router.get('/dashboard', homeController.getDashboardData);

// Get recommended plans based on user's current plan
router.get('/recommended-plans', homeController.getRecommendedPlans);

// Get quick actions data (pending appointments, notifications, etc.)
router.get('/quick-actions', homeController.getQuickActions);

module.exports = router; 