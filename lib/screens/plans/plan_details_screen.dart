import 'package:flutter/material.dart';
import 'package:hmo_app/screens/plans/plan_comparison_screen.dart';
import 'package:hmo_app/screens/plans/plan_calculator_screen.dart';

class PlanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> plan;

  const PlanDetailsScreen({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan['name'], style: const TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlanCalculatorScreen(plan: plan),
                ),
              );
              if (result != null) {
                // Handle calculator result by showing a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Calculated Plan'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Premium: ₦${result['totalPrice']}'),
                        Text('Family Members: ${result['familyMembers']}'),
                        if (result['internationalCoverage']) 
                          const Text('International Coverage: Included'),
                        if (result['dentalCoverage']) 
                          const Text('Dental Coverage: Included'),
                        if (result['visionCoverage']) 
                          const Text('Vision Coverage: Included'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEnrollmentDialog(context);
                        },
                        child: const Text('Proceed to Enroll'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanComparisonScreen(
                  plans: [
                    const {
                      'name': 'Basic',
                      'price': '25,000',
                      'coverage': '60%',
                      'features': ['4 visits/year', 'Basic Coverage'],
                    },
                    plan, // Current plan
                    const {
                      'name': 'Premium',
                      'price': '65,000',
                      'coverage': '100%',
                      'features': ['Unlimited visits', 'Full Coverage'],
                    },
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanHeader(context),
            const SizedBox(height: 24),
            _buildCoverageSection(),
            const SizedBox(height: 24),
            _buildBenefitsSection(),
            const SizedBox(height: 24),
            _buildNetworkSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showEnrollmentDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Enroll Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '₦${plan['price']}/year',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['coverage'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(plan['rating']),
                const SizedBox(width: 16),
                Text(
                  plan['subscribers'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coverage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCoverageItem('Hospital Services', '100%'),
        _buildCoverageItem('Specialist Consultations', '80%'),
        _buildCoverageItem('Prescription Drugs', '70%'),
        _buildCoverageItem('Emergency Services', '100%'),
        _buildCoverageItem('Preventive Care', '100%'),
      ],
    );
  }

  Widget _buildCoverageItem(String service, String coverage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service),
          Text(
            coverage,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benefits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitItem('24/7 Customer Support'),
        _buildBenefitItem('Nationwide Coverage'),
        _buildBenefitItem('No Waiting Period'),
        _buildBenefitItem('Family Coverage Available'),
        _buildBenefitItem('Dental and Vision Coverage'),
      ],
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(benefit),
        ],
      ),
    );
  }

  Widget _buildNetworkSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hospital Network',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.local_hospital),
          title: Text('General Hospital Lagos'),
          subtitle: Text('Lagos, Nigeria'),
        ),
        ListTile(
          leading: Icon(Icons.local_hospital),
          title: Text('University College Hospital'),
          subtitle: Text('Ibadan, Nigeria'),
        ),
        ListTile(
          leading: Icon(Icons.local_hospital),
          title: Text('National Hospital'),
          subtitle: Text('Abuja, Nigeria'),
        ),
      ],
    );
  }

  void _showEnrollmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Plan Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${plan['name']}'),
            const SizedBox(height: 8),
            Text('Price: ₦${plan['price']}/year'),
            const SizedBox(height: 16),
            const Text(
              'By proceeding, you agree to the terms and conditions.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentDialog(context);
            },
            child: const Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }

  void _showEnrollmentSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enrollment Successful'),
        content: const Text(
          'You have successfully enrolled in this health plan. You will receive a confirmation email shortly.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize Your Plan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomizationOption(
          'Add Family Members',
          'Cover your spouse and children',
          2500,
        ),
        _buildCustomizationOption(
          'International Coverage',
          'Get coverage while traveling abroad',
          5000,
        ),
        _buildCustomizationOption(
          'Dental Premium',
          'Enhanced dental coverage',
          3000,
        ),
      ],
    );
  }

  Widget _buildCustomizationOption(String title, String description, int price) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text('₦$price/year\n$description'),
      value: false,
      onChanged: (bool? value) {
        // Handle customization selection
      },
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit/Debit Card'),
              onTap: () => _processCardPayment(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Transfer'),
              onTap: () => _processBankTransfer(context),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('USSD'),
              onTap: () => _processUSSDPayment(context),
            ),
          ],
        ),
      ),
    );
  }

  void _processCardPayment(BuildContext context) {
    Navigator.pop(context); // Close payment methods sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Card Details'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Expiry',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEnrollmentSuccess(context);
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _processBankTransfer(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Transfer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bank: First Bank\nAccount: 1234567890\nName: CareLink HMO'),
            SizedBox(height: 16),
            Text('Please make transfer and upload proof of payment'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEnrollmentSuccess(context);
            },
            child: const Text('Upload Receipt'),
          ),
        ],
      ),
    );
  }

  void _processUSSDPayment(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('USSD Payment'),
        content: const Text('Dial *123*1234# to complete payment'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEnrollmentSuccess(context);
            },
            child: const Text('I have paid'),
          ),
        ],
      ),
    );
  }
} 