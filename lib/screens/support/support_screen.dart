import 'package:flutter/material.dart';
import 'package:hmo_app/screens/support/claims_screen.dart';
import 'package:hmo_app/screens/support/coverage_screen.dart';
import 'package:hmo_app/screens/support/contact_screen.dart';
import 'package:hmo_app/screens/support/faq_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Categories
            Text(
              'How can we help you?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Help Options
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildHelpCard(
                  context,
                  'Claims',
                  'Submit or track claims',
                  Icons.receipt_long,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClaimsScreen()),
                  ),
                ),
                _buildHelpCard(
                  context,
                  'Coverage',
                  'Check what\'s covered',
                  Icons.health_and_safety,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CoverageScreen()),
                  ),
                ),
                _buildHelpCard(
                  context,
                  'Contact Us',
                  'Get in touch with us',
                  Icons.headset_mic,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactScreen()),
                  ),
                ),
                _buildHelpCard(
                  context,
                  'FAQs',
                  'Common questions',
                  Icons.help_outline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqScreen()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Emergency Contact
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24/7 Emergency Support',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Call 0800-CARELINK',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone),
                      color: Theme.of(context).primaryColor,
                      onPressed: () => _makePhoneCall('1234567890'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Support Tickets
            Text(
              'Recent Tickets',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTicketItem(
              context,
              'Claim Inquiry',
              'Under Review',
              'Ticket #12345',
              Colors.orange,
            ),
            _buildTicketItem(
              context,
              'Coverage Question',
              'Resolved',
              'Ticket #12344',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketItem(
    BuildContext context,
    String title,
    String status,
    String ticketId,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(ticketId),
        trailing: Chip(
          label: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
            ),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
        ),
        onTap: () {
          // Handle ticket tap
        },
      ),
    );
  }
} 