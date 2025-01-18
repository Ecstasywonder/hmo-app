const { Hospital, Doctor, Review, Specialty, Schedule, Plan } = require('../models');
const { Op } = require('sequelize');

class HospitalService {
  async searchHospitals(filters = {}) {
    try {
      const {
        name,
        city,
        state,
        specialty,
        rating,
        planId,
        page = 1,
        limit = 10
      } = filters;

      const where = {
        isActive: true
      };

      if (name) {
        where.name = { [Op.iLike]: `%${name}%` };
      }

      if (city) {
        where.city = { [Op.iLike]: `%${city}%` };
      }

      if (state) {
        where.state = { [Op.iLike]: `%${state}%` };
      }

      if (rating) {
        where.rating = { [Op.gte]: rating };
      }

      const include = [
        {
          model: Specialty,
          as: 'specialties',
          where: specialty ? { name: specialty } : undefined,
          required: !!specialty
        },
        {
          model: Plan,
          as: 'acceptedPlans',
          where: planId ? { id: planId } : undefined,
          required: !!planId
        }
      ];

      const offset = (page - 1) * limit;

      const { rows: hospitals, count } = await Hospital.findAndCountAll({
        where,
        include,
        order: [['rating', 'DESC']],
        limit,
        offset,
        distinct: true
      });

      return {
        hospitals,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error searching hospitals: ${error.message}`);
    }
  }

  async getHospitalDetails(hospitalId) {
    try {
      const hospital = await Hospital.findByPk(hospitalId, {
        include: [
          {
            model: Doctor,
            as: 'doctors',
            attributes: ['id', 'name', 'specialty', 'experience', 'rating', 'availability']
          },
          {
            model: Review,
            as: 'reviews',
            attributes: ['id', 'rating', 'comment', 'createdAt'],
            include: [{
              model: User,
              as: 'user',
              attributes: ['id', 'firstName', 'lastName', 'avatar']
            }],
            limit: 5,
            order: [['createdAt', 'DESC']]
          },
          {
            model: Specialty,
            as: 'specialties',
            through: { attributes: [] }
          },
          {
            model: Schedule,
            as: 'schedule',
            attributes: ['day', 'openTime', 'closeTime', 'isOpen']
          },
          {
            model: Plan,
            as: 'acceptedPlans',
            through: { attributes: [] },
            attributes: ['id', 'name']
          }
        ]
      });

      if (!hospital) {
        throw new Error('Hospital not found');
      }

      return hospital;
    } catch (error) {
      throw new Error(`Error fetching hospital details: ${error.message}`);
    }
  }

  async getHospitalSchedule(hospitalId, date) {
    try {
      const schedule = await Schedule.findOne({
        where: {
          hospitalId,
          day: date.getDay()
        }
      });

      if (!schedule || !schedule.isOpen) {
        return {
          isOpen: false,
          availableSlots: []
        };
      }

      // Get all appointments for the given date to determine available slots
      const appointments = await Appointment.findAll({
        where: {
          hospitalId,
          date: {
            [Op.between]: [
              date.setHours(0, 0, 0, 0),
              date.setHours(23, 59, 59, 999)
            ]
          },
          status: {
            [Op.notIn]: ['cancelled']
          }
        },
        attributes: ['time']
      });

      // Generate available time slots based on schedule and existing appointments
      const availableSlots = this._generateAvailableSlots(
        schedule.openTime,
        schedule.closeTime,
        appointments.map(a => a.time)
      );

      return {
        isOpen: true,
        schedule,
        availableSlots
      };
    } catch (error) {
      throw new Error(`Error fetching hospital schedule: ${error.message}`);
    }
  }

  async getHospitalReviews(hospitalId, page = 1, limit = 10) {
    try {
      const offset = (page - 1) * limit;

      const { rows: reviews, count } = await Review.findAndCountAll({
        where: { hospitalId },
        include: [{
          model: User,
          as: 'user',
          attributes: ['id', 'firstName', 'lastName', 'avatar']
        }],
        order: [['createdAt', 'DESC']],
        limit,
        offset
      });

      return {
        reviews,
        pagination: {
          total: count,
          page: parseInt(page),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      throw new Error(`Error fetching hospital reviews: ${error.message}`);
    }
  }

  async addHospitalReview(hospitalId, userId, data) {
    try {
      const { rating, comment } = data;

      const review = await Review.create({
        hospitalId,
        userId,
        rating,
        comment
      });

      // Update hospital average rating
      await this._updateHospitalRating(hospitalId);

      return review;
    } catch (error) {
      throw new Error(`Error adding hospital review: ${error.message}`);
    }
  }

  // Private helper methods
  _generateAvailableSlots(openTime, closeTime, bookedSlots) {
    const slots = [];
    const [openHour, openMinute] = openTime.split(':').map(Number);
    const [closeHour, closeMinute] = closeTime.split(':').map(Number);
    
    let currentSlot = new Date().setHours(openHour, openMinute, 0, 0);
    const endTime = new Date().setHours(closeHour, closeMinute, 0, 0);
    
    while (currentSlot < endTime) {
      const timeString = new Date(currentSlot).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
      });
      
      if (!bookedSlots.includes(timeString)) {
        slots.push(timeString);
      }
      
      // Add 30 minutes for next slot
      currentSlot += 30 * 60 * 1000;
    }
    
    return slots;
  }

  async _updateHospitalRating(hospitalId) {
    const avgRating = await Review.findOne({
      where: { hospitalId },
      attributes: [
        [sequelize.fn('AVG', sequelize.col('rating')), 'averageRating']
      ]
    });

    await Hospital.update(
      { rating: avgRating.getDataValue('averageRating') },
      { where: { id: hospitalId } }
    );
  }
}

module.exports = new HospitalService(); 