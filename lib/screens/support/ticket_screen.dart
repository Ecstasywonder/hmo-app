import 'package:flutter/material.dart';
import '../../widgets/loading_widget.dart';

class TicketScreen extends StatefulWidget {
  final Map<String, String>? initialData;

  const TicketScreen({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'General';
  String _selectedPriority = 'Normal';
  bool _isSubmitting = false;
  List<String> _attachments = [];

  final List<String> _ticketTypes = [
    'General',
    'Technical Issue',
    'Billing',
    'Claims',
    'Coverage',
    'Provider',
    'Feedback',
  ];

  final List<String> _priorities = [
    'Low',
    'Normal',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedType = widget.initialData!['type'] ?? _selectedType;
      _subjectController.text = widget.initialData!['subject'] ?? '';
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement ticket submission
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support ticket submitted successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit ticket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _addAttachment() async {
    // TODO: Implement file picking and upload
    setState(() {
      _attachments.add('attachment_${_attachments.length + 1}.pdf');
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Support Ticket'),
      ),
      body: _isSubmitting
          ? const LoadingWidget(message: 'Submitting ticket...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Ticket Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _ticketTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 20) {
                          return 'Description must be at least 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: _priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPriority = value!);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add File'),
                          onPressed: _addAttachment,
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: _attachments.asMap().entries.map((entry) {
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(entry.value),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _removeAttachment(entry.key),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitTicket,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit Ticket',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Our support team typically responds within 24 hours.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 