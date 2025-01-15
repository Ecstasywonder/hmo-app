import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildNotificationItem(
            context,
            index % 3 == 0 ? 'appointment' : index % 2 == 0 ? 'plan' : 'general',
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, String type) {
    IconData icon;
    String title;
    String message;
    String fullDetails;
    Color color;

    switch (type) {
      case 'appointment':
        icon = Icons.calendar_today;
        title = 'Appointment Reminder';
        message = 'Your appointment is scheduled for tomorrow at 10:00 AM';
        fullDetails = '''
Dr. Sarah Johnson
Department: Cardiology
Location: Main Hospital, Floor 3
Room: 304

Please arrive 15 minutes early to complete registration.
Bring your health card and any recent test results.

Need to reschedule? Call (555) 123-4567''';
        color = Colors.blue;
        break;
      case 'plan':
        icon = Icons.health_and_safety;
        title = 'Plan Update';
        message = 'Your health plan coverage has been updated';
        fullDetails = '''
Your Premium Health Plan has been updated with the following changes:

• Added dental coverage
• Increased prescription coverage limit
• New wellness program benefits
• International coverage now included

These changes are effective from next month.
View your updated plan details in My Plan section.''';
        color = Theme.of(context).primaryColor;
        break;
      default:
        icon = Icons.notifications;
        title = 'Important Notice';
        message = 'New features available in the app';
        fullDetails = '''
We've added exciting new features to improve your experience:

• Virtual consultations
• Digital health records
• Medication reminders
• Wellness tracking
• Enhanced security

Update your app to access these features.
Learn more in the Help section.''';
        color = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '2h ago',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        onTap: () => _showNotificationDetails(
          context,
          title,
          fullDetails,
          color,
          icon,
        ),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    String title,
    String details,
    Color color,
    IconData icon,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  details,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 