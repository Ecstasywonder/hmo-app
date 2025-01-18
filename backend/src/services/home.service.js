const { User, Plan, Hospital, Appointment, MedicalRecord } = require('../models');
const { Op } = require('sequelize');

class HomeService {
  async getDashboardData(userId) {
    try {
      // Get user data with active plan
      const user = await User.findByPk(userId, {
        include: [{
          model: Plan,
          as: 'activePlan',
          attributes: ['id', 'name', 'coverage', 'price', 'validUntil', 'benefits', 'rating', 'subscribers']
        }]
      });

      // Get quick stats
      const [appointments, hospitals, medicalRecords] = await Promise.all([
        Appointment.count({ where: { userId, status: 'pending' } }),
        Hospital.count({ where: { isActive: true } }),
        MedicalRecord.count({ where: { userId } })
      ]);

      return {
        user: {
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          avatar: user.avatar
        },
        activePlan: user.activePlan,
        stats: {
          pendingAppointments: appointments,
          availableHospitals: hospitals,
          medicalRecords: medicalRecords
        }
      };
    } catch (error) {
      throw new Error(`Error fetching dashboard data: ${error.message}`);
    }
  }

  async getRecommendedPlans(userId) {
    try {
      const user = await User.findByPk(userId, {
        include: [{
          model: Plan,
          as: 'activePlan'
        }]
      });

      // Get plans similar to user's active plan or top-rated plans if no active plan
      const plans = await Plan.findAll({
        where: user.activePlan ? {
          id: { [Op.ne]: user.activePlan.id },
          price: {
            [Op.between]: [
              user.activePlan.price * 0.7, // 30% cheaper
              user.activePlan.price * 1.3  // 30% more expensive
            ]
          }
        } : {
          isActive: true
        },
        order: [
          ['rating', 'DESC'],
          ['subscribers', 'DESC']
        ],
        limit: 5,
        attributes: ['id', 'name', 'coverage', 'price', 'rating', 'subscribers']
      });

      return plans;
    } catch (error) {
      throw new Error(`Error fetching recommended plans: ${error.message}`);
    }
  }

  async getQuickActions(userId) {
    try {
      const [
        pendingAppointments,
        unreadNotifications,
        incompleteMedicalRecords
      ] = await Promise.all([
        Appointment.findAll({
          where: { userId, status: 'pending' },
          limit: 5,
          order: [['date', 'ASC']],
          attributes: ['id', 'date', 'time', 'hospitalId', 'type']
        }),
        // Add notification check when implemented
        Promise.resolve([]),
        MedicalRecord.findAll({
          where: { 
            userId,
            isComplete: false
          },
          limit: 5,
          order: [['createdAt', 'DESC']],
          attributes: ['id', 'recordType', 'recordDate']
        })
      ]);

      return {
        pendingAppointments,
        unreadNotifications,
        incompleteMedicalRecords
      };
    } catch (error) {
      throw new Error(`Error fetching quick actions: ${error.message}`);
    }
  }
}

module.exports = new HomeService(); 