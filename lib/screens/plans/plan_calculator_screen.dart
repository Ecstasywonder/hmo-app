import 'package:flutter/material.dart';
import 'package:hmo_app/screens/plans/family_member_form.dart';

class PlanCalculatorScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const PlanCalculatorScreen({
    super.key,
    required this.plan,
  });

  @override
  State<PlanCalculatorScreen> createState() => _PlanCalculatorScreenState();
}

class _PlanCalculatorScreenState extends State<PlanCalculatorScreen> {
  int _familyMembers = 0;
  bool _internationalCoverage = false;
  bool _dentalCoverage = false;
  bool _visionCoverage = false;

  double get _basePrice => double.parse(
    widget.plan['price'].toString().replaceAll(',', '')
  );
  double get _totalPrice {
    double total = _basePrice;
    total += _familyMembers * 25000; // ₦25,000 per family member
    if (_internationalCoverage) total += 50000;
    if (_dentalCoverage) total += 30000;
    if (_visionCoverage) total += 20000;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Calculator', 
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFamilyMembersSection(),
                const Divider(height: 32),
                _buildAdditionalCoverageSection(),
                const Divider(height: 32),
                _buildPriceBreakdown(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Family Members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _familyMembers > 0 
                  ? () => setState(() => _familyMembers--)
                  : null,
            ),
            Text(
              '$_familyMembers members',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => setState(() => _familyMembers++),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _familyMembers > 0 ? _showFamilyMemberForm : null,
          child: const Text('Add Family Members'),
        ),
      ],
    );
  }

  Widget _buildAdditionalCoverageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Coverage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('International Coverage'),
          subtitle: const Text('₦50,000/year'),
          value: _internationalCoverage,
          onChanged: (value) => setState(() => _internationalCoverage = value),
        ),
        SwitchListTile(
          title: const Text('Dental Coverage'),
          subtitle: const Text('₦30,000/year'),
          value: _dentalCoverage,
          onChanged: (value) => setState(() => _dentalCoverage = value),
        ),
        SwitchListTile(
          title: const Text('Vision Coverage'),
          subtitle: const Text('₦20,000/year'),
          value: _visionCoverage,
          onChanged: (value) => setState(() => _visionCoverage = value),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Base Plan', _basePrice),
            if (_familyMembers > 0)
              _buildPriceRow(
                'Family Members ($_familyMembers)',
                _familyMembers * 25000,
              ),
            if (_internationalCoverage)
              _buildPriceRow('International Coverage', 50000),
            if (_dentalCoverage)
              _buildPriceRow('Dental Coverage', 30000),
            if (_visionCoverage)
              _buildPriceRow('Vision Coverage', 20000),
            const Divider(),
            _buildPriceRow('Total', _totalPrice, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            '₦${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total Annual Premium'),
                Text(
                  '₦${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'totalPrice': _totalPrice,
              'familyMembers': _familyMembers,
              'internationalCoverage': _internationalCoverage,
              'dentalCoverage': _dentalCoverage,
              'visionCoverage': _visionCoverage,
            }),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showFamilyMemberForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyMemberForm(
          memberCount: _familyMembers,
        ),
      ),
    );
    if (result != null) {
      // Handle family member details
      setState(() {
        // Store family member details if needed
      });
    }
  }
} 