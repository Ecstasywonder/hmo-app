const express = require('express');
const { body } = require('express-validator');
const planController = require('../controllers/plan.controller');
const validateRequest = require('../middleware/validate-request');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');

const router = express.Router();

// Public routes
router.get('/', planController.getAllPlans);
router.get('/:id', planController.getPlanById);

// Protected routes (requires authentication)
router.post(
  '/subscribe/:planId',
  auth,
  planController.subscribeToPlan
);

// Admin routes
router.post(
  '/',
  [
    auth,
    admin,
    body('name').notEmpty().withMessage('Plan name is required'),
    body('description').notEmpty().withMessage('Plan description is required'),
    body('price').isNumeric().withMessage('Price must be a number'),
    body('duration').isNumeric().withMessage('Duration must be a number'),
    body('benefits').isArray().withMessage('Benefits must be an array'),
    validateRequest
  ],
  planController.createPlan
);

router.put(
  '/:id',
  [
    auth,
    admin,
    body('name').optional(),
    body('description').optional(),
    body('price').optional().isNumeric().withMessage('Price must be a number'),
    body('duration').optional().isNumeric().withMessage('Duration must be a number'),
    body('benefits').optional().isArray().withMessage('Benefits must be an array'),
    validateRequest
  ],
  planController.updatePlan
);

router.delete('/:id', [auth, admin], planController.deletePlan);

module.exports = router; 