const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Appointment = sequelize.define('Appointment', {
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
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  time: {
    type: DataTypes.TIME,
    allowNull: false
  },
  type: {
    type: DataTypes.ENUM(
      'consultation',
      'follow_up',
      'check_up',
      'vaccination',
      'procedure',
      'test',
      'emergency'
    ),
    allowNull: false
  },
  reason: {
    type: DataTypes.TEXT
  },
  status: {
    type: DataTypes.ENUM(
      'pending',
      'confirmed',
      'completed',
      'cancelled',
      'rescheduled',
      'no_show',
      'rejected'
    ),
    defaultValue: 'pending'
  },
  notes: {
    type: DataTypes.TEXT
  },
  cancellationReason: {
    type: DataTypes.TEXT
  },
  cancelledBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  cancelledAt: {
    type: DataTypes.DATE
  },
  confirmedBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  confirmedAt: {
    type: DataTypes.DATE
  },
  completedBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  completedAt: {
    type: DataTypes.DATE
  },
  doctorName: {
    type: DataTypes.STRING
  },
  doctorSpecialty: {
    type: DataTypes.STRING
  },
  duration: {
    type: DataTypes.INTEGER, // in minutes
    defaultValue: 30
  },
  reminderSent: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  lastReminderSentAt: {
    type: DataTypes.DATE
  },
  followUpDate: {
    type: DataTypes.DATEONLY
  },
  followUpNotes: {
    type: DataTypes.TEXT
  },
  attachments: {
    type: DataTypes.JSONB,
    defaultValue: []
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {}
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
      fields: ['date']
    },
    {
      fields: ['status']
    },
    {
      fields: ['type']
    },
    {
      fields: ['date', 'hospitalId']
    }
  ]
});

// Hooks
Appointment.beforeCreate(async (appointment) => {
  // Check if the time slot is available
  const existingAppointment = await Appointment.findOne({
    where: {
      hospitalId: appointment.hospitalId,
      date: appointment.date,
      time: appointment.time,
      status: {
        [Op.notIn]: ['cancelled', 'rejected']
      }
    }
  });

  if (existingAppointment) {
    throw new Error('This time slot is already booked');
  }
});

Appointment.beforeUpdate(async (appointment) => {
  // If status is changing to cancelled, set cancellation timestamp
  if (appointment.changed('status') && appointment.status === 'cancelled') {
    appointment.cancelledAt = new Date();
  }

  // If status is changing to confirmed, set confirmation timestamp
  if (appointment.changed('status') && appointment.status === 'confirmed') {
    appointment.confirmedAt = new Date();
  }

  // If status is changing to completed, set completion timestamp
  if (appointment.changed('status') && appointment.status === 'completed') {
    appointment.completedAt = new Date();
  }

  // If date or time is changing, check availability
  if (appointment.changed('date') || appointment.changed('time')) {
    const existingAppointment = await Appointment.findOne({
      where: {
        hospitalId: appointment.hospitalId,
        date: appointment.date,
        time: appointment.time,
        status: {
          [Op.notIn]: ['cancelled', 'rejected']
        },
        id: {
          [Op.ne]: appointment.id
        }
      }
    });

    if (existingAppointment) {
      throw new Error('This time slot is already booked');
    }
  }
});

module.exports = Appointment; 