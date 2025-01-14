import 'package:flutter/material.dart';
import 'package:hmo_app/screens/admin/manage_users_screen.dart';
import 'package:hmo_app/screens/admin/manage_plans_screen.dart';
import 'package:hmo_app/screens/admin/manage_appointments_screen.dart';
import 'package:hmo_app/screens/admin/manage_claims_screen.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              // Handle logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildAdminCard(
            context,
            'Manage Users',
            Icons.people,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            'Manage Plans',
            Icons.health_and_safety,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManagePlansScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            'Appointments',
            Icons.calendar_today,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageAppointmentsScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            'Claims',
            Icons.receipt_long,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageClaimsScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            'Hospitals',
            Icons.local_hospital,
            () {
              // Navigate to hospital management
            },
          ),
          _buildAdminCard(
            context,
            'Reports',
            Icons.bar_chart,
            () {
              // Navigate to reports
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
          ],
        ),
      ),
    );
  }
} 