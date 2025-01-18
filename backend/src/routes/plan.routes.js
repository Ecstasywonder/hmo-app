const express = require('express');
const router = express.Router();
const planController = require('../controllers/plan.controller');
const { authenticate } = require('../middleware/auth');

// Public routes
router.get('/', planController.getAllPlans);
router.get('/:id', planController.getPlanById);
router.get('/:id/benefits', planController.getPlanBenefits);

// Protected routes - require authentication
router.use(authenticate);
router.post('/compare', planController.comparePlans);
router.post('/subscribe', planController.subscribeToPlan);
router.get('/user/history', planController.getSubscriptionHistory);

module.exports = router; 