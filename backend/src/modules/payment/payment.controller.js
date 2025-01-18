const { catchAsync } = require('../../utils/catchAsync');
const PaymentService = require('./payment.service');

class PaymentController {
  initializePayment = catchAsync(async (req, res) => {
    const { planId, paymentMethod } = req.body;
    const userId = req.user.id;

    const paymentData = await PaymentService.initializePayment(
      userId,
      planId,
      paymentMethod
    );

    res.status(200).json({
      status: 'success',
      data: paymentData
    });
  });

  verifyPayment = catchAsync(async (req, res) => {
    const { transactionRef } = req.params;
    
    const subscription = await PaymentService.verifyPayment(transactionRef);

    res.status(200).json({
      status: 'success',
      data: subscription
    });
  });

  getBankList = catchAsync(async (req, res) => {
    const banks = await PaymentService.getBankList();

    res.status(200).json({
      status: 'success',
      data: banks
    });
  });

  linkBankAccount = catchAsync(async (req, res) => {
    const { accountNumber, bankCode, bankName } = req.body;
    const userId = req.user.id;

    const bankAccount = await PaymentService.linkBankAccount(userId, {
      accountNumber,
      bankCode,
      bankName
    });

    res.status(201).json({
      status: 'success',
      data: bankAccount
    });
  });

  getPaymentHistory = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { page, limit } = req.query;

    const history = await PaymentService.getPaymentHistory(userId, {
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 10
    });

    res.status(200).json({
      status: 'success',
      data: history
    });
  });

  generateReceipt = catchAsync(async (req, res) => {
    const { paymentId } = req.params;
    
    const receipt = await PaymentService.generateReceipt(paymentId);

    res.status(200).json({
      status: 'success',
      data: receipt
    });
  });

  handleWebhook = catchAsync(async (req, res) => {
    const signature = req.headers['verif-hash'];
    
    if (!signature || signature !== process.env.FLW_WEBHOOK_HASH) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid webhook signature'
      });
    }

    const eventData = req.body;
    
    if (eventData.event === 'charge.completed' && eventData.data.status === 'successful') {
      await PaymentService.handlePaymentSuccess(eventData.data);
    }

    res.status(200).json({
      status: 'success'
    });
  });
}

module.exports = new PaymentController();