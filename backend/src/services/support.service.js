const { SupportTicket, FAQ, Message, User } = require('../models');
const { Op } = require('sequelize');
const { sendEmail } = require('../utils/email');

class SupportService {
  async createSupportTicket(userId, data) {
    try {
      const { subject, description, priority, category, attachments } = data;

      const ticket = await SupportTicket.create({
        userId,
        subject,
        description,
        priority,
        category,
        attachments,
        status: 'open',
        ticketNumber: await this._generateTicketNumber()
      });

      // Send confirmation email to user
      const user = await User.findByPk(userId);
      await sendEmail({
        to: user.email,
        subject: `Support Ticket Created - ${ticket.ticketNumber}`,
        template: 'support-ticket-created',
        data: {
          userName: user.firstName,
          ticketNumber: ticket.ticketNumber,
          subject: ticket.subject
        }
      });

      return ticket;
    } catch (error) {
      throw new Error(`Error creating support ticket: ${error.message}`);
    }
  }

  async getUserTickets(userId, status) {
    try {
      const where = { userId };
      if (status) {
        where.status = status;
      }

      const tickets = await SupportTicket.findAll({
        where,
        order: [
          ['updatedAt', 'DESC']
        ],
        include: [{
          model: Message,
          as: 'messages',
          limit: 1,
          order: [['createdAt', 'DESC']]
        }]
      });

      return tickets;
    } catch (error) {
      throw new Error(`Error fetching user tickets: ${error.message}`);
    }
  }

  async getTicketDetails(ticketId, userId) {
    try {
      const ticket = await SupportTicket.findOne({
        where: {
          id: ticketId,
          userId
        },
        include: [{
          model: Message,
          as: 'messages',
          include: [{
            model: User,
            as: 'sender',
            attributes: ['id', 'firstName', 'lastName', 'avatar', 'role']
          }],
          order: [['createdAt', 'ASC']]
        }]
      });

      if (!ticket) {
        throw new Error('Ticket not found');
      }

      return ticket;
    } catch (error) {
      throw new Error(`Error fetching ticket details: ${error.message}`);
    }
  }

  async addMessageToTicket(ticketId, userId, message) {
    try {
      const ticket = await SupportTicket.findByPk(ticketId);
      if (!ticket) {
        throw new Error('Ticket not found');
      }

      const newMessage = await Message.create({
        ticketId,
        senderId: userId,
        content: message,
        type: 'text'
      });

      // Update ticket status if it was closed
      if (ticket.status === 'closed') {
        await ticket.update({ status: 'reopened' });
      }

      // Update ticket's last activity
      await ticket.update({ lastActivityAt: new Date() });

      return newMessage;
    } catch (error) {
      throw new Error(`Error adding message to ticket: ${error.message}`);
    }
  }

  async closeTicket(ticketId, userId) {
    try {
      const ticket = await SupportTicket.findOne({
        where: {
          id: ticketId,
          userId
        }
      });

      if (!ticket) {
        throw new Error('Ticket not found');
      }

      await ticket.update({ status: 'closed' });

      // Send closure confirmation email
      const user = await User.findByPk(userId);
      await sendEmail({
        to: user.email,
        subject: `Support Ticket Closed - ${ticket.ticketNumber}`,
        template: 'support-ticket-closed',
        data: {
          userName: user.firstName,
          ticketNumber: ticket.ticketNumber,
          subject: ticket.subject
        }
      });

      return ticket;
    } catch (error) {
      throw new Error(`Error closing ticket: ${error.message}`);
    }
  }

  async getFAQs(category) {
    try {
      const where = {};
      if (category) {
        where.category = category;
      }

      const faqs = await FAQ.findAll({
        where,
        order: [
          ['category', 'ASC'],
          ['order', 'ASC']
        ]
      });

      return faqs;
    } catch (error) {
      throw new Error(`Error fetching FAQs: ${error.message}`);
    }
  }

  async searchFAQs(query) {
    try {
      const faqs = await FAQ.findAll({
        where: {
          [Op.or]: [
            { question: { [Op.iLike]: `%${query}%` } },
            { answer: { [Op.iLike]: `%${query}%` } }
          ]
        },
        order: [['category', 'ASC']]
      });

      return faqs;
    } catch (error) {
      throw new Error(`Error searching FAQs: ${error.message}`);
    }
  }

  // Private helper methods
  async _generateTicketNumber() {
    const prefix = 'TKT';
    const date = new Date().toISOString().slice(2, 10).replace(/-/g, '');
    const count = await SupportTicket.count({
      where: {
        createdAt: {
          [Op.gte]: new Date().setHours(0, 0, 0, 0)
        }
      }
    });
    
    return `${prefix}${date}${(count + 1).toString().padStart(4, '0')}`;
  }
}

module.exports = new SupportService(); 