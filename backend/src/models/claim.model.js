const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Claim = sequelize.define('Claim', {
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
  medicalRecordId: {
    type: DataTypes.UUID,
    references: {
      model: 'MedicalRecords',
      key: 'id'
    }
  },
  claimNumber: {
    type: DataTypes.STRING,
    unique: true
  },
  claimDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  serviceDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  diagnosis: {
    type: DataTypes.STRING,
    allowNull: false
  },
  treatment: {
    type: DataTypes.STRING,
    allowNull: false
  },
  claimAmount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  approvedAmount: {
    type: DataTypes.DECIMAL(10, 2)
  },
  status: {
    type: DataTypes.ENUM('pending', 'under_review', 'approved', 'rejected', 'paid'),
    defaultValue: 'pending'
  },
  notes: {
    type: DataTypes.TEXT
  },
  documents: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  processedBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  processedAt: {
    type: DataTypes.DATE
  },
  paymentDate: {
    type: DataTypes.DATE
  },
  paymentReference: {
    type: DataTypes.STRING
  },
  rejectionReason: {
    type: DataTypes.STRING
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
      fields: ['claimNumber']
    },
    {
      fields: ['status']
    },
    {
      fields: ['claimDate']
    }
  ]
});

// Hook to generate claim number before creation
Claim.beforeCreate(async (claim) => {
  const date = new Date();
  const year = date.getFullYear().toString().slice(-2);
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  
  // Get the last claim number for the current month
  const lastClaim = await Claim.findOne({
    where: {
      claimNumber: {
        [Op.like]: `CLM${year}${month}%`
      }
    },
    order: [['claimNumber', 'DESC']]
  });

  let sequence = '0001';
  if (lastClaim && lastClaim.claimNumber) {
    const lastSequence = parseInt(lastClaim.claimNumber.slice(-4));
    sequence = (lastSequence + 1).toString().padStart(4, '0');
  }

  claim.claimNumber = `CLM${year}${month}${sequence}`;
});

module.exports = Claim; 