const express = require('express');
const router = express.Router();
const multer = require('multer');
const profileController = require('../controllers/profile.controller');
const { authenticate } = require('../middleware/auth');
const { validateProfileUpdate } = require('../middleware/validation');

// Configure multer for file uploads
const upload = multer({
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    // Allow images for avatar
    if (file.fieldname === 'avatar') {
      if (!file.mimetype.startsWith('image/')) {
        return cb(new Error('Only image files are allowed for avatar'), false);
      }
    }
    // Allow common document types
    else if (file.fieldname === 'document') {
      const allowedTypes = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'image/jpeg',
        'image/png'
      ];
      if (!allowedTypes.includes(file.mimetype)) {
        return cb(new Error('Invalid file type'), false);
      }
    }
    cb(null, true);
  }
});

// All routes require authentication
router.use(authenticate);

// Get user profile
router.get('/', profileController.getProfile);

// Update profile information
router.put('/', validateProfileUpdate, profileController.updateProfile);

// Update email
router.put('/email', profileController.updateEmail);

// Update password
router.put('/password', profileController.updatePassword);

// Update avatar
router.put('/avatar', upload.single('avatar'), profileController.updateAvatar);

// Delete account
router.delete('/', profileController.deleteAccount);

// Document management
router.get('/documents', profileController.getDocuments);
router.post('/documents', upload.single('document'), profileController.uploadDocument);
router.delete('/documents/:id', profileController.deleteDocument);

module.exports = router; 