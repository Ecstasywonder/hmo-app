import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/admin_notification_service.dart';
import 'package:hmo_app/screens/admin/medical_records_verification_screen.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              context.read<AdminNotificationService>().markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<AdminNotificationService>(
        builder: (context, service, child) {
          if (service.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: service.notifications.length,
            itemBuilder: (context, index) {
              final notification = service.notifications[index];
              return Card(
                color: notification['read'] 
                    ? null 
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                child: ListTile(
                  leading: _getNotificationIcon(notification['type']),
                  title: Text(notification['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['message']),
                      Text(
                        _formatTimestamp(notification['timestamp']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    service.markAsRead(notification['id']);
                    _handleNotificationTap(context, notification);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'record_verification':
        return const Icon(Icons.medical_information, color: Colors.blue);
      case 'user_report':
        return const Icon(Icons.report_problem, color: Colors.orange);
      default:
        return const Icon(Icons.notifications);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'record_verification':
        if (notification['data'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalRecordsVerificationScreen(
                pendingRecords: [notification['data']],
              ),
            ),
          );
        }
        break;
      // Handle other notification types
    }
  }
} 