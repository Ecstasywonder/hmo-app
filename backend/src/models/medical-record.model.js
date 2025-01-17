const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const MedicalRecord = sequelize.define('MedicalRecord', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  hospitalId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Hospitals',
      key: 'id'
    }
  },
  appointmentId: {
    type: DataTypes.UUID,
    references: {
      model: 'Appointments',
      key: 'id'
    }
  },
  recordNumber: {
    type: DataTypes.STRING,
    unique: true
  },
  recordType: {
    type: DataTypes.ENUM(
      'consultation',
      'diagnosis',
      'prescription',
      'lab_result',
      'imaging',
      'surgery',
      'discharge',
      'follow_up'
    ),
    allowNull: false
  },
  recordDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  diagnosis: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  symptoms: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  treatment: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  prescriptions: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  labResults: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  vitals: {
    type: DataTypes.JSONB,
    defaultValue: {}
  },
  notes: {
    type: DataTypes.TEXT
  },
  attachments: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  doctorName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  doctorSpecialty: {
    type: DataTypes.STRING
  },
  followUpDate: {
    type: DataTypes.DATE
  },
  verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  verifiedBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  verifiedAt: {
    type: DataTypes.DATE
  },
  verificationNotes: {
    type: DataTypes.TEXT
  },
  confidential: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  accessLevel: {
    type: DataTypes.ENUM('public', 'private', 'restricted'),
    defaultValue: 'private'
  },
  sharedWith: {
    type: DataTypes.JSONB,
    defaultValue: []
  }
}, {
  timestamps: true,
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['hospitalId']
    },
    {
      fields: ['appointmentId']
    },
    {
      fields: ['recordNumber']
    },
    {
      fields: ['recordType']
    },
    {
      fields: ['recordDate']
    },
    {
      fields: ['verified']
    }
  ]
});

// Hook to generate record number before creation
MedicalRecord.beforeCreate(async (record) => {
  const date = new Date();
  const year = date.getFullYear().toString().slice(-2);
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  
  // Get the last record number for the current month
  const lastRecord = await MedicalRecord.findOne({
    where: {
      recordNumber: {
        [Op.like]: `MR${year}${month}%`
      }
    },
    order: [['recordNumber', 'DESC']]
  });

  let sequence = '0001';
  if (lastRecord && lastRecord.recordNumber) {
    const lastSequence = parseInt(lastRecord.recordNumber.slice(-4));
    sequence = (lastSequence + 1).toString().padStart(4, '0');
  }

  record.recordNumber = `MR${year}${month}${sequence}`;
});

module.exports = MedicalRecord; 