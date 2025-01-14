import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedSpecialty;
  String? selectedHospital;

  final List<String> specialties = [
    'General Medicine',
    'Pediatrics',
    'Cardiology',
    'Orthopedics',
    'Dermatology',
    'Dentistry',
  ];

  final List<String> hospitals = [
    'City General Hospital',
    'St. Mary\'s Medical Center',
    'Unity Healthcare',
    'Metropolitan Hospital',
  ];

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Specialty Selection
            Text(
              'Select Specialty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSpecialty,
              decoration: const InputDecoration(
                hintText: 'Choose specialty',
              ),
              items: specialties
                  .map((specialty) => DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSpecialty = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Hospital Selection
            Text(
              'Select Hospital',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedHospital,
              decoration: const InputDecoration(
                hintText: 'Choose hospital',
              ),
              items: hospitals
                  .map((hospital) => DropdownMenuItem(
                        value: hospital,
                        child: Text(hospital),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedHospital = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Choose date',
                      style: TextStyle(
                        color: selectedDate != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(Icons.calendar_today,
                        color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Slots
            Text(
              'Select Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) {
                final isSelected = selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedSpecialty != null &&
                        selectedHospital != null &&
                        selectedDate != null &&
                        selectedTime != null
                    ? () {
                        // Handle booking logic
                      }
                    : null,
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 