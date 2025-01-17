const { Plan, User, Subscription } = require('../models');

exports.getAllPlans = async (req, res) => {
  try {
    const plans = await Plan.findAll({
      where: { isActive: true },
      attributes: ['id', 'name', 'description', 'price', 'duration', 'benefits']
    });
    res.json(plans);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getPlanById = async (req, res) => {
  try {
    const plan = await Plan.findByPk(req.params.id);
    if (!plan) {
      return res.status(404).json({ message: 'Plan not found' });
    }
    res.json(plan);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.createPlan = async (req, res) => {
  try {
    const { name, description, price, duration, benefits } = req.body;
    const plan = await Plan.create({
      name,
      description,
      price,
      duration,
      benefits,
      isActive: true
    });
    res.status(201).json(plan);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updatePlan = async (req, res) => {
  try {
    const plan = await Plan.findByPk(req.params.id);
    if (!plan) {
      return res.status(404).json({ message: 'Plan not found' });
    }

    const { name, description, price, duration, benefits, isActive } = req.body;
    
    // Update plan fields
    plan.name = name || plan.name;
    plan.description = description || plan.description;
    plan.price = price || plan.price;
    plan.duration = duration || plan.duration;
    plan.benefits = benefits || plan.benefits;
    plan.isActive = isActive !== undefined ? isActive : plan.isActive;

    await plan.save();
    res.json(plan);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deletePlan = async (req, res) => {
  try {
    const plan = await Plan.findByPk(req.params.id);
    if (!plan) {
      return res.status(404).json({ message: 'Plan not found' });
    }

    // Soft delete by setting isActive to false
    plan.isActive = false;
    await plan.save();
    
    res.json({ message: 'Plan deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.subscribeToPlan = async (req, res) => {
  try {
    const { planId } = req.params;
    const userId = req.user.id;

    // Check if plan exists and is active
    const plan = await Plan.findOne({
      where: { id: planId, isActive: true }
    });

    if (!plan) {
      return res.status(404).json({ message: 'Plan not found or inactive' });
    }

    // Check if user already has an active subscription to this plan
    const existingSubscription = await Subscription.findOne({
      where: {
        userId,
        planId,
        status: 'active'
      }
    });

    if (existingSubscription) {
      return res.status(400).json({ message: 'Already subscribed to this plan' });
    }

    // Create new subscription
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + plan.duration);

    const subscription = await Subscription.create({
      userId,
      planId,
      startDate,
      endDate,
      status: 'active',
      amount: plan.price
    });

    res.status(201).json({
      message: 'Successfully subscribed to plan',
      subscription
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
}; 