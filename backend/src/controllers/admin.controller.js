const adminService = require('../services/admin.service');
const userService = require('../services/user.service');
const hospitalService = require('../services/hospital.service');
const planService = require('../services/plan.service');
const appointmentService = require('../services/appointment.service');
const { validateAdmin } = require('../middleware/auth.middleware');

class AdminController {
  // Dashboard methods
  async getDashboard(req, res) {
    try {
      const stats = await adminService.getDashboardStats();
      res.json(stats);
    } catch (error) {
      console.error('Error getting dashboard stats:', error);
      res.status(500).json({
        error: 'Failed to get dashboard statistics',
        details: error.message
      });
    }
  }

  async getSystemHealth(req, res) {
    try {
      const health = await adminService.getSystemHealth();
      res.json(health);
    } catch (error) {
      console.error('Error getting system health:', error);
      res.status(500).json({
        error: 'Failed to get system health status',
        details: error.message
      });
    }
  }

  async getAdminNotifications(req, res) {
    try {
      const notifications = await adminService.getAdminNotifications();
      res.json(notifications);
    } catch (error) {
      console.error('Error getting admin notifications:', error);
      res.status(500).json({
        error: 'Failed to get admin notifications',
        details: error.message
      });
    }
  }

  async getReports(req, res) {
    try {
      const { type, startDate, endDate } = req.query;
      let report;

      switch (type) {
        case 'users':
          report = await adminService.generateUserReport(startDate, endDate);
          break;
        case 'appointments':
          report = await adminService.generateAppointmentReport(startDate, endDate);
          break;
        case 'revenue':
          report = await adminService.generateRevenueReport(startDate, endDate);
          break;
        case 'hospitals':
          report = await adminService.generateHospitalReport(startDate, endDate);
          break;
        default:
          throw new Error('Invalid report type');
      }

      res.json(report);
    } catch (error) {
      console.error('Error generating report:', error);
      res.status(500).json({
        error: 'Failed to generate report',
        details: error.message
      });
    }
  }

  // User management methods
  async getUsers(req, res) {
    try {
      const { page = 1, limit = 10, search, status, role } = req.query;
      const users = await userService.getUsers({ page, limit, search, status, role });
      res.json(users);
    } catch (error) {
      console.error('Error getting users:', error);
      res.status(500).json({
        error: 'Failed to get users',
        details: error.message
      });
    }
  }

  async getUserDetails(req, res) {
    try {
      const { id } = req.params;
      const user = await userService.getUserDetails(id);
      res.json(user);
    } catch (error) {
      console.error('Error getting user details:', error);
      res.status(500).json({
        error: 'Failed to get user details',
        details: error.message
      });
    }
  }

  async updateUser(req, res) {
    try {
      const { id } = req.params;
      const userData = req.body;
      const user = await userService.updateUser(id, userData);
      res.json(user);
    } catch (error) {
      console.error('Error updating user:', error);
      res.status(500).json({
        error: 'Failed to update user',
        details: error.message
      });
    }
  }

  async deleteUser(req, res) {
    try {
      const { id } = req.params;
      await userService.deleteUser(id);
      res.json({ message: 'User deleted successfully' });
    } catch (error) {
      console.error('Error deleting user:', error);
      res.status(500).json({
        error: 'Failed to delete user',
        details: error.message
      });
    }
  }

  // Hospital management methods
  async getHospitals(req, res) {
    try {
      const { page = 1, limit = 10, search, city, specialty } = req.query;
      const hospitals = await hospitalService.getHospitals({ page, limit, search, city, specialty });
      res.json(hospitals);
    } catch (error) {
      console.error('Error getting hospitals:', error);
      res.status(500).json({
        error: 'Failed to get hospitals',
        details: error.message
      });
    }
  }

  async createHospital(req, res) {
    try {
      const hospitalData = req.body;
      const hospital = await hospitalService.createHospital(hospitalData);
      res.status(201).json(hospital);
    } catch (error) {
      console.error('Error creating hospital:', error);
      res.status(500).json({
        error: 'Failed to create hospital',
        details: error.message
      });
    }
  }

  async getHospitalDetails(req, res) {
    try {
      const { id } = req.params;
      const hospital = await hospitalService.getHospitalDetails(id);
      res.json(hospital);
    } catch (error) {
      console.error('Error getting hospital details:', error);
      res.status(500).json({
        error: 'Failed to get hospital details',
        details: error.message
      });
    }
  }

  async updateHospital(req, res) {
    try {
      const { id } = req.params;
      const hospitalData = req.body;
      const hospital = await hospitalService.updateHospital(id, hospitalData);
      res.json(hospital);
    } catch (error) {
      console.error('Error updating hospital:', error);
      res.status(500).json({
        error: 'Failed to update hospital',
        details: error.message
      });
    }
  }

  async deleteHospital(req, res) {
    try {
      const { id } = req.params;
      await hospitalService.deleteHospital(id);
      res.json({ message: 'Hospital deleted successfully' });
    } catch (error) {
      console.error('Error deleting hospital:', error);
      res.status(500).json({
        error: 'Failed to delete hospital',
        details: error.message
      });
    }
  }

  // Plan management methods
  async getPlans(req, res) {
    try {
      const { page = 1, limit = 10, search } = req.query;
      const plans = await planService.getPlans({ page, limit, search });
      res.json(plans);
    } catch (error) {
      console.error('Error getting plans:', error);
      res.status(500).json({
        error: 'Failed to get plans',
        details: error.message
      });
    }
  }

