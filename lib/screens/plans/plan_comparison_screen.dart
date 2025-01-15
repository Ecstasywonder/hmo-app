import 'package:flutter/material.dart';

class PlanComparisonScreen extends StatelessWidget {
  final List<Map<String, dynamic>> plans;
  
  const PlanComparisonScreen({
    super.key,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Plans', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Features')),
            DataColumn(label: Text('Basic')),
            DataColumn(label: Text('Standard')),
            DataColumn(label: Text('Premium')),
          ],
          rows: [
            _buildDataRow('Price', ['₦25,000/yr', '₦45,000/yr', '₦65,000/yr']),
            _buildDataRow('Hospital Coverage', ['60%', '80%', '100%']),
            _buildDataRow('Specialist Visits', ['4/year', '8/year', 'Unlimited']),
            _buildDataRow('Dental Coverage', ['No', 'Basic', 'Full']),
            _buildDataRow('Vision Coverage', ['No', 'Basic', 'Full']),
            _buildDataRow('Maternity', ['No', 'Basic', 'Full']),
            _buildDataRow('Emergency Care', ['Basic', 'Full', 'Full + Int\'l']),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String feature, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(fontWeight: FontWeight.bold))),
        ...values.map((value) => DataCell(Text(value))),
      ],
    );
  }
} 