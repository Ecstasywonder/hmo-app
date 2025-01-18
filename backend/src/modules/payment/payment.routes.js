const express = require('express');
const router = express.Router();
const PaymentController = require('./payment.controller');
const { authenticate } = require('../../middleware/auth');
const { validatePayment } = require('./payment.validation');

// Protected routes
router.use(authenticate);

// Initialize payment
router.post(
  '/initialize',
  validatePayment.initialize,
  PaymentController.initializePayment
);

// Verify payment
router.get(
  '/verify/:transactionRef',
  validatePayment.verify,
  PaymentController.verifyPayment
);

// Bank operations
router.get('/banks', PaymentController.getBankList);
router.post(
  '/bank-accounts',
  validatePayment.bankAccount,
  PaymentController.linkBankAccount
);

// Payment history and receipts
router.get('/history', PaymentController.getPaymentHistory);
router.get(
  '/receipt/:paymentId',
  validatePayment.receipt,
  PaymentController.generateReceipt
);

// Webhook (unprotected)
router.post('/webhook', PaymentController.handleWebhook);

module.exports = router;