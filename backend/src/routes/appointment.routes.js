const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointment.controller');
const { validateAuth } = require('../middleware/auth.middleware');

// Apply auth validation middleware to all routes
router.use(validateAuth);

// Get available specialties
router.get('/specialties', appointmentController.getSpecialties);

// Get hospitals by specialty
router.get('/hospitals', appointmentController.getHospitalsBySpecialty);

// Get available time slots
router.get('/time-slots', appointmentController.getAvailableTimeSlots);

// Book appointment
router.post('/', appointmentController.bookAppointment);

// Get user's appointments
router.get('/my-appointments', appointmentController.getUserAppointments);

// Get appointment details
router.get('/:id', appointmentController.getAppointmentDetails);

// Update appointment
router.put('/:id', appointmentController.updateAppointment);

// Cancel appointment
router.delete('/:id', appointmentController.cancelAppointment);

// Get appointment history
router.get('/history', appointmentController.getAppointmentHistory);

// Reschedule appointment
router.post('/:id/reschedule', appointmentController.rescheduleAppointment);

// Confirm appointment
router.post('/:id/confirm', appointmentController.confirmAppointment);

module.exports = router; 