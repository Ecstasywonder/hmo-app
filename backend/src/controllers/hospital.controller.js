const hospitalService = require('../services/hospital.service');
const { catchAsync } = require('../utils/error');

class HospitalController {
  searchHospitals = catchAsync(async (req, res) => {
    const filters = {
      name: req.query.name,
      city: req.query.city,
      state: req.query.state,
      specialty: req.query.specialty,
      rating: req.query.rating,
      planId: req.query.planId,
      page: req.query.page,
      limit: req.query.limit
    };

    const result = await hospitalService.searchHospitals(filters);
    res.json({
      success: true,
      data: result.hospitals,
      pagination: result.pagination
    });
  });

  getHospitalDetails = catchAsync(async (req, res) => {
    const { id } = req.params;
    const hospital = await hospitalService.getHospitalDetails(id);
    res.json({
      success: true,
      data: hospital
    });
  });

  getHospitalSchedule = catchAsync(async (req, res) => {
    const { id } = req.params;
    const date = req.query.date ? new Date(req.query.date) : new Date();

    if (isNaN(date.getTime())) {
      return res.status(400).json({
        success: false,
        error: 'Invalid date format'
      });
    }

    const schedule = await hospitalService.getHospitalSchedule(id, date);
    res.json({
      success: true,
      data: schedule
    });
  });

  getHospitalReviews = catchAsync(async (req, res) => {
    const { id } = req.params;
    const { page, limit } = req.query;

    const result = await hospitalService.getHospitalReviews(id, page, limit);
    res.json({
      success: true,
      data: result.reviews,
      pagination: result.pagination
    });
  });

  addHospitalReview = catchAsync(async (req, res) => {
    const { id } = req.params;
    const userId = req.user.id;
    const { rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        error: 'Rating must be between 1 and 5'
      });
    }

    const review = await hospitalService.addHospitalReview(id, userId, {
      rating,
      comment
    });

    res.status(201).json({
      success: true,
      data: review
    });
  });
}

module.exports = new HospitalController(); 