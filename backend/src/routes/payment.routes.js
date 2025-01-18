const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');
const { authenticate } = require('../middleware/auth');

// Protected routes
router.use(authenticate);

// Initialize payment
router.post('/initialize', paymentController.initializePayment);

// Verify payment
router.get('/verify/:transactionRef', paymentController.verifyPayment);

// Webhook (unprotected)
router.post('/webhook', paymentController.handleWebhook);

module.exports = router; 