const { Hospital, Appointment } = require('../models');
const { Op } = require('sequelize');

class HospitalService {
  async createHospital(data) {
    return await Hospital.create({
      name: data.name,
      address: data.address,
      city: data.city,
      state: data.state,
      phone: data.phone,
      email: data.email,
      specialties: data.specialties || [],
      facilities: data.facilities || [],
      workingHours: data.workingHours || {
        monday: { start: '09:00', end: '17:00' },
        tuesday: { start: '09:00', end: '17:00' },
        wednesday: { start: '09:00', end: '17:00' },
        thursday: { start: '09:00', end: '17:00' },
        friday: { start: '09:00', end: '17:00' }
      },
      status: 'active',
      rating: 0,
      totalRatings: 0
    });
  }

  async updateHospital(id, data) {
    const hospital = await Hospital.findByPk(id);
    
    if (!hospital) {
      throw new Error('Hospital not found');
    }

    await hospital.update({
      name: data.name || hospital.name,
      address: data.address || hospital.address,
      city: data.city || hospital.city,
      state: data.state || hospital.state,
      phone: data.phone || hospital.phone,
      email: data.email || hospital.email,
      specialties: data.specialties || hospital.specialties,
      facilities: data.facilities || hospital.facilities,
      workingHours: data.workingHours || hospital.workingHours,
      status: data.status || hospital.status
    });

    return hospital;
  }

  async searchHospitals(filters = {}) {
    const where = {
      status: 'active',
      ...(filters.city && { city: filters.city }),
      ...(filters.state && { state: filters.state }),
      ...(filters.specialty && {
        specialties: {
          [Op.contains]: [filters.specialty]
        }
      }),
      ...(filters.search && {
        [Op.or]: [
          { name: { [Op.iLike]: `%${filters.search}%` } },
          { address: { [Op.iLike]: `%${filters.search}%` } },
          { city: { [Op.iLike]: `%${filters.search}%` } }
        ]
      })
    };

    return await Hospital.findAll({
      where,
      order: [
        ...(filters.sortBy === 'rating' ? [['rating', 'DESC']] : []),
        ['name', 'ASC']
      ],
      limit: filters.limit || 10,
      offset: filters.offset || 0
    });
  }

  async getHospitalDetails(id) {
    const hospital = await Hospital.findByPk(id);
    
    if (!hospital) {
      throw new Error('Hospital not found');
    }

    // Get upcoming appointments count
    const appointmentCounts = await Appointment.findAll({
      where: {
        hospitalId: id,
        date: {
          [Op.gte]: new Date()
        }
      },
      attributes: [
        'date',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['date'],
      raw: true
    });

    return {
      ...hospital.toJSON(),
      appointmentCounts
    };
  }

  async rateHospital(id, rating, review = '') {
    const hospital = await Hospital.findByPk(id);
    
    if (!hospital) {
      throw new Error('Hospital not found');
    }

    // Update rating
    const newTotalRatings = hospital.totalRatings + 1;
    const newRating = (hospital.rating * hospital.totalRatings + rating) / newTotalRatings;

    await hospital.update({
      rating: newRating,
      totalRatings: newTotalRatings,
      reviews: [
        ...hospital.reviews || [],
        {
          rating,
          review,
          date: new Date()
        }
      ]
    });

    return hospital;
  }

  async getHospitalStats(id) {
    const hospital = await Hospital.findByPk(id);
    
    if (!hospital) {
      throw new Error('Hospital not found');
    }

    // Get appointment statistics
    const appointmentStats = await Appointment.findAll({
      where: { hospitalId: id },
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['status'],
      raw: true
    });

    // Get monthly appointment trends
    const monthlyTrends = await Appointment.findAll({
      where: {
        hospitalId: id,
        createdAt: {
          [Op.gte]: new Date(new Date().setMonth(new Date().getMonth() - 12))
        }
      },
      attributes: [
        [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'month'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt'))],
      order: [[sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'ASC']],
      raw: true
    });

    return {
      general: {
        totalAppointments: appointmentStats.reduce((sum, stat) => sum + parseInt(stat.count), 0),
        rating: hospital.rating,
        totalRatings: hospital.totalRatings
      },
      appointmentStats,
      monthlyTrends
    };
  }
}

module.exports = new HospitalService(); 