  async createPlan(req, res) {
    try {
      const planData = req.body;
      const plan = await planService.createPlan(planData);
      res.status(201).json(plan);
    } catch (error) {
      console.error('Error creating plan:', error);
      res.status(500).json({
        error: 'Failed to create plan',
        details: error.message
      });
    }
  }

  async getPlanDetails(req, res) {
    try {
      const { id } = req.params;
      const plan = await planService.getPlanDetails(id);
      res.json(plan);
    } catch (error) {
      console.error('Error getting plan details:', error);
      res.status(500).json({
        error: 'Failed to get plan details',
        details: error.message
      });
    }
  }

  async updatePlan(req, res) {
    try {
      const { id } = req.params;
      const planData = req.body;
      const plan = await planService.updatePlan(id, planData);
      res.json(plan);
    } catch (error) {
      console.error('Error updating plan:', error);
      res.status(500).json({
        error: 'Failed to update plan',
        details: error.message
      });
    }
  }

  async deletePlan(req, res) {
    try {
      const { id } = req.params;
      await planService.deletePlan(id);
      res.json({ message: 'Plan deleted successfully' });
    } catch (error) {
      console.error('Error deleting plan:', error);
      res.status(500).json({
        error: 'Failed to delete plan',
        details: error.message
      });
    }
  }

  // Appointment management methods
  async getAppointments(req, res) {
    try {
      const { page = 1, limit = 10, status, date, hospitalId } = req.query;
      const appointments = await appointmentService.getAppointments({ page, limit, status, date, hospitalId });
      res.json(appointments);
    } catch (error) {
      console.error('Error getting appointments:', error);
      res.status(500).json({
        error: 'Failed to get appointments',
        details: error.message
      });
    }
  }

  async getAppointmentDetails(req, res) {
    try {
      const { id } = req.params;
      const appointment = await appointmentService.getAppointmentDetails(id);
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
      const appointmentData = req.body;
      const appointment = await appointmentService.updateAppointment(id, appointmentData);
      res.json(appointment);
    } catch (error) {
      console.error('Error updating appointment:', error);
      res.status(500).json({
        error: 'Failed to update appointment',
        details: error.message
      });
    }
  }

  async deleteAppointment(req, res) {
    try {
      const { id } = req.params;
      await appointmentService.deleteAppointment(id);
      res.json({ message: 'Appointment deleted successfully' });
    } catch (error) {
      console.error('Error deleting appointment:', error);
      res.status(500).json({
        error: 'Failed to delete appointment',
        details: error.message
      });
    }
  }

  // Claims management methods
  async getClaims(req, res) {
    try {
      const { page = 1, limit = 10, status, userId } = req.query;
      const claims = await adminService.getClaims({ page, limit, status, userId });
      res.json(claims);
    } catch (error) {
      console.error('Error getting claims:', error);
      res.status(500).json({
        error: 'Failed to get claims',
        details: error.message
      });
    }
  }

  async getClaimDetails(req, res) {
    try {
      const { id } = req.params;
      const claim = await adminService.getClaimDetails(id);
      res.json(claim);
    } catch (error) {
      console.error('Error getting claim details:', error);
      res.status(500).json({
        error: 'Failed to get claim details',
        details: error.message
      });
    }
  }

  async updateClaim(req, res) {
    try {
      const { id } = req.params;
      const claimData = req.body;
      const claim = await adminService.updateClaim(id, claimData);
      res.json(claim);
    } catch (error) {
      console.error('Error updating claim:', error);
      res.status(500).json({
        error: 'Failed to update claim',
        details: error.message
      });
    }
  }

  // Medical records methods
  async getMedicalRecords(req, res) {
    try {
      const { page = 1, limit = 10, userId, verified } = req.query;
      const records = await adminService.getMedicalRecords({ page, limit, userId, verified });
      res.json(records);
    } catch (error) {
      console.error('Error getting medical records:', error);
      res.status(500).json({
        error: 'Failed to get medical records',
        details: error.message
      });
    }
  }

  async getMedicalRecordDetails(req, res) {
    try {
      const { id } = req.params;
      const record = await adminService.getMedicalRecordDetails(id);
      res.json(record);
    } catch (error) {
      console.error('Error getting medical record details:', error);
      res.status(500).json({
        error: 'Failed to get medical record details',
        details: error.message
      });
    }
  }

  async verifyMedicalRecord(req, res) {
    try {
      const { id } = req.params;
      const { verified, notes } = req.body;
      const record = await adminService.verifyMedicalRecord(id, verified, notes);
      res.json(record);
    } catch (error) {
      console.error('Error verifying medical record:', error);
      res.status(500).json({
        error: 'Failed to verify medical record',
        details: error.message
      });
    }
  }

  // Settings methods
  async getSettings(req, res) {
    try {
      const settings = await adminService.getSettings();
      res.json(settings);
    } catch (error) {
      console.error('Error getting settings:', error);
      res.status(500).json({
        error: 'Failed to get settings',
        details: error.message
      });
    }
  }

  async updateSettings(req, res) {
    try {
      const settingsData = req.body;
      const settings = await adminService.updateSettings(settingsData);
      res.json(settings);
    } catch (error) {
      console.error('Error updating settings:', error);
      res.status(500).json({
        error: 'Failed to update settings',
        details: error.message
      });
    }
  }
}

module.exports = new AdminController(); 