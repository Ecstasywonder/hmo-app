import 'package:flutter/material.dart';
import 'package:hmo_app/screens/appointments/book_appointment_screen.dart';
import 'package:hmo_app/screens/hospitals/find_hospital_screen.dart';
import 'package:hmo_app/screens/plans/my_plan_screen.dart';
import 'package:hmo_app/screens/support/support_screen.dart';
import 'package:hmo_app/screens/plans/plan_details_screen.dart';
import 'package:hmo_app/screens/notifications/notifications_screen.dart';
import 'package:hmo_app/screens/profile/profile_screen.dart';
import 'package:hmo_app/screens/providers/hmo_providers_screen.dart';
import 'package:hmo_app/screens/plans/plan_comparison_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareLink',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildQuickActionCard(
                  context,
                  'Book Appointment',
                  Icons.calendar_today,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Find Hospital',
                  Icons.local_hospital,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FindHospitalScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'My Plan',
                  Icons.health_and_safety,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyPlanScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Support',
                  Icons.headset_mic,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SupportScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.medical_information),
                  title: const Text('Medical Records'),
                  subtitle: const Text('View your health records'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/medical-records'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Active Plan Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Plan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlanDetailsScreen(
                                plan: {
                                  'name': 'Premium Health Plan',
                                  'price': '45000',
                                  'coverage': 'Full Coverage',
                                  'rating': '4.8',
                                  'subscribers': '10K+',
                                },
                              ),
                            ),
                          ),
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Premium Health Plan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until Dec 31, 2024',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Other HMO Providers Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Other HMO Providers',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HmoProvidersScreen()),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildHmoProviderCard(
                        context,
                        'Premium Care HMO',
                        '4.8',
                        '₦45,000/year',
                        () {},
                      ),
                      _buildHmoProviderCard(
                        context,
                        'HealthPlus HMO',
                        '4.6',
                        '₦38,000/year',
                        () {},
                      ),
                      _buildHmoProviderCard(
                        context,
                        'MediCare HMO',
                        '4.7',
                        '₦42,000/year',
                        () {},
                      ),
                       _buildHmoProviderCard(
                        context,
                        'Optimus MediCare HMO',
                        '4.7',
                        '₦72,000/year',
                        () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHmoProviderCard(
    BuildContext context,
    String name,
    String rating,
    String price,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.health_and_safety,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(rating),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlanComparisonScreen(
                      plans: [
                        {
                          'name': 'Basic',
                          'price': '25000',
                          'coverage': '60%',
                          'features': ['4 visits/year', 'Basic Coverage'],
                        },
                        {
                          'name': 'Standard',
                          'price': '45000',
                          'coverage': '80%',
                          'features': ['8 visits/year', 'Enhanced Coverage'],
                        },
                        {
                          'name': 'Premium',
                          'price': '65000',
                          'coverage': '100%',
                          'features': ['Unlimited visits', 'Full Coverage'],
                        },
                      ],
                    ),
                  ),
                ),
                child: const Text('Compare Plans'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 