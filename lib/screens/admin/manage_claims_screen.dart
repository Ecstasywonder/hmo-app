import 'package:flutter/material.dart';

class ManageClaimsScreen extends StatefulWidget {
  const ManageClaimsScreen({super.key});

  @override
  State<ManageClaimsScreen> createState() => _ManageClaimsScreenState();
}

class _ManageClaimsScreenState extends State<ManageClaimsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _claims = [
    {
      'id': 'CLM001',
      'patientName': 'John Doe',
      'type': 'Medical',
      'amount': '₦50,000',
      'date': '2024-02-10',
      'status': 'Pending',
      'description': 'General consultation and medication',
      'hospital': 'CareLink Medical Center',
      'documents': ['Medical Report', 'Receipt', 'Prescription'],
    },
    {
      'id': 'CLM002',
      'patientName': 'Jane Smith',
      'type': 'Dental',
      'amount': '₦75,000',
      'date': '2024-02-12',
      'status': 'Approved',
      'description': 'Dental surgery and follow-up',
      'hospital': 'CareLink Dental Clinic',
      'documents': ['Dental X-Ray', 'Treatment Plan', 'Receipt'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Claims',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search claims...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Pending'),
                      _buildFilterChip('Under Review'),
                      _buildFilterChip('Approved'),
                      _buildFilterChip('Rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Claims List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredClaims.length,
              itemBuilder: (context, index) {
                final claim = _filteredClaims[index];
                return _buildClaimCard(claim);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    Color statusColor;
    switch (claim['status']) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Under Review':
        statusColor = Colors.blue;
        break;
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Row(
          children: [
            Text(claim['patientName']),
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
                claim['status'],
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
            Text('${claim['type']} - ${claim['amount']}'),
            Text(
              'Submitted on ${claim['date']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              claim['hospital'],
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
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
            if (claim['status'] == 'Pending') ...[
              const PopupMenuItem(
                value: 'review',
                child: Row(
                  children: [
                    Icon(Icons.rate_review),
                    SizedBox(width: 8),
                    Text('Start Review'),
                  ],
                ),
              ),
            ],
            if (claim['status'] == 'Under Review') ...[
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Approve'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reject',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reject', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showClaimDetails(claim);
                break;
              case 'review':
                _updateClaimStatus(claim, 'Under Review');
                break;
              case 'approve':
                _showApprovalDialog(claim);
                break;
              case 'reject':
                _showRejectionDialog(claim);
                break;
            }
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredClaims {
    return _claims.where((claim) {
      final matchesFilter = _selectedFilter == 'All' ||
          claim['status'] == _selectedFilter;

      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch = searchTerm.isEmpty ||
          claim['patientName'].toLowerCase().contains(searchTerm) ||
          claim['type'].toLowerCase().contains(searchTerm) ||
          claim['hospital'].toLowerCase().contains(searchTerm);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _showClaimDetails(Map<String, dynamic> claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Claim ID', claim['id']),
              _buildDetailRow('Patient', claim['patientName']),
              _buildDetailRow('Type', claim['type']),
              _buildDetailRow('Amount', claim['amount']),
              _buildDetailRow('Date', claim['date']),
              _buildDetailRow('Status', claim['status']),
              _buildDetailRow('Hospital', claim['hospital']),
              _buildDetailRow('Description', claim['description']),
              const SizedBox(height: 16),
              const Text(
                'Documents:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                (claim['documents'] as List).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 16),
                      const SizedBox(width: 8),
                      Text(claim['documents'][index]),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Handle document download
                        },
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateClaimStatus(Map<String, dynamic> claim, String status) {
    setState(() {
      claim['status'] = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claim marked as $status'),
        backgroundColor: status == 'Approved' ? Colors.green : Colors.blue,
      ),
    );
  }

  void _showApprovalDialog(Map<String, dynamic> claim) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve claim for ${claim['patientName']}?'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Add Note (Optional)',
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
          TextButton(
            onPressed: () {
              _updateClaimStatus(claim, 'Approved');
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(Map<String, dynamic> claim) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject claim for ${claim['patientName']}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a reason for rejection';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                _updateClaimStatus(claim, 'Rejected');
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 