const express = require('express');
const router = express.Router();
const supportController = require('../controllers/support.controller');
const { authenticate } = require('../middleware/auth');

// Public routes
router.get('/faqs', supportController.getFAQs);
router.get('/faqs/search', supportController.searchFAQs);

// Protected routes - require authentication
router.use(authenticate);

// Support tickets
router.post('/tickets', supportController.createTicket);
router.get('/tickets', supportController.getUserTickets);
router.get('/tickets/:id', supportController.getTicketDetails);
router.post('/tickets/:id/messages', supportController.addMessage);
router.post('/tickets/:id/close', supportController.closeTicket);

module.exports = router; 