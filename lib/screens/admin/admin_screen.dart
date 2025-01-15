import 'package:flutter/material.dart';
import 'package:hmo_app/screens/admin/dashboard_screen.dart';
import 'package:hmo_app/screens/admin/manage_users_screen.dart';
import 'package:hmo_app/screens/admin/medical_records_screen.dart';
import 'package:hmo_app/screens/admin/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/admin_notification_service.dart';
import 'package:hmo_app/screens/admin/admin_notifications_screen.dart';

final List<BottomNavigationBarItem> _navigationItems = [
  const BottomNavigationBarItem(
    icon: Icon(Icons.dashboard),
    label: 'Dashboard',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.people),
    label: 'Users',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.medical_information),
    label: 'Records',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.settings),
    label: 'Settings',
  ),
];

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ManageUsersScreen(),
    const MedicalRecordsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: _navigationItems,
      ),
    );
  }
} 