import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/screens/admin/manage_claims_screen.dart';
import 'package:hmo_app/screens/admin/manage_hospitals_screen.dart';
import 'package:hmo_app/screens/admin/reports_screen.dart';
import 'package:hmo_app/screens/admin/settings_screen.dart';
import 'package:hmo_app/screens/admin/manage_users_screen.dart';
import 'package:hmo_app/services/auth_service.dart';
import 'package:hmo_app/services/admin_notification_service.dart';
import 'package:hmo_app/screens/admin/admin_notifications_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', 
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        context.read<AuthService>().logout(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        children: [
          _buildDashboardCard(
            context,
            'Manage Claims',
            Icons.assignment,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageClaimsScreen(),
              ),
            ),
          ),
          _buildDashboardCard(
            context,
            'Manage Hospitals',
            Icons.local_hospital,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageHospitalsScreen(),
              ),
            ),
          ),
          _buildDashboardCard(
            context,
            'Reports & Analytics',
            Icons.analytics,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportsScreen(),
              ),
            ),
          ),
          _buildDashboardCard(
            context,
            'Manage Users',
            Icons.people,
            Colors.indigo,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageUsersScreen(),
              ),
            ),
          ),
          _buildDashboardCard(
            context,
            'Settings',
            Icons.settings,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 