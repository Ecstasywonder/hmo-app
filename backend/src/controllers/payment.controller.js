const paymentService = require('../services/payment.service');
const { catchAsync } = require('../utils/catchAsync');

class PaymentController {
  initializePayment = catchAsync(async (req, res) => {
    const { planId, paymentMethod } = req.body;
    const userId = req.user.id;

    const paymentData = await paymentService.initializePayment(
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
    
    const payment = await paymentService.verifyPayment(transactionRef);

    res.status(200).json({
      status: 'success',
      data: payment
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
      await paymentService.verifyPayment(eventData.data.id);
    }

    res.status(200).json({
      status: 'success'
    });
  });
}

module.exports = new PaymentController(); 