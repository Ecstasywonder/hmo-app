const profileService = require('../services/profile.service');
const { catchAsync } = require('../utils/error');
const { validatePassword } = require('../utils/validation');

class ProfileController {
  getProfile = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const profile = await profileService.getProfile(userId);
    res.json({
      success: true,
      data: profile
    });
  });

  updateProfile = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const updates = {
      firstName: req.body.firstName,
      lastName: req.body.lastName,
      phoneNumber: req.body.phoneNumber,
      dateOfBirth: req.body.dateOfBirth,
      gender: req.body.gender,
      address: req.body.address,
      city: req.body.city,
      state: req.body.state,
      emergencyContact: req.body.emergencyContact,
      bloodGroup: req.body.bloodGroup,
      allergies: req.body.allergies,
      chronicConditions: req.body.chronicConditions,
      preferences: req.body.preferences
    };

    const profile = await profileService.updateProfile(userId, updates);
    res.json({
      success: true,
      data: profile
    });
  });

  updateEmail = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { newEmail, password } = req.body;

    if (!newEmail || !password) {
      return res.status(400).json({
        success: false,
        error: 'New email and password are required'
      });
    }

    await profileService.updateEmail(userId, newEmail, password);
    res.json({
      success: true,
      message: 'Verification email sent to new address'
    });
  });

  updatePassword = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        error: 'Current password and new password are required'
      });
    }

    // Validate new password
    const validationError = validatePassword(newPassword);
    if (validationError) {
      return res.status(400).json({
        success: false,
        error: validationError
      });
    }

    await profileService.updatePassword(userId, currentPassword, newPassword);
    res.json({
      success: true,
      message: 'Password updated successfully'
    });
  });

  updateAvatar = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const file = req.file;

    if (!file) {
      return res.status(400).json({
        success: false,
        error: 'No file uploaded'
      });
    }

    const avatarUrl = await profileService.updateAvatar(userId, file);
    res.json({
      success: true,
      data: { avatarUrl }
    });
  });

  deleteAccount = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        error: 'Password is required'
      });
    }

    await profileService.deleteAccount(userId, password);
    res.json({
      success: true,
      message: 'Account deleted successfully'
    });
  });

  getDocuments = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const documents = await profileService.getDocuments(userId);
    res.json({
      success: true,
      data: documents
    });
  });

  uploadDocument = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const file = req.file;
    const metadata = req.body.metadata ? JSON.parse(req.body.metadata) : {};

    if (!file) {
      return res.status(400).json({
        success: false,
        error: 'No file uploaded'
      });
    }

    const document = await profileService.uploadDocument(userId, file, metadata);
    res.status(201).json({
      success: true,
      data: document
    });
  });

  deleteDocument = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    await profileService.deleteDocument(userId, id);
    res.json({
      success: true,
      message: 'Document deleted successfully'
    });
  });
}

module.exports = new ProfileController(); 