const planService = require('../services/plan.service');
const { catchAsync } = require('../utils/error');

class PlanController {
  getAllPlans = catchAsync(async (req, res) => {
    const filters = {
      minPrice: req.query.minPrice,
      maxPrice: req.query.maxPrice,
      coverage: req.query.coverage
    };

    const plans = await planService.getAllPlans(filters);
    res.json({
      success: true,
      data: plans
    });
  });

  getPlanById = catchAsync(async (req, res) => {
    const { id } = req.params;
    const plan = await planService.getPlanById(id);
    res.json({
      success: true,
      data: plan
    });
  });

  comparePlans = catchAsync(async (req, res) => {
    const { planIds } = req.body;
    
    if (!planIds || !Array.isArray(planIds) || planIds.length < 2) {
      return res.status(400).json({
        success: false,
        error: 'Please provide at least two plan IDs for comparison'
      });
    }

    const comparisonData = await planService.comparePlans(planIds);
    res.json({
      success: true,
      data: comparisonData
    });
  });

  subscribeToPlan = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { planId, paymentDetails } = req.body;

    if (!planId || !paymentDetails) {
      return res.status(400).json({
        success: false,
        error: 'Plan ID and payment details are required'
      });
    }

    const subscription = await planService.subscribeToPlan(userId, planId, paymentDetails);
    res.json({
      success: true,
      data: subscription
    });
  });

  getSubscriptionHistory = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const history = await planService.getUserSubscriptionHistory(userId);
    res.json({
      success: true,
      data: history
    });
  });

  getPlanBenefits = catchAsync(async (req, res) => {
    const { id } = req.params;
    const benefits = await planService.getPlanBenefits(id);
    res.json({
      success: true,
      data: benefits
    });
  });
}

module.exports = new PlanController(); 