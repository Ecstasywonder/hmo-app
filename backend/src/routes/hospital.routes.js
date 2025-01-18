const express = require('express');
const router = express.Router();
const hospitalController = require('../controllers/hospital.controller');
const { authenticate } = require('../middleware/auth');

// Public routes
router.get('/search', hospitalController.searchHospitals);
router.get('/:id', hospitalController.getHospitalDetails);
router.get('/:id/schedule', hospitalController.getHospitalSchedule);
router.get('/:id/reviews', hospitalController.getHospitalReviews);

// Protected routes - require authentication
router.use(authenticate);
router.post('/:id/reviews', hospitalController.addHospitalReview);

module.exports = router; 