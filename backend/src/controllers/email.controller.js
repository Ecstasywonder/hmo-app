const { User, EmailVerification, PasswordReset } = require('../models');
const emailService = require('../services/email.service');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');

// Helper function to generate random token
const generateToken = () => crypto.randomBytes(32).toString('hex');

exports.sendVerificationEmail = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({ message: 'Email already verified' });
    }

    // Create verification token
    const token = generateToken();
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    await EmailVerification.create({
      userId: user.id,
      token,
      expiresAt
    });

    // Send verification email
    await emailService.sendVerificationEmail(user, token);

    res.json({ message: 'Verification email sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.verifyEmail = async (req, res) => {
  try {
    const { token } = req.params;

    const verification = await EmailVerification.findOne({
      where: {
        token,
        isUsed: false,
        expiresAt: { [Op.gt]: new Date() }
      },
      include: [{ model: User }]
    });

    if (!verification) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    // Update user and verification record
    const user = verification.User;
    user.isEmailVerified = true;
    verification.isUsed = true;

    await Promise.all([user.save(), verification.save()]);

    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.requestPasswordReset = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Create reset token
    const token = generateToken();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await PasswordReset.create({
      userId: user.id,
      token,
      expiresAt,
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    });

    // Send password reset email
    await emailService.sendPasswordResetEmail(user, token);

    res.json({ message: 'Password reset email sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { token, password } = req.body;

    const resetRequest = await PasswordReset.findOne({
      where: {
        token,
        isUsed: false,
        expiresAt: { [Op.gt]: new Date() }
      },
      include: [{ model: User }]
    });

    if (!resetRequest) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    // Update password and reset request record
    const user = resetRequest.User;
    user.password = await bcrypt.hash(password, 10);
    resetRequest.isUsed = true;

    await Promise.all([user.save(), resetRequest.save()]);

    res.json({ message: 'Password reset successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updateEmailPreferences = async (req, res) => {
  try {
    const { marketingEmails, appointmentReminders, subscriptionAlerts } = req.body;
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update email preferences
    if (marketingEmails !== undefined) user.marketingEmails = marketingEmails;
    if (appointmentReminders !== undefined) user.appointmentReminders = appointmentReminders;
    if (subscriptionAlerts !== undefined) user.subscriptionAlerts = subscriptionAlerts;

    await user.save();

    res.json({
      message: 'Email preferences updated successfully',
      preferences: {
        marketingEmails: user.marketingEmails,
        appointmentReminders: user.appointmentReminders,
        subscriptionAlerts: user.subscriptionAlerts
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.broadcastEmail = async (req, res) => {
  try {
    const { subject, content, userFilter } = req.body;

    // Build user filter
    let whereClause = {};
    if (userFilter) {
      if (userFilter.role) whereClause.role = userFilter.role;
      if (userFilter.isActive !== undefined) whereClause.isActive = userFilter.isActive;
      if (userFilter.marketingEmails !== undefined) whereClause.marketingEmails = userFilter.marketingEmails;
    }

    const users = await User.findAll({
      where: whereClause,
      attributes: ['id', 'email', 'name']
    });

    // Send emails in batches to avoid overwhelming the email service
    const batchSize = 50;
    for (let i = 0; i < users.length; i += batchSize) {
      const batch = users.slice(i, i + batchSize);
      await Promise.all(
        batch.map(user =>
          emailService.transporter.sendMail({
            from: process.env.SMTP_FROM,
            to: user.email,
            subject,
            html: content.replace('{name}', user.name)
          })
        )
      );
    }

    res.json({
      message: `Broadcast email sent to ${users.length} users`,
      count: users.length
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
}; 