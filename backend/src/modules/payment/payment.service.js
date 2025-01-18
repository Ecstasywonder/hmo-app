const Flutterwave = require('flutterwave-node-v3');
const { Plan, PlanSubscription, User, Payment, BankAccount } = require('../../models');
const { NotFoundError, PaymentError } = require('../../utils/errors');
const { sendEmail } = require('../../utils/email');

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
      customizations: {
        title: 'HMO Plan Subscription',
        description: `Subscription to ${plan.name} plan`,
        logo: 'https://yourhmoapp.com/logo.png'
      },
      meta: {
        userId,
        planId,
        planName: plan.name
      }
    };

    // Add payment method specific configurations
    switch (paymentMethod) {
      case 'bank_transfer':
        payload.payment_type = 'bank_transfer';
        payload.duration = 2; // Number of hours the transfer details remain valid
        break;
      case 'debit':
        if (!user.bankAccountId) {
          throw new PaymentError('No bank account linked to user');
        }
        const bankAccount = await BankAccount.findByPk(user.bankAccountId);
        payload.debit_account = {
          account_bank: bankAccount.bankCode,
          account_number: bankAccount.accountNumber
        };
        break;
    }

    try {
      const response = await flw.Transaction.initialize(payload);
      
      // Create a pending payment record
      await Payment.create({
        userId,
        planId,
        amount: plan.amount,
        currency: 'NGN',
        paymentMethod,
        transactionRef: payload.tx_ref,
        status: 'pending',
        transferDetails: paymentMethod === 'bank_transfer' ? response.data : null
      });

      return response;
    } catch (error) {
      throw new PaymentError(`Payment initialization failed: ${error.message}`);
    }
  }

  // ... rest of the service methods
}

module.exports = new PaymentService(); 