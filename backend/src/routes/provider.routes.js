const express = require('express');
const router = express.Router();
const providerController = require('../controllers/provider.controller');
const { authenticate } = require('../middleware/auth');
const { validateReview } = require('../middleware/validation');

// Public routes
router.get('/', providerController.getAllProviders);
router.get('/:id', providerController.getProviderById);
router.get('/:id/plans', providerController.getProviderPlans);
router.get('/:id/hospitals', providerController.getProviderHospitals);
router.get('/:id/reviews', providerController.getProviderReviews);

// Protected routes
router.post('/:id/reviews', authenticate, validateReview, providerController.addProviderReview);

module.exports = router; 