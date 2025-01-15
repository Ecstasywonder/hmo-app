import 'package:flutter/material.dart';

class MedicalRecordsVerificationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> pendingRecords;

  const MedicalRecordsVerificationScreen({
    super.key,
    required this.pendingRecords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Medical Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingRecords.length,
        itemBuilder: (context, index) {
          final record = pendingRecords[index];
          return Card(
            child: ListTile(
              title: Text(record['type']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record['description']),
                  Text(record['doctor']),
                  Text(record['date']),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                    onPressed: () => _verifyRecord(context, record),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    color: Colors.red,
                    onPressed: () => _rejectRecord(context, record),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _verifyRecord(BuildContext context, Map<String, dynamic> record) {
    // Update record status to verified
    record['status'] = 'Verified';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record verified')),
    );
  }

  void _rejectRecord(BuildContext context, Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Record'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              record['status'] = 'Rejected';
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record rejected')),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
} 