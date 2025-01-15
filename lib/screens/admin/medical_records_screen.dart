import 'package:flutter/material.dart';
import 'package:hmo_app/widgets/theme_builder.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample medical records data
  final List<Map<String, dynamic>> _records = [
    {
      'patientName': 'John Doe',
      'patientId': 'HMO-2024-001',
      'recordType': 'Lab Results',
      'date': '2024-01-15',
      'doctor': 'Dr. Sarah Johnson',
      'status': 'Completed',
      'description': 'Annual health checkup results',
      'confidential': true,
    },
    {
      'patientName': 'Jane Smith',
      'patientId': 'HMO-2024-002',
      'recordType': 'Prescription',
      'date': '2024-01-20',
      'doctor': 'Dr. Michael Brown',
      'status': 'Active',
      'description': 'Medication for hypertension',
      'confidential': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme) => Scaffold(
        appBar: AppBar(
          title: Text('Medical Records', style: theme.textTheme.titleLarge),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search records...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return _buildRecordCard(record);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddRecordDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredRecords {
    final searchTerm = _searchController.text.toLowerCase();
    return _records.where((record) {
      return record['patientName'].toLowerCase().contains(searchTerm) ||
          record['patientId'].toLowerCase().contains(searchTerm) ||
          record['recordType'].toLowerCase().contains(searchTerm);
    }).toList();
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['patientName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${record['patientId']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (record['confidential'])
                  const Icon(Icons.lock, color: Colors.red),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _showRecordDetails(record);
                        break;
                      case 'edit':
                        _showEditRecordDialog(record);
                        break;
                      case 'download':
                        _downloadRecord(record);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(record['recordType']),
                const SizedBox(width: 8),
                _buildInfoChip(record['date']),
                const SizedBox(width: 8),
                _buildStatusChip(record['status']),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record['description'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              record['doctor'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildStatusChip(String status) {
    final isCompleted = status == 'Completed';
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: isCompleted ? Colors.green : Colors.blue,
        ),
      ),
      backgroundColor: (isCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Records'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Confidential Only'),
              value: false,
              onChanged: (value) {
                // Implement filter logic
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Show Active Only'),
              value: false,
              onChanged: (value) {
                // Implement filter logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record['recordType']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient Name', record['patientName']),
              _buildDetailRow('Patient ID', record['patientId']),
              _buildDetailRow('Date', record['date']),
              _buildDetailRow('Doctor', record['doctor']),
              _buildDetailRow('Status', record['status']),
              _buildDetailRow('Description', record['description']),
              if (record['confidential'])
                const Text(
                  '\nThis record contains confidential information',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    // Implement add record dialog
  }

  void _showEditRecordDialog(Map<String, dynamic> record) {
    // Implement edit record dialog
  }

  void _downloadRecord(Map<String, dynamic> record) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading record...'),
      ),
    );
  }
} 