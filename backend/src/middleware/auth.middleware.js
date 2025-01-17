const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config/jwt');
const { User } = require('../models');

exports.validateAuth = async (req, res, next) => {
  try {
    // Get token from header
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ message: 'No token, authorization denied' });
    }

    try {
      // Verify token
      const decoded = jwt.verify(token, JWT_SECRET);
      
      // Get user from database
      const user = await User.findByPk(decoded.userId, {
        attributes: { exclude: ['password'] }
      });

      if (!user) {
        return res.status(401).json({ message: 'User not found' });
      }

      // Check if user is active
      if (!user.isActive) {
        return res.status(401).json({ message: 'Account is deactivated' });
      }

      // Check if account is locked
      if (user.isLocked && user.lockedUntil > new Date()) {
        return res.status(403).json({ 
          message: 'Account is locked',
          lockedUntil: user.lockedUntil
        });
      }

      // Add user to request
      req.user = user;
      next();
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({ message: 'Token has expired' });
      }
      return res.status(401).json({ message: 'Token is not valid' });
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.validateAdmin = async (req, res, next) => {
  try {
    // First validate auth
    await exports.validateAuth(req, res, () => {
      // Check if user is admin
      if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied. Admin only.' });
      }
      next();
    });
  } catch (error) {
    console.error('Admin validation error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.validateHospital = async (req, res, next) => {
  try {
    // First validate auth
    await exports.validateAuth(req, res, () => {
      // Check if user is hospital staff
      if (req.user.role !== 'hospital') {
        return res.status(403).json({ message: 'Access denied. Hospital staff only.' });
      }
      next();
    });
  } catch (error) {
    console.error('Hospital validation error:', error);
    res.status(500).json({ message: 'Server error' });
  }
}; 