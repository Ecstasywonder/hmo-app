const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { validateAdmin } = require('../middleware/auth.middleware');

// Apply admin validation middleware to all routes
router.use(validateAdmin);

// Dashboard routes
router.get('/dashboard', adminController.getDashboard);
router.get('/system-health', adminController.getSystemHealth);
router.get('/notifications', adminController.getAdminNotifications);
router.get('/reports', adminController.getReports);

// User management routes
router.get('/users', adminController.getUsers);
router.get('/users/:id', adminController.getUserDetails);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Hospital management routes
router.get('/hospitals', adminController.getHospitals);
router.post('/hospitals', adminController.createHospital);
router.get('/hospitals/:id', adminController.getHospitalDetails);
router.put('/hospitals/:id', adminController.updateHospital);
router.delete('/hospitals/:id', adminController.deleteHospital);

// Plan management routes
router.get('/plans', adminController.getPlans);
router.post('/plans', adminController.createPlan);
router.get('/plans/:id', adminController.getPlanDetails);
router.put('/plans/:id', adminController.updatePlan);
router.delete('/plans/:id', adminController.deletePlan);

// Appointment management routes
router.get('/appointments', adminController.getAppointments);
router.get('/appointments/:id', adminController.getAppointmentDetails);
router.put('/appointments/:id', adminController.updateAppointment);
router.delete('/appointments/:id', adminController.deleteAppointment);

// Claims management routes
router.get('/claims', adminController.getClaims);
router.get('/claims/:id', adminController.getClaimDetails);
router.put('/claims/:id', adminController.updateClaim);

// Medical records routes
router.get('/medical-records', adminController.getMedicalRecords);
router.get('/medical-records/:id', adminController.getMedicalRecordDetails);
router.put('/medical-records/:id/verify', adminController.verifyMedicalRecord);

// Settings routes
router.get('/settings', adminController.getSettings);
router.put('/settings', adminController.updateSettings);

module.exports = router; 