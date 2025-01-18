const express = require('express');
const router = express.Router();
const PaymentController = require('./controller');
const { authenticate } = require('../../middleware/auth');

// Protected routes
router.use(authenticate);

// Initialize payment
router.post('/initialize', PaymentController.initializePayment);

// Verify payment
router.get('/verify/:transactionRef', PaymentController.verifyPayment);

// Webhook (unprotected)
router.post('/webhook', PaymentController.handleWebhook);

module.exports = router; 