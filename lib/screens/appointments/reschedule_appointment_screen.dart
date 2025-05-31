import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/models/appointment.dart';
import 'package:hmo_app/widgets/loading_widget.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const RescheduleAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleAppointmentScreen> createState() => _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState extends State<RescheduleAppointmentScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  List<TimeOfDay> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.date;
    _selectedTime = widget.appointment.time;
    _loadAvailableTimeSlots();
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final slots = await appointmentService.getAvailableSlots(
        widget.appointment.hospitalId,
        _selectedDate!,
      );

      setState(() {
        _availableTimeSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load available time slots')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 1));
    final lastDate = now.add(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (day) {
        // Disable weekends if the hospital doesn't operate on weekends
        return day.weekday < 6;
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _rescheduleAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      await appointmentService.rescheduleAppointment(
        widget.appointment.id,
        _selectedDate!,
        _selectedTime!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment rescheduled successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reschedule appointment')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Appointment'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading available time slots...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Appointment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(
                        '${widget.appointment.date.day}/${widget.appointment.date.month}/${widget.appointment.date.year}',
                      ),
                      subtitle: Text(
                        '${widget.appointment.time.hour.toString().padLeft(2, '0')}:${widget.appointment.time.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select New Date & Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _selectDate,
                        ),
                        const Divider(),
                        if (_selectedDate != null) ...[
                          if (_availableTimeSlots.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No available time slots for this date',
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableTimeSlots.map((time) {
                                  final isSelected = _selectedTime == time;
                                  return ChoiceChip(
                                    label: Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() => _selectedTime = selected ? time : null);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading || _selectedDate == null || _selectedTime == null
            ? null
            : _rescheduleAppointment,
        child: const Text('Confirm Reschedule'),
      ),
    );
  }
}

class AppointmentService {
  Future<List<TimeOfDay>> getAvailableSlots(String hospitalId, DateTime date) async {
    // Dummy implementation: replace with actual logic to fetch available time slots.
    await Future.delayed(const Duration(seconds: 1));
    return [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
    ];
  }
  
  Future<void> rescheduleAppointment(String appointmentId, DateTime newDate, TimeOfDay newTime) async {
    // Dummy implementation: replace with actual logic to reschedule the appointment.
    await Future.delayed(const Duration(seconds: 1));
  }
}