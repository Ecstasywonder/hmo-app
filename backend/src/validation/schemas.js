const { body } = require('express-validator');

exports.userValidation = {
  register: [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Valid email is required'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters')
      .matches(/\d/)
      .withMessage('Password must contain a number')
  ],
  update: [
    body('name').optional().trim().notEmpty(),
    body('phone').optional().matches(/^\+?[\d\s-]+$/).withMessage('Invalid phone number'),
    body('address').optional().trim().notEmpty()
  ]
};

exports.hospitalValidation = {
  create: [
    body('name').trim().notEmpty().withMessage('Hospital name is required'),
    body('address').trim().notEmpty().withMessage('Address is required'),
    body('phone').matches(/^\+?[\d\s-]+$/).withMessage('Invalid phone number'),
    body('email').isEmail().withMessage('Valid email is required'),
    body('specialties').isArray().withMessage('Specialties must be an array'),
    body('workingHours').optional().isObject().withMessage('Working hours must be an object')
  ],
  update: [
    body('name').optional().trim().notEmpty(),
    body('address').optional().trim().notEmpty(),
    body('phone').optional().matches(/^\+?[\d\s-]+$/),
    body('email').optional().isEmail(),
    body('specialties').optional().isArray(),
    body('workingHours').optional().isObject()
  ]
};

exports.appointmentValidation = {
  create: [
    body('date').isISO8601().withMessage('Valid date is required'),
    body('time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Valid time is required (HH:MM)'),
    body('reason').trim().notEmpty().withMessage('Reason is required'),
    body('doctorName').optional().trim().notEmpty(),
    body('department').optional().trim().notEmpty()
  ],
  update: [
    body('status').isIn(['pending', 'confirmed', 'cancelled', 'completed']).withMessage('Invalid status'),
    body('notes').optional().trim().notEmpty(),
    body('cancelReason').optional().trim().notEmpty()
  ]
};

exports.planValidation = {
  create: [
    body('name').trim().notEmpty().withMessage('Plan name is required'),
    body('description').trim().notEmpty().withMessage('Description is required'),
    body('price').isFloat({ min: 0 }).withMessage('Valid price is required'),
    body('duration').isInt({ min: 1 }).withMessage('Valid duration is required'),
    body('benefits').isArray().withMessage('Benefits must be an array')
  ],
  update: [
    body('name').optional().trim().notEmpty(),
    body('description').optional().trim().notEmpty(),
    body('price').optional().isFloat({ min: 0 }),
    body('duration').optional().isInt({ min: 1 }),
    body('benefits').optional().isArray()
  ]
};

exports.subscriptionValidation = {
  create: [
    body('planId').isUUID().withMessage('Valid plan ID is required'),
    body('paymentMethod').trim().notEmpty().withMessage('Payment method is required'),
    body('autoRenew').optional().isBoolean()
  ],
  update: [
    body('status').isIn(['active', 'expired', 'cancelled']).withMessage('Invalid status'),
    body('autoRenew').optional().isBoolean(),
    body('cancellationReason').optional().trim().notEmpty()
  ]
}; 