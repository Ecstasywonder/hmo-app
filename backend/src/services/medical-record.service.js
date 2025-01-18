const { MedicalRecord, Hospital, Doctor, User, Attachment } = require('../models');
const { Op } = require('sequelize');

class MedicalRecordService {
  async getUserMedicalRecords(userId, filters = {}) {
    try {
      const {
        startDate,
        endDate,
        type,
        hospitalId,
        page = 1,
        limit = 10
      } = filters;

      const where = { userId };

      if (startDate && endDate) {
        where.recordDate = {
          [Op.between]: [new Date(startDate), new Date(endDate)]
        };
      }

      if (type) {
        where.recordType = type;
      }

      if (hospitalId) {
        where.hospitalId = hospitalId;
      }

      const offset = (page - 1) * limit;

      const { rows: records, count } = await MedicalRecord.findAndCountAll({
        where,
        include: [
          {
            model: Hospital,
            as: 'hospital',
            attributes: ['id', 'name']
          },
          {
            model: Doctor,
            as: 'doctor',
            attributes: ['id', 'name', 'specialty']
          }
        ],
        order: [['recordDate', 'DESC']],
        limit,
        offset
      });

      return {
        records,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error fetching medical records: ${error.message}`);
    }
  }

  async getMedicalRecordById(recordId, userId) {
    try {
      const record = await MedicalRecord.findOne({
        where: {
          id: recordId,
          userId
        },
        include: [
          {
            model: Hospital,
            as: 'hospital',
            attributes: ['id', 'name', 'address', 'phone']
          },
          {
            model: Doctor,
            as: 'doctor',
            attributes: ['id', 'name', 'specialty', 'qualification']
          },
          {
            model: Attachment,
            as: 'attachments'
          }
        ]
      });

      if (!record) {
        throw new Error('Medical record not found');
      }

      return record;
    } catch (error) {
      throw new Error(`Error fetching medical record details: ${error.message}`);
    }
  }

  async createMedicalRecord(data) {
    try {
      const {
        userId,
        hospitalId,
        doctorId,
        appointmentId,
        recordType,
        diagnosis,
        symptoms,
        treatment,
        prescriptions,
        labResults,
        vitals,
        notes,
        attachments,
        followUpDate
      } = data;

      const record = await MedicalRecord.create({
        userId,
        hospitalId,
        doctorId,
        appointmentId,
        recordType,
        recordNumber: await this._generateRecordNumber(),
        recordDate: new Date(),
        diagnosis,
        symptoms,
        treatment,
        prescriptions,
        labResults,
        vitals,
        notes,
        followUpDate
      });

      // Handle attachments if any
      if (attachments && attachments.length > 0) {
        const attachmentRecords = attachments.map(attachment => ({
          ...attachment,
          medicalRecordId: record.id
        }));

        await Attachment.bulkCreate(attachmentRecords);
      }

      return record;
    } catch (error) {
      throw new Error(`Error creating medical record: ${error.message}`);
    }
  }

  async updateMedicalRecord(recordId, userId, data) {
    try {
      const record = await MedicalRecord.findOne({
        where: {
          id: recordId,
          userId
        }
      });

      if (!record) {
        throw new Error('Medical record not found');
      }

      // Update only allowed fields
      const allowedUpdates = [
        'diagnosis',
        'symptoms',
        'treatment',
        'prescriptions',
        'labResults',
        'vitals',
        'notes',
        'followUpDate'
      ];

      const updates = {};
      allowedUpdates.forEach(field => {
        if (data[field] !== undefined) {
          updates[field] = data[field];
        }
      });

      await record.update(updates);

      // Handle attachment updates if any
      if (data.attachments) {
        // Remove old attachments
        await Attachment.destroy({
          where: { medicalRecordId: recordId }
        });

        // Add new attachments
        if (data.attachments.length > 0) {
          const attachmentRecords = data.attachments.map(attachment => ({
            ...attachment,
            medicalRecordId: recordId
          }));

          await Attachment.bulkCreate(attachmentRecords);
        }
      }

      return record;
    } catch (error) {
      throw new Error(`Error updating medical record: ${error.message}`);
    }
  }

  async shareMedicalRecord(recordId, userId, shareWithIds) {
    try {
      const record = await MedicalRecord.findOne({
        where: {
          id: recordId,
          userId
        }
      });

      if (!record) {
        throw new Error('Medical record not found');
      }

      // Validate share recipients exist
      const users = await User.findAll({
        where: {
          id: {
            [Op.in]: shareWithIds
          }
        }
      });

      if (users.length !== shareWithIds.length) {
        throw new Error('One or more users not found');
      }

      // Update shared users
      await record.update({
        sharedWith: shareWithIds
      });

      return record;
    } catch (error) {
      throw new Error(`Error sharing medical record: ${error.message}`);
    }
  }

  // Private helper methods
  async _generateRecordNumber() {
    const prefix = 'MR';
    const date = new Date().toISOString().slice(2, 10).replace(/-/g, '');
    const count = await MedicalRecord.count({
      where: {
        createdAt: {
          [Op.gte]: new Date().setHours(0, 0, 0, 0)
        }
      }
    });
    
    return `${prefix}${date}${(count + 1).toString().padStart(4, '0')}`;
  }
}

module.exports = new MedicalRecordService(); 