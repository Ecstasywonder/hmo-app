const Flutterwave = require('flutterwave-node-v3');
const { Plan, User, Payment } = require('../../models');
const { NotFoundError, PaymentError } = require('../../utils/errors');

const flw = new Flutterwave(process.env.FLW_PUBLIC_KEY, process.env.FLW_SECRET_KEY);

class PaymentService {
  async initializePayment(userId, planId, paymentMethod = 'card') {
    const user = await User.findByPk(userId);
    const plan = await Plan.findByPk(planId);
    
    if (!plan) throw new NotFoundError('Plan not found');

    const payload = {
      tx_ref: `plan_${planId}_${Date.now()}`,
      amount: plan.amount,
      currency: 'NGN',
      payment_type: paymentMethod,
      customer: {
        email: user.email,
        name: user.name,
        phonenumber: user.phone
      },
      meta: { userId, planId }
    };

    try {
      const response = await flw.Transaction.initialize(payload);
      await Payment.create({
        userId,
        planId,
        amount: plan.amount,
        currency: 'NGN',
        paymentMethod,
        transactionRef: payload.tx_ref,
        status: 'pending'
      });
      return response;
    } catch (error) {
      throw new PaymentError(`Payment initialization failed: ${error.message}`);
    }
  }

  async verifyPayment(transactionRef) {
    try {
      const response = await flw.Transaction.verify({ id: transactionRef });
      if (response.data.status === 'successful') {
        const payment = await Payment.findOne({ where: { transactionRef } });
        if (!payment) throw new NotFoundError('Payment record not found');
        await payment.update({ status: 'completed' });
        return payment;
      }
      throw new PaymentError('Payment verification failed');
    } catch (error) {
      throw new PaymentError(`Payment verification failed: ${error.message}`);
    }
  }
}

module.exports = new PaymentService(); 