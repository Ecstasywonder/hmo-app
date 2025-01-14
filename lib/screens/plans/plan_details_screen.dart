import 'package:flutter/material.dart';

class PlanDetailsScreen extends StatelessWidget {
  const PlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Details',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Plan Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'CareLink HMO',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Health Plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valid until Dec 31, 2024',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: const Text('Active'),
                    backgroundColor: Colors.green[50],
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coverage Details
                  const Text(
                    'Coverage Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCoverageItem(
                    context,
                    'Hospital Admission',
                    '100% coverage',
                    Icons.local_hospital,
                  ),
                  _buildCoverageItem(
                    context,
                    'Outpatient Care',
                    '90% coverage',
                    Icons.medical_services,
                  ),
                  _buildCoverageItem(
                    context,
                    'Prescription Drugs',
                    '80% coverage',
                    Icons.medication,
                  ),
                  _buildCoverageItem(
                    context,
                    'Specialist Visits',
                    'Unlimited visits',
                    Icons.person,
                  ),
                  _buildCoverageItem(
                    context,
                    'Emergency Care',
                    '100% coverage',
                    Icons.emergency,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Network Hospitals
                  const Text(
                    'Network Hospitals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHospitalItem(
                    'City General Hospital',
                    '123 Healthcare Street',
                  ),
                  _buildHospitalItem(
                    'St. Mary\'s Medical Center',
                    '456 Medical Avenue',
                  ),
                  _buildHospitalItem(
                    'Unity Healthcare',
                    '789 Wellness Road',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Plan Documents
                  const Text(
                    'Plan Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentItem(
                    context,
                    'Policy Document',
                    'PDF, 2.5 MB',
                    Icons.description,
                  ),
                  _buildDocumentItem(
                    context,
                    'Coverage Schedule',
                    'PDF, 1.2 MB',
                    Icons.schedule,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageItem(
    BuildContext context,
    String title,
    String coverage,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  coverage,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalItem(String name, String address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text(address),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to hospital details
        },
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    String title,
    String details,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(details),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // Handle document download
          },
        ),
      ),
    );
  }
} 