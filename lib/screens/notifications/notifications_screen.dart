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
        itemCount: 10, // Replace with actual notifications count
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
    Color color;

    switch (type) {
      case 'appointment':
        icon = Icons.calendar_today;
        title = 'Appointment Reminder';
        message = 'Your appointment is scheduled for tomorrow at 10:00 AM';
        color = Colors.blue;
        break;
      case 'plan':
        icon = Icons.health_and_safety;
        title = 'Plan Update';
        message = 'Your health plan coverage has been updated';
        color = Theme.of(context).primaryColor;
        break;
      default:
        icon = Icons.notifications;
        title = 'Important Notice';
        message = 'New features available in the app';
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
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
} 