const medicalRecordService = require('../services/medical-record.service');
const { catchAsync } = require('../utils/error');

class MedicalRecordController {
  getUserRecords = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const filters = {
      startDate: req.query.startDate,
      endDate: req.query.endDate,
      type: req.query.type,
      hospitalId: req.query.hospitalId,
      page: req.query.page,
      limit: req.query.limit
    };

    const result = await medicalRecordService.getUserMedicalRecords(userId, filters);
    res.json({
      success: true,
      data: result.records,
      pagination: result.pagination
    });
  });

  getRecordById = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    const record = await medicalRecordService.getMedicalRecordById(id, userId);
    res.json({
      success: true,
      data: record
    });
  });

  createRecord = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const recordData = {
      userId,
      hospitalId: req.body.hospitalId,
      doctorId: req.body.doctorId,
      appointmentId: req.body.appointmentId,
      recordType: req.body.recordType,
      diagnosis: req.body.diagnosis,
      symptoms: req.body.symptoms,
      treatment: req.body.treatment,
      prescriptions: req.body.prescriptions,
      labResults: req.body.labResults,
      vitals: req.body.vitals,
      notes: req.body.notes,
      attachments: req.body.attachments,
      followUpDate: req.body.followUpDate
    };

    // Validate required fields
    const requiredFields = ['hospitalId', 'doctorId', 'recordType'];
    const missingFields = requiredFields.filter(field => !recordData[field]);

    if (missingFields.length > 0) {
      return res.status(400).json({
        success: false,
        error: `Missing required fields: ${missingFields.join(', ')}`
      });
    }

    const record = await medicalRecordService.createMedicalRecord(recordData);
    res.status(201).json({
      success: true,
      data: record
    });
  });

  updateRecord = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const updates = {
      diagnosis: req.body.diagnosis,
      symptoms: req.body.symptoms,
      treatment: req.body.treatment,
      prescriptions: req.body.prescriptions,
      labResults: req.body.labResults,
      vitals: req.body.vitals,
      notes: req.body.notes,
      followUpDate: req.body.followUpDate,
      attachments: req.body.attachments
    };

    const record = await medicalRecordService.updateMedicalRecord(id, userId, updates);
    res.json({
      success: true,
      data: record
    });
  });

  shareRecord = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { shareWithIds } = req.body;

    if (!shareWithIds || !Array.isArray(shareWithIds) || shareWithIds.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Please provide at least one user ID to share with'
      });
    }

    const record = await medicalRecordService.shareMedicalRecord(id, userId, shareWithIds);
    res.json({
      success: true,
      data: record
    });
  });
}

module.exports = new MedicalRecordController(); 