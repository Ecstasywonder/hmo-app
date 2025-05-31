import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSupportCard(
              context,
              title: 'Frequently Asked Questions',
              description: 'Find answers to common questions about our services',
              icon: Icons.help_outline,
              onTap: () => Navigator.pushNamed(context, '/support/faq'),
            ),
            const SizedBox(height: 16),
            _buildSupportCard(
              context,
              title: 'Live Chat',
              description: 'Chat with our support team in real-time',
              icon: Icons.chat_bubble_outline,
              onTap: () => Navigator.pushNamed(context, '/support/chat'),
            ),
            const SizedBox(height: 16),
            _buildSupportCard(
              context,
              title: 'Submit a Ticket',
              description: 'Create a support ticket for specific issues',
              icon: Icons.assignment_outlined,
              onTap: () => Navigator.pushNamed(context, '/support/ticket'),
            ),
            const SizedBox(height: 16),
            _buildSupportCard(
              context,
              title: 'Contact Information',
              description: 'View our contact details and office locations',
              icon: Icons.contact_phone_outlined,
              onTap: () => Navigator.pushNamed(context, '/support/contact'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Emergency Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emergency, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Emergency Hotline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'For medical emergencies, please call:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement call functionality
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Text(
                            '1-800-EMERGENCY',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Available 24/7 for emergency assistance',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Operating Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOperatingHours('Monday - Friday', '8:00 AM - 8:00 PM'),
                    const Divider(),
                    _buildOperatingHours('Saturday', '9:00 AM - 5:00 PM'),
                    const Divider(),
                    _buildOperatingHours('Sunday', '10:00 AM - 3:00 PM'),
                    const SizedBox(height: 8),
                    Text(
                      'All times are in local timezone',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Text(
                title,
                style: const TextStyle(
                        fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                      description,
                style: TextStyle(
                        fontSize: 14,
                  color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatingHours(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(hours),
        ],
      ),
    );
  }
} 