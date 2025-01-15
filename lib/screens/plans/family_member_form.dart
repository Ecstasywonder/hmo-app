import 'package:flutter/material.dart';

class FamilyMemberForm extends StatefulWidget {
  final int memberCount;
  
  const FamilyMemberForm({
    super.key,
    required this.memberCount,
  });

  @override
  State<FamilyMemberForm> createState() => _FamilyMemberFormState();
}

class _FamilyMemberFormState extends State<FamilyMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.memberCount; i++) {
      _members.add({
        'name': '',
        'dob': null,
        'relationship': 'Spouse',
        'gender': 'Male',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members', 
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._members.asMap().entries.map((entry) => 
              _buildMemberCard(entry.key, entry.value)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(int index, Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Member ${index + 1}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
              onSaved: (value) {
                _members[index]['name'] = value;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              value: member['relationship'],
              items: ['Spouse', 'Child', 'Parent']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _members[index]['relationship'] = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    value: member['gender'],
                    items: ['Male', 'Female']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _members[index]['gender'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _members[index]['dob'] = date;
                        });
                      }
                    },
                    readOnly: true,
                    validator: (value) {
                      if (_members[index]['dob'] == null) {
                        return 'Please select date';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                      text: _members[index]['dob'] != null
                          ? '${_members[index]['dob']?.day}/'
                              '${_members[index]['dob']?.month}/'
                              '${_members[index]['dob']?.year}'
                          : '',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, _members);
    }
  }
} 