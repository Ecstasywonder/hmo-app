import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/widgets/theme_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hmo_app/services/admin_notification_service.dart';

class UserMedicalRecordsScreen extends StatefulWidget {
  const UserMedicalRecordsScreen({super.key});

  @override
  State<UserMedicalRecordsScreen> createState() => _UserMedicalRecordsScreenState();
}

class _UserMedicalRecordsScreenState extends State<UserMedicalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedCategory = 'All';
  
  final List<Map<String, dynamic>> _records = [
    {
      'type': 'Lab Results',
      'description': 'Annual health checkup results',
      'doctor': 'Dr. Sarah Johnson',
      'date': '2024-01-15',
      'status': 'Completed',
      'details': {
        'Blood Pressure': '120/80',
        'Heart Rate': '72 bpm',
        'Cholesterol': '180 mg/dL',
        'Blood Sugar': '90 mg/dL',
      },
      'attachments': ['blood_test.pdf', 'urinalysis.pdf'],
    },
    {
      'type': 'Prescription',
      'description': 'Medication for hypertension',
      'doctor': 'Dr. Michael Brown',
      'date': '2024-01-20',
      'status': 'Active',
      'details': {
        'Medication': 'Lisinopril 10mg',
        'Dosage': '1 tablet daily',
        'Duration': '3 months',
        'Notes': 'Take with food',
      },
      'attachments': ['prescription.pdf'],
    },
  ];

  final List<String> _categories = [
    'All',
    'Lab Results',
    'Prescriptions',
    'Diagnoses',
    'Vaccinations',
    'Surgeries',
    'Dental',
    'Vision',
    'Mental Health',
    'Physical Therapy',
    'Allergies',
    'X-Ray/Imaging',
    'Other'
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((category) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  ),
                ).toList(),
              ),
            ),
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _filteredRecords.map((record) => _buildRecordCard(record)).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddRecordDialog(context),
          label: const Text('Add Record'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredRecords {
    return _records.where((record) {
      final matchesSearch = record['type'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record['description'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || record['type'] == _selectedCategory;
      final matchesStatus = _selectedFilter == 'All' || record['status'] == _selectedFilter;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final isPending = record['status'] == 'Pending Verification';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        enabled: !isPending,
        title: Text(
          record['type'],
          style: TextStyle(
            color: isPending ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record['description'],
              style: TextStyle(
                color: isPending ? Colors.grey : null,
              ),
            ),
            Text(
              record['doctor'],
              style: TextStyle(
                color: isPending ? Colors.grey : null,
              ),
            ),
            Text(
              record['date'],
              style: TextStyle(
                color: isPending ? Colors.grey : null,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(record['status']),
          backgroundColor: _getStatusColor(record['status']),
        ),
        onTap: isPending ? null : () => _showRecordDetails(record),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.withOpacity(0.1);
      case 'Pending Verification':
        return Colors.orange.withOpacity(0.1);
      case 'Active':
        return Colors.blue.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Records'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('All Records'),
              value: 'All',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value.toString());
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Active'),
              value: 'Active',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value.toString());
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Completed'),
              value: 'Completed',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value.toString());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record['type']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Basic Information', [
                _buildDetailRow('Doctor', record['doctor']),
                _buildDetailRow('Date', record['date']),
                _buildDetailRow('Status', record['status']),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Details', 
                (record['details'] as Map<String, dynamic>).entries.map(
                  (e) => _buildDetailRow(e.key, e.value.toString())
                ).toList(),
              ),
              if (record['attachments'].isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Attachments', 
                  record['attachments'].map<Widget>((file) => 
                    ListTile(
                      leading: const Icon(Icons.attachment),
                      title: Text(file),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _downloadFile(file),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _shareRecord(record, file),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ],
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _downloadFile(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // Implement file opening logic
          },
        ),
      ),
    );
  }

  void _shareRecord(Map<String, dynamic> record, String fileName) async {
    await Share.share(
      'Medical Record: ${record['type']}\nDate: ${record['date']}\nDoctor: ${record['doctor']}\nFile: $fileName',
      subject: 'Medical Record - ${record['type']}',
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medical Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_document),
              title: const Text('Fill Template'),
              onTap: () {
                Navigator.pop(context);
                _showRecordTemplate(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Document'),
              onTap: () {
                Navigator.pop(context);
                _uploadDocument(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordTemplate(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? selectedType;
    final descriptionController = TextEditingController();
    final doctorController = TextEditingController();
    DateTime? recordDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Medical Record',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Record Type',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedType,
                  items: [
                    'Lab Results',
                    'Prescription',
                    'Diagnosis',
                    'Vaccination',
                    'Surgery',
                    'Dental',
                    'Vision',
                    'Mental Health',
                    'Physical Therapy',
                    'Allergy Test',
                    'X-Ray/Imaging',
                    'Other'
                  ].map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  validator: (value) => value == null ? 'Please select a type' : null,
                  onChanged: (value) => selectedType = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true 
                      ? 'Please enter a description' 
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: doctorController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor/Hospital',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true 
                      ? 'Please enter doctor/hospital name' 
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: recordDate?.toString().split(' ')[0] ?? '',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      recordDate = date;
                    }
                  },
                  validator: (value) => recordDate == null 
                      ? 'Please select a date' 
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            // Add record with pending verification status
                            setState(() {
                              _records.add({
                                'type': selectedType,
                                'description': descriptionController.text,
                                'doctor': doctorController.text,
                                'date': recordDate.toString().split(' ')[0],
                                'status': 'Pending Verification',
                                'details': {},
                                'attachments': [],
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Record added successfully'),
                              ),
                            );
                            context.read<AdminNotificationService>().addNotification(
                              title: 'New Medical Record',
                              message: 'A new medical record needs verification',
                              type: 'record_verification',
                              data: {
                                'type': selectedType,
                                'description': descriptionController.text,
                                'doctor': doctorController.text,
                                'date': recordDate.toString().split(' ')[0],
                                'status': 'Pending Verification',
                                'details': {},
                                'attachments': [],
                              },
                            );
                          }
                        },
                        child: const Text('Save Record'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _uploadDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final file = result.files.first;
        
        // Show form to add metadata
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Document Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Selected file: ${file.name}'),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Document Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Notes',
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
                  // Add document record with pending verification
                  setState(() {
                    _records.add({
                      'type': 'Document',
                      'description': file.name,
                      'doctor': 'Uploaded Document',
                      'date': DateTime.now().toString().split(' ')[0],
                      'status': 'Pending Verification',
                      'details': {},
                      'attachments': [file.name],
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document uploaded successfully'),
                    ),
                  );
                  context.read<AdminNotificationService>().addNotification(
                    title: 'New Medical Record',
                    message: 'A new medical record needs verification',
                    type: 'record_verification',
                    data: {
                      'type': 'Document',
                      'description': file.name,
                      'doctor': 'Uploaded Document',
                      'date': DateTime.now().toString().split(' ')[0],
                      'status': 'Pending Verification',
                      'details': {},
                      'attachments': [file.name],
                    },
                  );
                },
                child: const Text('Upload'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading document'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 