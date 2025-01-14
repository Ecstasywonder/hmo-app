import 'package:flutter/material.dart';

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedClaimType = 'Medical';
  DateTime? _dateOfService;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _claimTypes = [
    'Medical',
    'Dental',
    'Vision',
    'Prescription',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Claims',
              style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Submit Claim'),
              Tab(text: 'Track Claims'),
            ],
            labelColor: Colors.black87,
          ),
        ),
        body: TabBarView(
          children: [
            // Submit Claim Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Claim Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedClaimType,
                      decoration: const InputDecoration(
                        labelText: 'Claim Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _claimTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClaimType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date of Service
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _dateOfService = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of Service',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _dateOfService != null
                              ? '${_dateOfService!.day}/${_dateOfService!.month}/${_dateOfService!.year}'
                              : 'Select date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (₦)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Upload Documents
                    OutlinedButton.icon(
                      onPressed: () {
                        // Handle document upload
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Documents'),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Handle claim submission
                          }
                        },
                        child: const Text('Submit Claim'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Track Claims Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // Replace with actual claims count
              itemBuilder: (context, index) {
                return _buildClaimCard(
                  claimId: '#${1000 + index}',
                  type: _claimTypes[index % _claimTypes.length],
                  amount: '₦${(index + 1) * 5000}',
                  date: '${DateTime.now().subtract(Duration(days: index * 3)).day}/'
                      '${DateTime.now().subtract(Duration(days: index * 3)).month}/'
                      '${DateTime.now().subtract(Duration(days: index * 3)).year}',
                  status: index % 3 == 0
                      ? 'Approved'
                      : index % 2 == 0
                          ? 'Pending'
                          : 'Under Review',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard({
    required String claimId,
    required String type,
    required String amount,
    required String date,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Row(
          children: [
            Text(claimId),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Type: $type'),
            Text('Amount: $amount'),
            Text('Date: $date'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Navigate to claim details
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 