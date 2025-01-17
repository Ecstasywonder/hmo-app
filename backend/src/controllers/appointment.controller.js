const appointmentService = require('../services/appointment.service');
const hospitalService = require('../services/hospital.service');
const notificationService = require('../services/notification.service');

class AppointmentController {
  async getSpecialties(req, res) {
    try {
      const specialties = await hospitalService.getSpecialties();
      res.json(specialties);
    } catch (error) {
      console.error('Error getting specialties:', error);
      res.status(500).json({
        error: 'Failed to get specialties',
        details: error.message
      });
    }
  }

  async getHospitalsBySpecialty(req, res) {
    try {
      const { specialty, city } = req.query;
      const hospitals = await hospitalService.getHospitalsBySpecialty(specialty, city);
      res.json(hospitals);
    } catch (error) {
      console.error('Error getting hospitals:', error);
      res.status(500).json({
        error: 'Failed to get hospitals',
        details: error.message
      });
    }
  }

  async getAvailableTimeSlots(req, res) {
    try {
      const { hospitalId, date } = req.query;
      if (!hospitalId || !date) {
        return res.status(400).json({
          error: 'Hospital ID and date are required'
        });
      }

      const timeSlots = await appointmentService.getAvailableSlots(hospitalId, date);
      res.json(timeSlots);
    } catch (error) {
      console.error('Error getting time slots:', error);
      res.status(500).json({
        error: 'Failed to get time slots',
        details: error.message
      });
    }
  }

  async bookAppointment(req, res) {
    try {
      const userId = req.user.id;
      const appointmentData = {
        ...req.body,
        userId
      };

      // Validate required fields
      const requiredFields = ['hospitalId', 'date', 'time', 'type'];
      const missingFields = requiredFields.filter(field => !appointmentData[field]);
      if (missingFields.length > 0) {
        return res.status(400).json({
          error: 'Missing required fields',
          fields: missingFields
        });
      }

      const appointment = await appointmentService.createAppointment(userId, appointmentData);

      // Send notifications
      await notificationService.sendNotification(userId, 'appointment_confirmation', {
        appointmentId: appointment.id,
        hospitalName: appointment.Hospital.name,
        date: appointment.date,
        time: appointment.time
      });

      res.status(201).json(appointment);
    } catch (error) {
      console.error('Error booking appointment:', error);
      res.status(500).json({
        error: 'Failed to book appointment',
        details: error.message
      });
    }
  }

  async getUserAppointments(req, res) {
    try {
      const userId = req.user.id;
      const { status, startDate, endDate } = req.query;

      const appointments = await appointmentService.getUserAppointments(userId, {
        status,
        startDate,
        endDate
      });

      res.json(appointments);
    } catch (error) {
      console.error('Error getting user appointments:', error);
      res.status(500).json({
        error: 'Failed to get appointments',
        details: error.message
      });
    }
  }

  async getAppointmentDetails(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const appointment = await appointmentService.getAppointmentDetails(id);

      // Check if user has access to this appointment
      if (appointment.userId !== userId && req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'Access denied'
        });
      }

      res.json(appointment);
    } catch (error) {
      console.error('Error getting appointment details:', error);
      res.status(500).json({
        error: 'Failed to get appointment details',
        details: error.message
      });
    }
  }

  async updateAppointment(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const appointmentData = req.body;

      const appointment = await appointmentService.getAppointmentDetails(id);

      // Check if user has access to update this appointment
      if (appointment.userId !== userId && req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'Access denied'
        });
      }

      const updatedAppointment = await appointmentService.updateAppointment(id, appointmentData);

      // Send notification
      await notificationService.sendNotification(userId, 'appointment_updated', {
        appointmentId: updatedAppointment.id,
        hospitalName: updatedAppointment.Hospital.name,
        date: updatedAppointment.date,
        time: updatedAppointment.time
      });

      res.json(updatedAppointment);
    } catch (error) {
      console.error('Error updating appointment:', error);
      res.status(500).json({
        error: 'Failed to update appointment',
        details: error.message
      });
    }
  }

  async cancelAppointment(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const { reason } = req.body;

      const appointment = await appointmentService.getAppointmentDetails(id);

      // Check if user has access to cancel this appointment
      if (appointment.userId !== userId && req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'Access denied'
        });
      }

      const cancelledAppointment = await appointmentService.cancelAppointment(id, reason);

      // Send notification
      await notificationService.sendNotification(userId, 'appointment_cancelled', {
        appointmentId: cancelledAppointment.id,
        hospitalName: cancelledAppointment.Hospital.name,
        date: cancelledAppointment.date,
        time: cancelledAppointment.time,
        reason
      });

      res.json(cancelledAppointment);
    } catch (error) {
      console.error('Error cancelling appointment:', error);
      res.status(500).json({
        error: 'Failed to cancel appointment',
        details: error.message
      });
    }
  }

  async getAppointmentHistory(req, res) {
    try {
      const userId = req.user.id;
      const { page = 1, limit = 10 } = req.query;

      const history = await appointmentService.getAppointmentHistory(userId, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      res.json(history);
    } catch (error) {
      console.error('Error getting appointment history:', error);
      res.status(500).json({
        error: 'Failed to get appointment history',
        details: error.message
      });
    }
  }

  async rescheduleAppointment(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const { date, time } = req.body;

      if (!date || !time) {
        return res.status(400).json({
          error: 'Date and time are required for rescheduling'
        });
      }

      const appointment = await appointmentService.getAppointmentDetails(id);

      // Check if user has access to reschedule this appointment
      if (appointment.userId !== userId && req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'Access denied'
        });
      }

      const rescheduledAppointment = await appointmentService.rescheduleAppointment(id, {
        date,
        time
      });

      // Send notification
      await notificationService.sendNotification(userId, 'appointment_rescheduled', {
        appointmentId: rescheduledAppointment.id,
        hospitalName: rescheduledAppointment.Hospital.name,
        date: rescheduledAppointment.date,
        time: rescheduledAppointment.time
      });

      res.json(rescheduledAppointment);
    } catch (error) {
      console.error('Error rescheduling appointment:', error);
      res.status(500).json({
        error: 'Failed to reschedule appointment',
        details: error.message
      });
    }
  }

  async confirmAppointment(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const appointment = await appointmentService.getAppointmentDetails(id);

      // Check if user has access to confirm this appointment
      if (appointment.userId !== userId && req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'Access denied'
        });
      }

      const confirmedAppointment = await appointmentService.confirmAppointment(id);

      // Send notification
      await notificationService.sendNotification(userId, 'appointment_confirmed', {
        appointmentId: confirmedAppointment.id,
        hospitalName: confirmedAppointment.Hospital.name,
        date: confirmedAppointment.date,
        time: confirmedAppointment.time
      });

      res.json(confirmedAppointment);
    } catch (error) {
      console.error('Error confirming appointment:', error);
      res.status(500).json({
        error: 'Failed to confirm appointment',
        details: error.message
      });
    }
  }
}

module.exports = new AppointmentController(); 