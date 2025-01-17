const { User, EmailVerification, PasswordReset, LoginAttempt, ActivityLog } = require('../models');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const emailService = require('./email.service');
const { Op } = require('sequelize');

class UserService {
  async register(data) {
    // Check if user already exists
    const existingUser = await User.findOne({
      where: {
        [Op.or]: [
          { email: data.email },
          { phone: data.phone }
        ]
      }
    });

    if (existingUser) {
      throw new Error('User with this email or phone already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 10);

    // Create user
    const user = await User.create({
      name: data.name,
      email: data.email,
      phone: data.phone,
      password: hashedPassword,
      role: 'user',
      isEmailVerified: false,
      status: 'active'
    });

    // Generate verification token
    const verificationToken = crypto.randomBytes(32).toString('hex');
    await EmailVerification.create({
      userId: user.id,
      token: verificationToken,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
    });

    // Send verification email
    await emailService.sendVerificationEmail(user, verificationToken);

    return user;
  }

  async login(email, password) {
    const user = await User.findOne({ where: { email } });

    if (!user) {
      throw new Error('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    if (user.isLocked && user.lockedUntil > new Date()) {
      throw new Error('Account is locked. Please try again later');
    }

    if (!user.isEmailVerified) {
      throw new Error('Please verify your email before logging in');
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    return { user, token };
  }

  async verifyEmail(token) {
    const verification = await EmailVerification.findOne({
      where: {
        token,
        expiresAt: { [Op.gt]: new Date() }
      },
      include: [User]
    });

    if (!verification) {
      throw new Error('Invalid or expired verification token');
    }

    // Update user
    await verification.User.update({ isEmailVerified: true });

    // Delete verification record
    await verification.destroy();

    return verification.User;
  }

  async requestPasswordReset(email) {
    const user = await User.findOne({ where: { email } });

    if (!user) {
      throw new Error('User not found');
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    await PasswordReset.create({
      userId: user.id,
      token: resetToken,
      expiresAt: new Date(Date.now() + 60 * 60 * 1000) // 1 hour
    });

    // Send reset email
    await emailService.sendPasswordResetEmail(user, resetToken);

    return true;
  }

  async resetPassword(token, newPassword) {
    const reset = await PasswordReset.findOne({
      where: {
        token,
        expiresAt: { [Op.gt]: new Date() }
      },
      include: [User]
    });

    if (!reset) {
      throw new Error('Invalid or expired reset token');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update user password
    await reset.User.update({ password: hashedPassword });

    // Delete reset record
    await reset.destroy();

    return reset.User;
  }

  async updateProfile(userId, data) {
    const user = await User.findByPk(userId);

    if (!user) {
      throw new Error('User not found');
    }

    // Update user data
    await user.update({
      name: data.name || user.name,
      phone: data.phone || user.phone,
      address: data.address || user.address,
      dateOfBirth: data.dateOfBirth || user.dateOfBirth,
      gender: data.gender || user.gender,
      emergencyContact: data.emergencyContact || user.emergencyContact,
      bloodGroup: data.bloodGroup || user.bloodGroup,
      allergies: data.allergies || user.allergies,
      medicalConditions: data.medicalConditions || user.medicalConditions
    });

    return user;
  }

  async changePassword(userId, currentPassword, newPassword) {
    const user = await User.findByPk(userId);

    if (!user) {
      throw new Error('User not found');
    }

    // Verify current password
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isPasswordValid) {
      throw new Error('Current password is incorrect');
    }

    // Hash and update new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await user.update({ password: hashedPassword });

    return true;
  }

  async getUserActivity(userId) {
    return await ActivityLog.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
      limit: 50
    });
  }

  async getLoginHistory(userId) {
    return await LoginAttempt.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
      limit: 10
    });
  }

  async deactivateAccount(userId, reason) {
    const user = await User.findByPk(userId);

    if (!user) {
      throw new Error('User not found');
    }

    await user.update({
      status: 'inactive',
      deactivationReason: reason,
      deactivatedAt: new Date()
    });

    return true;
  }
}

module.exports = new UserService(); 