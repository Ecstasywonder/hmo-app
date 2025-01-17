const { Appointment, User, Hospital } = require('../models');
const emailService = require('./email.service');
const { Op } = require('sequelize');

class AppointmentService {
  async createAppointment(userId, data) {
    const appointment = await Appointment.create({
      userId,
      hospitalId: data.hospitalId,
      date: data.date,
      time: data.time,
      type: data.type,
      reason: data.reason,
      status: 'pending',
      notes: data.notes
    });

    // Load user and hospital details for email
    const [user, hospital] = await Promise.all([
      User.findByPk(userId),
      Hospital.findByPk(data.hospitalId)
    ]);

    // Send confirmation email
    await emailService.transporter.sendMail({
      to: user.email,
      subject: 'Appointment Scheduled',
      html: `
        <h2>Appointment Confirmation</h2>
        <p>Your appointment has been scheduled with ${hospital.name}</p>
        <p>Date: ${data.date}</p>
        <p>Time: ${data.time}</p>
        <p>Type: ${data.type}</p>
        <p>Status: Pending confirmation</p>
      `
    });

    return appointment;
  }

  async updateAppointment(id, data) {
    const appointment = await Appointment.findByPk(id, {
      include: [User, Hospital]
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    await appointment.update({
      date: data.date || appointment.date,
      time: data.time || appointment.time,
      type: data.type || appointment.type,
      reason: data.reason || appointment.reason,
      status: data.status || appointment.status,
      notes: data.notes || appointment.notes
    });

    // Send update email
    await emailService.transporter.sendMail({
      to: appointment.User.email,
      subject: 'Appointment Updated',
      html: `
        <h2>Appointment Update</h2>
        <p>Your appointment with ${appointment.Hospital.name} has been updated</p>
        <p>New Date: ${appointment.date}</p>
        <p>New Time: ${appointment.time}</p>
        <p>Status: ${appointment.status}</p>
      `
    });

    return appointment;
  }

  async cancelAppointment(id, reason) {
    const appointment = await Appointment.findByPk(id, {
      include: [User, Hospital]
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    await appointment.update({
      status: 'cancelled',
      cancellationReason: reason
    });

    // Send cancellation email
    await emailService.transporter.sendMail({
      to: appointment.User.email,
      subject: 'Appointment Cancelled',
      html: `
        <h2>Appointment Cancellation</h2>
        <p>Your appointment with ${appointment.Hospital.name} has been cancelled</p>
        <p>Date: ${appointment.date}</p>
        <p>Time: ${appointment.time}</p>
        <p>Reason: ${reason}</p>
      `
    });

    return appointment;
  }

  async getUserAppointments(userId, filters = {}) {
    const where = {
      userId,
      ...(filters.status && { status: filters.status }),
      ...(filters.startDate && filters.endDate && {
        date: {
          [Op.between]: [filters.startDate, filters.endDate]
        }
      })
    };

    return await Appointment.findAll({
      where,
      include: [
        {
          model: Hospital,
          attributes: ['id', 'name', 'address', 'phone']
        }
      ],
      order: [['date', 'ASC'], ['time', 'ASC']]
    });
  }

  async getHospitalAppointments(hospitalId, filters = {}) {
    const where = {
      hospitalId,
      ...(filters.status && { status: filters.status }),
      ...(filters.startDate && filters.endDate && {
        date: {
          [Op.between]: [filters.startDate, filters.endDate]
        }
      })
    };

    return await Appointment.findAll({
      where,
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'email', 'phone']
        }
      ],
      order: [['date', 'ASC'], ['time', 'ASC']]
    });
  }

  async getAvailableSlots(hospitalId, date) {
    // Get all appointments for the given date
    const appointments = await Appointment.findAll({
      where: {
        hospitalId,
        date,
        status: {
          [Op.notIn]: ['cancelled', 'rejected']
        }
      }
    });

    // Get hospital working hours (this should come from hospital settings)
    const workingHours = {
      start: '09:00',
      end: '17:00',
      slotDuration: 30 // minutes
    };

    // Generate all possible slots
    const slots = this.generateTimeSlots(
      workingHours.start,
      workingHours.end,
      workingHours.slotDuration
    );

    // Filter out booked slots
    const bookedTimes = appointments.map(apt => apt.time);
    return slots.filter(slot => !bookedTimes.includes(slot));
  }

  generateTimeSlots(start, end, duration) {
    const slots = [];
    let current = new Date(`2000-01-01 ${start}`);
    const endTime = new Date(`2000-01-01 ${end}`);

    while (current < endTime) {
      slots.push(current.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
      }));
      current = new Date(current.getTime() + duration * 60000);
    }

    return slots;
  }

  async getAppointmentDetails(id) {
    const appointment = await Appointment.findByPk(id, {
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'email', 'phone']
        },
        {
          model: Hospital,
          attributes: ['id', 'name', 'address', 'phone', 'email']
        }
      ]
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    return appointment;
  }

  async getAppointmentHistory(userId, { page = 1, limit = 10 }) {
    const offset = (page - 1) * limit;

    const [appointments, total] = await Promise.all([
      Appointment.findAll({
        where: {
          userId,
          status: {
            [Op.in]: ['completed', 'cancelled']
          }
        },
        include: [
          {
            model: Hospital,
            attributes: ['id', 'name', 'address']
          }
        ],
        order: [['date', 'DESC']],
        limit,
        offset
      }),
      Appointment.count({
        where: {
          userId,
          status: {
            [Op.in]: ['completed', 'cancelled']
          }
        }
      })
    ]);

    return {
      appointments,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  async rescheduleAppointment(id, { date, time }) {
    const appointment = await Appointment.findByPk(id, {
      include: [User, Hospital]
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Check if the new slot is available
    const isSlotAvailable = await this.isTimeSlotAvailable(
      appointment.hospitalId,
      date,
      time
    );

    if (!isSlotAvailable) {
      throw new Error('Selected time slot is not available');
    }

    await appointment.update({
      date,
      time,
      status: 'rescheduled'
    });

    // Send rescheduling email
    await emailService.transporter.sendMail({
      to: appointment.User.email,
      subject: 'Appointment Rescheduled',
      html: `
        <h2>Appointment Rescheduled</h2>
        <p>Your appointment with ${appointment.Hospital.name} has been rescheduled</p>
        <p>New Date: ${date}</p>
        <p>New Time: ${time}</p>
      `
    });

    return appointment;
  }

  async confirmAppointment(id) {
    const appointment = await Appointment.findByPk(id, {
      include: [User, Hospital]
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    await appointment.update({
      status: 'confirmed'
    });

    // Send confirmation email
    await emailService.transporter.sendMail({
      to: appointment.User.email,
      subject: 'Appointment Confirmed',
      html: `
        <h2>Appointment Confirmed</h2>
        <p>Your appointment with ${appointment.Hospital.name} has been confirmed</p>
        <p>Date: ${appointment.date}</p>
        <p>Time: ${appointment.time}</p>
        <p>Please arrive 15 minutes before your scheduled time.</p>
      `
    });

    return appointment;
  }

  async isTimeSlotAvailable(hospitalId, date, time) {
    const existingAppointment = await Appointment.findOne({
      where: {
        hospitalId,
        date,
        time,
        status: {
          [Op.notIn]: ['cancelled', 'rejected']
        }
      }
    });

    return !existingAppointment;
  }
}

module.exports = new AppointmentService(); 