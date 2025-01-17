const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { Subscription, User, Plan } = require('../models');

class PaymentService {
  async createPaymentIntent(amount, currency = 'usd') {
    return await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency
    });
  }

  async createCustomer(user) {
    const customer = await stripe.customers.create({
      email: user.email,
      name: user.name,
      metadata: {
        userId: user.id
      }
    });

    return customer;
  }

  async attachPaymentMethod(customerId, paymentMethodId) {
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });

    // Set as default payment method
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });
  }

  async createSubscription(userId, planId, paymentMethodId) {
    try {
      const user = await User.findByPk(userId);
      const plan = await Plan.findByPk(planId);

      if (!user || !plan) {
        throw new Error('User or plan not found');
      }

      // Create or get Stripe customer
      let customer;
      if (!user.stripeCustomerId) {
        customer = await this.createCustomer(user);
        user.stripeCustomerId = customer.id;
        await user.save();
      } else {
        customer = await stripe.customers.retrieve(user.stripeCustomerId);
      }

      // Attach payment method if provided
      if (paymentMethodId) {
        await this.attachPaymentMethod(customer.id, paymentMethodId);
      }

      // Create Stripe subscription
      const subscription = await stripe.subscriptions.create({
        customer: customer.id,
        items: [{ price: plan.stripePriceId }],
        payment_behavior: 'default_incomplete',
        expand: ['latest_invoice.payment_intent'],
      });

      // Create local subscription record
      await Subscription.create({
        userId,
        planId,
        stripeSubscriptionId: subscription.id,
        status: 'active',
        startDate: new Date(),
        endDate: new Date(subscription.current_period_end * 1000),
        amount: plan.price
      });

      return subscription;
    } catch (error) {
      console.error('Subscription creation failed:', error);
      throw error;
    }
  }

  async cancelSubscription(subscriptionId) {
    try {
      const subscription = await Subscription.findByPk(subscriptionId);
      if (!subscription) {
        throw new Error('Subscription not found');
      }

      // Cancel on Stripe
      await stripe.subscriptions.cancel(subscription.stripeSubscriptionId);

      // Update local record
      subscription.status = 'cancelled';
      await subscription.save();

      return subscription;
    } catch (error) {
      console.error('Subscription cancellation failed:', error);
      throw error;
    }
  }

  async handleWebhook(event) {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await this.handlePaymentSuccess(event.data.object);
        break;
      case 'payment_intent.payment_failed':
        await this.handlePaymentFailure(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await this.handleSubscriptionCancelled(event.data.object);
        break;
      case 'invoice.payment_succeeded':
        await this.handleInvoicePaid(event.data.object);
        break;
      case 'invoice.payment_failed':
        await this.handleInvoicePaymentFailed(event.data.object);
        break;
    }
  }

  async handlePaymentSuccess(paymentIntent) {
    const subscription = await Subscription.findOne({
      where: { stripePaymentIntentId: paymentIntent.id }
    });
    if (subscription) {
      subscription.paymentStatus = 'completed';
      await subscription.save();
    }
  }

  async handlePaymentFailure(paymentIntent) {
    const subscription = await Subscription.findOne({
      where: { stripePaymentIntentId: paymentIntent.id }
    });
    if (subscription) {
      subscription.paymentStatus = 'failed';
      await subscription.save();
    }
  }

  async handleSubscriptionCancelled(stripeSubscription) {
    const subscription = await Subscription.findOne({
      where: { stripeSubscriptionId: stripeSubscription.id }
    });
    if (subscription) {
      subscription.status = 'cancelled';
      await subscription.save();
    }
  }

  async handleInvoicePaid(invoice) {
    const subscription = await Subscription.findOne({
      where: { stripeSubscriptionId: invoice.subscription }
    });
    if (subscription) {
      subscription.lastRenewalDate = new Date();
      subscription.nextRenewalDate = new Date(invoice.lines.data[0].period.end * 1000);
      await subscription.save();
    }
  }

  async handleInvoicePaymentFailed(invoice) {
    const subscription = await Subscription.findOne({
      where: { stripeSubscriptionId: invoice.subscription }
    });
    if (subscription) {
      subscription.paymentStatus = 'failed';
      await subscription.save();
    }
  }
}

module.exports = new PaymentService(); 