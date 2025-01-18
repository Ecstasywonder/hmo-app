const { User, PlanSubscription, MedicalRecord, Appointment, Attachment } = require('../models');
const { hashPassword } = require('../utils/auth');
const { sendEmail } = require('../utils/email');
const { uploadFile, deleteFile } = require('../utils/storage');

class ProfileService {
  async getProfile(userId) {
    try {
      const user = await User.findByPk(userId, {
        attributes: { exclude: ['password'] },
        include: [{
          model: PlanSubscription,
          as: 'planSubscriptions',
          where: { status: 'active' },
          required: false,
          limit: 1
        }]
      });

      if (!user) {
        throw new Error('User not found');
      }

      // Get user stats
      const [
        appointmentsCount,
        medicalRecordsCount,
        documentsCount
      ] = await Promise.all([
        Appointment.count({ where: { userId } }),
        MedicalRecord.count({ where: { userId } }),
        Attachment.count({ where: { userId } })
      ]);

      return {
        ...user.toJSON(),
        stats: {
          appointments: appointmentsCount,
          medicalRecords: medicalRecordsCount,
          documents: documentsCount
        }
      };
    } catch (error) {
      throw new Error(`Error fetching profile: ${error.message}`);
    }
  }

  async updateProfile(userId, data) {
    try {
      const user = await User.findByPk(userId);
      if (!user) {
        throw new Error('User not found');
      }

      const {
        firstName,
        lastName,
        phoneNumber,
        dateOfBirth,
        gender,
        address,
        city,
        state,
        emergencyContact,
        bloodGroup,
        allergies,
        chronicConditions,
        preferences
      } = data;

      // Update basic info
      const updates = {
        firstName,
        lastName,
        phoneNumber,
        dateOfBirth,
        gender,
        address,
        city,
        state,
        emergencyContact,
        bloodGroup,
        allergies,
        chronicConditions
      };

      // Filter out undefined values
      Object.keys(updates).forEach(key => 
        updates[key] === undefined && delete updates[key]
      );

      await user.update(updates);

      // Update preferences if provided
      if (preferences) {
        await user.update({
          preferences: {
            ...user.preferences,
            ...preferences
          }
        });
      }

      return user;
    } catch (error) {
      throw new Error(`Error updating profile: ${error.message}`);
    }
  }

  async updateEmail(userId, newEmail, password) {
    try {
      const user = await User.findByPk(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Verify password
      const isValid = await user.comparePassword(password);
      if (!isValid) {
        throw new Error('Invalid password');
      }

      // Check if email is already in use
      const existingUser = await User.findOne({ where: { email: newEmail } });
      if (existingUser) {
        throw new Error('Email already in use');
      }

      // Generate verification token
      const verificationToken = await user.generateVerificationToken();

      // Send verification email
      await sendEmail({
        to: newEmail,
        subject: 'Verify Your New Email',
        template: 'email-verification',
        data: {
          userName: user.firstName,
          verificationUrl: `${process.env.FRONTEND_URL}/verify-email?token=${verificationToken}`
        }
      });

      // Update user's pending email
      await user.update({
        pendingEmail: newEmail,
        emailVerified: false
      });

      return true;
    } catch (error) {
      throw new Error(`Error updating email: ${error.message}`);
    }
  }

  async updatePassword(userId, currentPassword, newPassword) {
    try {
      const user = await User.findByPk(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Verify current password
      const isValid = await user.comparePassword(currentPassword);
      if (!isValid) {
        throw new Error('Current password is incorrect');
      }

      // Hash new password
      const hashedPassword = await hashPassword(newPassword);

      // Update password
      await user.update({ password: hashedPassword });

      // Send password change notification
      await sendEmail({
        to: user.email,
        subject: 'Password Changed Successfully',
        template: 'password-changed',
        data: {
          userName: user.firstName
        }
      });

      return true;
    } catch (error) {
      throw new Error(`Error updating password: ${error.message}`);
    }
  }

  async updateAvatar(userId, file) {
    try {
      const user = await User.findByPk(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Delete old avatar if exists
      if (user.avatar) {
        await deleteFile(user.avatar);
      }

      // Upload new avatar
      const avatarUrl = await uploadFile(file, 'avatars');

      // Update user avatar
      await user.update({ avatar: avatarUrl });

      return avatarUrl;
    } catch (error) {
      throw new Error(`Error updating avatar: ${error.message}`);
    }
  }

  async deleteAccount(userId, password) {
    try {
      const user = await User.findByPk(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Verify password
      const isValid = await user.comparePassword(password);
      if (!isValid) {
        throw new Error('Invalid password');
      }

      // Send account deletion notification
      await sendEmail({
        to: user.email,
        subject: 'Account Deleted',
        template: 'account-deleted',
        data: {
          userName: user.firstName
        }
      });

      // Soft delete user account
      await user.destroy();

      return true;
    } catch (error) {
      throw new Error(`Error deleting account: ${error.message}`);
    }
  }

  async getDocuments(userId) {
    try {
      const documents = await Attachment.findAll({
        where: { userId },
        order: [['createdAt', 'DESC']]
      });

      return documents;
    } catch (error) {
      throw new Error(`Error fetching documents: ${error.message}`);
    }
  }

  async uploadDocument(userId, file, metadata) {
    try {
      // Upload file
      const fileUrl = await uploadFile(file, 'documents');

      // Create document record
      const document = await Attachment.create({
        userId,
        type: 'document',
        url: fileUrl,
        name: file.originalname,
        mimeType: file.mimetype,
        size: file.size,
        metadata
      });

      return document;
    } catch (error) {
      throw new Error(`Error uploading document: ${error.message}`);
    }
  }

  async deleteDocument(userId, documentId) {
    try {
      const document = await Attachment.findOne({
        where: {
          id: documentId,
          userId
        }
      });

      if (!document) {
        throw new Error('Document not found');
      }

      // Delete file from storage
      await deleteFile(document.url);

      // Delete document record
      await document.destroy();

      return true;
    } catch (error) {
      throw new Error(`Error deleting document: ${error.message}`);
    }
  }
}

module.exports = new ProfileService(); 