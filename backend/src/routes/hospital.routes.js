const express = require('express');
const { body } = require('express-validator');
const hospitalController = require('../controllers/hospital.controller');
const validateRequest = require('../middleware/validate-request');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');

const router = express.Router();

// Public routes
router.get('/', hospitalController.getAllHospitals);
router.get('/:id', hospitalController.getHospitalById);
router.get('/search', hospitalController.searchHospitals);

// Protected routes (requires authentication)
router.post(
  '/:hospitalId/appointments',
  [
    auth,
    body('date').isISO8601().withMessage('Valid date is required'),
    body('time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Valid time is required (HH:MM)'),
    body('reason').notEmpty().withMessage('Reason for appointment is required'),
    validateRequest
  ],
  hospitalController.bookAppointment
);

router.get('/user/appointments', auth, hospitalController.getUserAppointments);

// Admin routes
router.post(
  '/',
  [
    auth,
    admin,
    body('name').notEmpty().withMessage('Hospital name is required'),
    body('address').notEmpty().withMessage('Address is required'),
    body('phone').notEmpty().withMessage('Phone number is required'),
    body('email').isEmail().withMessage('Valid email is required'),
    body('specialties').isArray().withMessage('Specialties must be an array'),
    validateRequest
  ],
  hospitalController.createHospital
);

router.put(
  '/:id',
  [
    auth,
    admin,
    body('name').optional(),
    body('address').optional(),
    body('phone').optional(),
    body('email').optional().isEmail().withMessage('Valid email is required'),
    body('specialties').optional().isArray().withMessage('Specialties must be an array'),
    validateRequest
  ],
  hospitalController.updateHospital
);

router.delete('/:id', [auth, admin], hospitalController.deleteHospital);

// Hospital management routes
router.get('/:hospitalId/appointments', [auth, admin], hospitalController.getHospitalAppointments);
router.put('/:hospitalId/appointments/:appointmentId', [auth, admin], hospitalController.updateAppointmentStatus);

module.exports = router; 