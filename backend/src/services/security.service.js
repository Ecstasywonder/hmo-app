const rateLimit = require('express-rate-limit');
const { User, LoginAttempt, ActivityLog } = require('../models');
const { Op } = require('sequelize');

class SecurityService {
  constructor() {
    this.loginLimiter = rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 5, // 5 attempts
      message: 'Too many login attempts, please try again later'
    });

    this.apiLimiter = rateLimit({
      windowMs: 60 * 1000, // 1 minute
      max: 100 // 100 requests per minute
    });
  }

  async logLoginAttempt(userId, success, ipAddress, userAgent) {
    await LoginAttempt.create({
      userId,
      success,
      ipAddress,
      userAgent
    });

    // Check for suspicious activity
    if (!success) {
      const recentFailedAttempts = await LoginAttempt.count({
        where: {
          userId,
          success: false,
          createdAt: {
            [Op.gte]: new Date(Date.now() - 15 * 60 * 1000) // Last 15 minutes
          }
        }
      });

      if (recentFailedAttempts >= 5) {
        await this.lockAccount(userId);
      }
    }
  }

  async lockAccount(userId) {
    const user = await User.findByPk(userId);
    if (user) {
      user.isLocked = true;
      user.lockedUntil = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
      await user.save();
    }
  }

  async unlockAccount(userId) {
    const user = await User.findByPk(userId);
    if (user) {
      user.isLocked = false;
      user.lockedUntil = null;
      await user.save();
    }
  }

  async logActivity(userId, action, details, ipAddress) {
    await ActivityLog.create({
      userId,
      action,
      details,
      ipAddress
    });
  }

  async checkSuspiciousActivity(userId) {
    const recentActivities = await ActivityLog.findAll({
      where: {
        userId,
        createdAt: {
          [Op.gte]: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
        }
      }
    });

    // Check for suspicious patterns
    const suspiciousPatterns = this.analyzeSuspiciousPatterns(recentActivities);
    if (suspiciousPatterns.length > 0) {
      await this.flagAccountForReview(userId, suspiciousPatterns);
    }
  }

  analyzeSuspiciousPatterns(activities) {
    const patterns = [];

    // Check for rapid succession of activities
    const rapidActivities = this.checkRapidActivities(activities);
    if (rapidActivities) patterns.push('rapid_succession');

    // Check for multiple IP addresses
    const multipleIPs = this.checkMultipleIPs(activities);
    if (multipleIPs) patterns.push('multiple_ips');

    // Check for unusual time patterns
    const unusualTimes = this.checkUnusualTimes(activities);
    if (unusualTimes) patterns.push('unusual_times');

    return patterns;
  }

  checkRapidActivities(activities) {
    if (activities.length < 2) return false;

    for (let i = 1; i < activities.length; i++) {
      const timeDiff = activities[i].createdAt - activities[i-1].createdAt;
      if (timeDiff < 1000) { // Less than 1 second apart
        return true;
      }
    }
    return false;
  }

  checkMultipleIPs(activities) {
    const uniqueIPs = new Set(activities.map(a => a.ipAddress));
    return uniqueIPs.size > 3; // More than 3 different IPs in 24 hours
  }

  checkUnusualTimes(activities) {
    return activities.some(activity => {
      const hour = activity.createdAt.getHours();
      return hour >= 0 && hour <= 4; // Activity between midnight and 4 AM
    });
  }

  async flagAccountForReview(userId, patterns) {
    await User.update(
      {
        requiresReview: true,
        reviewReason: JSON.stringify(patterns)
      },
      { where: { id: userId } }
    );
  }

  validatePassword(password) {
    const minLength = 8;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

    const errors = [];
    if (password.length < minLength) errors.push('Password must be at least 8 characters long');
    if (!hasUpperCase) errors.push('Password must contain at least one uppercase letter');
    if (!hasLowerCase) errors.push('Password must contain at least one lowercase letter');
    if (!hasNumbers) errors.push('Password must contain at least one number');
    if (!hasSpecialChar) errors.push('Password must contain at least one special character');

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  sanitizeInput(input) {
    // Basic XSS prevention
    if (typeof input === 'string') {
      return input
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .replace(/\//g, '&#x2F;');
    }
    return input;
  }
}

module.exports = new SecurityService(); 