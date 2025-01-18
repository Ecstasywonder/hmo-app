const express = require('express');
const router = express.Router();
const medicalRecordController = require('../controllers/medical-record.controller');
const { authenticate } = require('../middleware/auth');

// All routes require authentication
router.use(authenticate);

// Get user's medical records with filters
router.get('/', medicalRecordController.getUserRecords);

// Get specific medical record details
router.get('/:id', medicalRecordController.getRecordById);

// Create new medical record
router.post('/', medicalRecordController.createRecord);

// Update existing medical record
router.put('/:id', medicalRecordController.updateRecord);

// Share medical record with other users
router.post('/:id/share', medicalRecordController.shareRecord);

module.exports = router; 