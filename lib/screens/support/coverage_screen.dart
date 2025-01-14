import 'package:flutter/material.dart';

class CoverageScreen extends StatelessWidget {
  const CoverageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coverage',
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
            // Plan Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Health Plan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CareLink HMO',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Coverage Categories
            Text(
              'What\'s Covered',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildCoverageCategory(
              context,
              'Hospital Services',
              [
                CoverageItem('Inpatient Care', '100% covered', true),
                CoverageItem('Emergency Room', '100% covered', true),
                CoverageItem('Surgery', '100% covered', true),
                CoverageItem('ICU Care', '100% covered', true),
              ],
            ),
            
            _buildCoverageCategory(
              context,
              'Outpatient Services',
              [
                CoverageItem('Doctor Visits', '90% covered', true),
                CoverageItem('Specialist Consultations', '80% covered', true),
                CoverageItem('Lab Tests', '100% covered', true),
                CoverageItem('X-Rays', '100% covered', true),
              ],
            ),
            
            _buildCoverageCategory(
              context,
              'Medications',
              [
                CoverageItem('Prescription Drugs', '80% covered', true),
                CoverageItem('Generic Medications', '100% covered', true),
                CoverageItem('Specialty Drugs', '70% covered', true),
              ],
            ),
            
            _buildCoverageCategory(
              context,
              'Preventive Care',
              [
                CoverageItem('Annual Check-ups', '100% covered', true),
                CoverageItem('Immunizations', '100% covered', true),
                CoverageItem('Cancer Screenings', '100% covered', true),
                CoverageItem('Wellness Programs', '100% covered', true),
              ],
            ),

            const SizedBox(height: 24),
            
            // Coverage Limits
            Text(
              'Coverage Limits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildLimitItem(
                      context,
                      'Annual Coverage Limit',
                      '₦10,000,000',
                      Icons.account_balance,
                    ),
                    const Divider(),
                    _buildLimitItem(
                      context,
                      'Per Visit Limit',
                      '₦100,000',
                      Icons.local_hospital,
                    ),
                    const Divider(),
                    _buildLimitItem(
                      context,
                      'Medication Limit',
                      '₦500,000',
                      Icons.medication,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageCategory(
    BuildContext context,
    String title,
    List<CoverageItem> items,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          children: items.map((item) => _buildCoverageItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildCoverageItem(BuildContext context, CoverageItem item) {
    return ListTile(
      title: Text(item.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.coverage,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            item.isIncluded ? Icons.check_circle : Icons.remove_circle,
            color: item.isIncluded ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitItem(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoverageItem {
  final String name;
  final String coverage;
  final bool isIncluded;

  CoverageItem(this.name, this.coverage, this.isIncluded);
} 