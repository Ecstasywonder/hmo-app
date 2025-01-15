import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmo_app/services/email_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'enrolleeNumber': 'HMO-2024-001',
      'status': 'Active',
      'plan': 'Premium',
      'dateAdded': '2024-01-15',
    },
    {
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'enrolleeNumber': 'HMO-2024-002',
      'status': 'Active',
      'plan': 'Standard',
      'dateAdded': '2024-01-20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users',
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
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
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredUsers {
    final searchTerm = _searchController.text.toLowerCase();
    return _users.where((user) {
      return user['name'].toLowerCase().contains(searchTerm) ||
          user['email'].toLowerCase().contains(searchTerm) ||
          user['enrolleeNumber'].toLowerCase().contains(searchTerm);
    }).toList();
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
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
                        user['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
          itemBuilder: (context) => [
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
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                          Icon(Icons.power_settings_new),
                          SizedBox(width: 8),
                          Text('Toggle Status'),
                ],
              ),
            ),
            const PopupMenuItem(
                      value: 'reset',
              child: Row(
                children: [
                          Icon(Icons.lock_reset),
                  SizedBox(width: 8),
                          Text('Reset Password'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditUserDialog(user);
                break;
              case 'status':
                _toggleUserStatus(user);
                break;
                      case 'reset':
                        _resetUserPassword(user);
                break;
            }
          },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('Enrollee: ${user['enrolleeNumber']}'),
                const SizedBox(width: 8),
                _buildInfoChip('Plan: ${user['plan']}'),
                const SizedBox(width: 8),
                _buildStatusChip(user['status']),
              ],
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
    final isActive = status == 'Active';
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
      backgroundColor: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
    );
  }

  String _generateEnrolleeNumber() {
    final year = DateTime.now().year;
    final number = (_users.length + 1).toString().padLeft(3, '0');
    return 'HMO-$year-$number';
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final planController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter user name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: planController,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter plan';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final enrolleeNumber = _generateEnrolleeNumber();
                final password = 'Pass${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
                
                try {
                  await EmailService.sendCredentials(
                    recipientEmail: emailController.text,
                    recipientName: nameController.text,
                    enrolleeNumber: enrolleeNumber,
                    password: password,
                  );

                  setState(() {
                    _users.add({
                      'name': nameController.text,
                      'email': emailController.text,
                      'enrolleeNumber': enrolleeNumber,
                      'status': 'Active',
                      'plan': planController.text,
                      'dateAdded': DateTime.now().toString().split(' ')[0],
                    });
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User added and credentials sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending credentials: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _showCredentialsDialog(String enrolleeNumber) {
    // Generate a random password
    final password = 'Pass${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please share these credentials with the user:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCredentialRow('Enrollee Number:', enrolleeNumber),
            _buildCredentialRow('Password:', password),
            const SizedBox(height: 16),
            const Text(
              'Note: User should change password upon first login.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'Enrollee Number: $enrolleeNumber\nPassword: $password',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credentials copied to clipboard')),
              );
            },
            child: const Text('Copy to Clipboard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final planController = TextEditingController(text: user['plan']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: planController,
                decoration: const InputDecoration(
                  labelText: 'Plan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plan';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  user['name'] = nameController.text;
                  user['email'] = emailController.text;
                  user['plan'] = planController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    setState(() {
      user['status'] = user['status'] == 'Active' ? 'Inactive' : 'Active';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'User ${user['status'] == 'Active' ? 'activated' : 'deactivated'}',
        ),
        backgroundColor: user['status'] == 'Active' ? Colors.green : Colors.red,
      ),
    );
  }

  void _resetUserPassword(Map<String, dynamic> user) {
    final newPassword = 'Reset${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New password for ${user['name']}:'),
            const SizedBox(height: 16),
            Text(
              newPassword,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: newPassword));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password copied to clipboard')),
              );
            },
            child: const Text('Copy Password'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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