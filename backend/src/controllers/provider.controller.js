const providerService = require('../services/provider.service');
const { catchAsync } = require('../utils/error');

class ProviderController {
  getAllProviders = catchAsync(async (req, res) => {
    const filters = {
      name: req.query.name,
      city: req.query.city,
      state: req.query.state,
      rating: req.query.rating ? parseFloat(req.query.rating) : undefined,
      minPlans: req.query.minPlans ? parseFloat(req.query.minPlans) : undefined,
      maxPlans: req.query.maxPlans ? parseFloat(req.query.maxPlans) : undefined,
      page: parseInt(req.query.page) || 1,
      limit: parseInt(req.query.limit) || 10
    };

    const result = await providerService.getAllProviders(filters);
    res.json({
      success: true,
      data: result.providers,
      pagination: result.pagination
    });
  });

  getProviderById = catchAsync(async (req, res) => {
    const { id } = req.params;
    const provider = await providerService.getProviderById(id);
    res.json({
      success: true,
      data: provider
    });
  });

  getProviderReviews = catchAsync(async (req, res) => {
    const { id } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const result = await providerService.getProviderReviews(id, page, limit);
    res.json({
      success: true,
      data: result.reviews,
      pagination: result.pagination
    });
  });

  addProviderReview = catchAsync(async (req, res) => {
    const { id } = req.params;
    const userId = req.user.id;
    const { rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        error: 'Rating must be between 1 and 5'
      });
    }

    const review = await providerService.addProviderReview(id, userId, {
      rating,
      comment
    });

    res.status(201).json({
      success: true,
      data: review
    });
  });

  getProviderPlans = catchAsync(async (req, res) => {
    const { id } = req.params;
    const plans = await providerService.getProviderPlans(id);
    res.json({
      success: true,
      data: plans
    });
  });

  getProviderHospitals = catchAsync(async (req, res) => {
    const { id } = req.params;
    const filters = {
      city: req.query.city,
      state: req.query.state,
      rating: req.query.rating ? parseFloat(req.query.rating) : undefined,
      page: parseInt(req.query.page) || 1,
      limit: parseInt(req.query.limit) || 10
    };

    const result = await providerService.getProviderHospitals(id, filters);
    res.json({
      success: true,
      data: result.hospitals,
      pagination: result.pagination
    });
  });
}

module.exports = new ProviderController(); 