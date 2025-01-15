import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/admin_notification_service.dart';
import 'package:hmo_app/screens/admin/admin_notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Dashboard Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminNotificationsScreen(),
                        ),
                      ),
                    ),
                    Consumer<AdminNotificationService>(
                      builder: (context, service, _) => service.unreadCount > 0
                        ? Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${service.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification Card
          Consumer<AdminNotificationService>(
            builder: (context, service, _) => service.unreadCount > 0
              ? Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.orange),
                    title: Text('${service.unreadCount} pending notifications'),
                    subtitle: const Text('Tap to view new records for verification'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminNotificationsScreen(),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          ),
          // Test Button
          ElevatedButton(
            onPressed: () {
              context.read<AdminNotificationService>().addNotification(
                title: 'Test Notification',
                message: 'Testing notification system',
                type: 'record_verification',
                data: {
                  'type': 'Test Record',
                  'description': 'Test Description',
                  'doctor': 'Dr. Test',
                  'date': DateTime.now().toString(),
                  'status': 'Pending Verification',
                },
              );
            },
            child: const Text('Add Test Notification'),
          ),
          // Add more dashboard content here
        ],
      ),
    );
  }
} 