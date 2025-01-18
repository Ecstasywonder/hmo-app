const supportService = require('../services/support.service');
const { catchAsync } = require('../utils/error');

class SupportController {
  createTicket = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const ticketData = {
      subject: req.body.subject,
      description: req.body.description,
      priority: req.body.priority,
      category: req.body.category,
      attachments: req.body.attachments
    };

    const ticket = await supportService.createSupportTicket(userId, ticketData);
    res.status(201).json({
      success: true,
      data: ticket
    });
  });

  getUserTickets = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { status } = req.query;

    const tickets = await supportService.getUserTickets(userId, status);
    res.json({
      success: true,
      data: tickets
    });
  });

  getTicketDetails = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    const ticket = await supportService.getTicketDetails(id, userId);
    res.json({
      success: true,
      data: ticket
    });
  });

  addMessage = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { message } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        success: false,
        error: 'Message content is required'
      });
    }

    const newMessage = await supportService.addMessageToTicket(id, userId, message);
    res.status(201).json({
      success: true,
      data: newMessage
    });
  });

  closeTicket = catchAsync(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    const ticket = await supportService.closeTicket(id, userId);
    res.json({
      success: true,
      data: ticket
    });
  });

  getFAQs = catchAsync(async (req, res) => {
    const { category } = req.query;
    const faqs = await supportService.getFAQs(category);
    res.json({
      success: true,
      data: faqs
    });
  });

  searchFAQs = catchAsync(async (req, res) => {
    const { query } = req.query;

    if (!query || !query.trim()) {
      return res.status(400).json({
        success: false,
        error: 'Search query is required'
      });
    }

    const faqs = await supportService.searchFAQs(query);
    res.json({
      success: true,
      data: faqs
    });
  });
}

module.exports = new SupportController(); 