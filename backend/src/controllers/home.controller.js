const homeService = require('../services/home.service');
const { catchAsync } = require('../utils/error');

class HomeController {
  getDashboardData = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const dashboardData = await homeService.getDashboardData(userId);
    res.json({
      success: true,
      data: dashboardData
    });
  });

  getRecommendedPlans = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const plans = await homeService.getRecommendedPlans(userId);
    res.json({
      success: true,
      data: plans
    });
  });

  getQuickActions = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const actions = await homeService.getQuickActions(userId);
    res.json({
      success: true,
      data: actions
    });
  });
}

module.exports = new HomeController(); 