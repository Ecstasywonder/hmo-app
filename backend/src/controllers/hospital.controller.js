const { Hospital, Appointment, User } = require('../models');
const { Op } = require('sequelize');

exports.getAllHospitals = async (req, res) => {
  try {
    const hospitals = await Hospital.findAll({
      where: { isActive: true },
      attributes: ['id', 'name', 'address', 'phone', 'email', 'specialties']
    });
    res.json(hospitals);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getHospitalById = async (req, res) => {
  try {
    const hospital = await Hospital.findOne({
      where: { id: req.params.id, isActive: true }
    });
    
    if (!hospital) {
      return res.status(404).json({ message: 'Hospital not found' });
    }
    
    res.json(hospital);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.searchHospitals = async (req, res) => {
  try {
    const { query, specialty, location } = req.query;
    const whereClause = { isActive: true };

    if (query) {
      whereClause.name = { [Op.iLike]: `%${query}%` };
    }

    if (specialty) {
      whereClause.specialties = { [Op.contains]: [specialty] };
    }

    if (location) {
      whereClause.address = { [Op.iLike]: `%${location}%` };
    }

    const hospitals = await Hospital.findAll({ where: whereClause });
    res.json(hospitals);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.createHospital = async (req, res) => {
  try {
    const { name, address, phone, email, specialties } = req.body;
    const hospital = await Hospital.create({
      name,
      address,
      phone,
      email,
      specialties,
      isActive: true
    });
    res.status(201).json(hospital);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updateHospital = async (req, res) => {
  try {
    const hospital = await Hospital.findByPk(req.params.id);
    if (!hospital) {
      return res.status(404).json({ message: 'Hospital not found' });
    }

    const { name, address, phone, email, specialties, isActive } = req.body;
    
    // Update hospital fields
    hospital.name = name || hospital.name;
    hospital.address = address || hospital.address;
    hospital.phone = phone || hospital.phone;
    hospital.email = email || hospital.email;
    hospital.specialties = specialties || hospital.specialties;
    hospital.isActive = isActive !== undefined ? isActive : hospital.isActive;

    await hospital.save();
    res.json(hospital);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteHospital = async (req, res) => {
  try {
    const hospital = await Hospital.findByPk(req.params.id);
    if (!hospital) {
      return res.status(404).json({ message: 'Hospital not found' });
    }

    // Soft delete
    hospital.isActive = false;
    await hospital.save();
    
    res.json({ message: 'Hospital deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.bookAppointment = async (req, res) => {
  try {
    const { hospitalId } = req.params;
    const { date, time, reason } = req.body;
    const userId = req.user.id;

    // Check if hospital exists and is active
    const hospital = await Hospital.findOne({
      where: { id: hospitalId, isActive: true }
    });

    if (!hospital) {
      return res.status(404).json({ message: 'Hospital not found or inactive' });
    }

    // Create appointment
    const appointment = await Appointment.create({
      userId,
      hospitalId,
      date,
      time,
      reason,
      status: 'pending'
    });

    res.status(201).json({
      message: 'Appointment booked successfully',
      appointment
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getUserAppointments = async (req, res) => {
  try {
    const appointments = await Appointment.findAll({
      where: { userId: req.user.id },
      include: [{
        model: Hospital,
        attributes: ['name', 'address', 'phone']
      }],
      order: [['date', 'DESC']]
    });
    res.json(appointments);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getHospitalAppointments = async (req, res) => {
  try {
    const appointments = await Appointment.findAll({
      where: { hospitalId: req.params.hospitalId },
      include: [{
        model: User,
        attributes: ['name', 'email', 'phone']
      }],
      order: [['date', 'ASC']]
    });
    res.json(appointments);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updateAppointmentStatus = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const { status } = req.body;

    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }

    appointment.status = status;
    await appointment.save();

    res.json({
      message: 'Appointment status updated successfully',
      appointment
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
}; 