import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/models/appointment.dart';
import 'package:hmo_app/services/appointment_service.dart';
import 'package:hmo_app/widgets/loading_widget.dart';
import 'package:hmo_app/widgets/error_widget.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  Appointment? _appointment;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final appointment = await appointmentService.getAppointmentDetails(widget.appointmentId);

      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointment details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final appointmentService = Provider.of<AppointmentService>(context, listen: false);
        await appointmentService.cancelAppointment(widget.appointmentId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment cancelled successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate changes
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel appointment')),
          );
        }
      }
    }
  }

  Future<void> _rescheduleAppointment() async {
    final result = await Navigator.pushNamed(
      context,
      '/appointments/reschedule',
      arguments: _appointment,
    );

    if (result == true) {
      _loadAppointment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading appointment details...');
    }

    if (_error != null) {
      return CustomErrorWidget(
        error: _error!,
        onRetry: _loadAppointment,
      );
    }

    if (_appointment == null) {
      return const Center(child: Text('Appointment not found'));
    }

    final theme = Theme.of(context);
    final appointment = _appointment!;
    final isPending = appointment.status.toLowerCase() == 'pending';
    final isUpcoming = appointment.date.isAfter(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Hospital Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.hospitalName,
                  style: theme.textTheme.titleLarge,
                ),
                if (appointment.doctorName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Dr. ${appointment.doctorName}',
                    style: theme.textTheme.titleMedium,
                  ),
                  if (appointment.doctorSpecialty != null)
                    Text(
                      appointment.doctorSpecialty!,
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Appointment Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '${appointment.time.hour.toString().padLeft(2, '0')}:${appointment.time.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.medical_services,
                  label: 'Type',
                  value: appointment.type,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: '${appointment.duration} minutes',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.info_outline,
                  label: 'Status',
                  value: appointment.status,
                  valueColor: _getStatusColor(appointment.status),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Reason for Visit',
            child: Text(
              appointment.reason,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          if (appointment.notes != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Additional Notes',
              child: Text(
                appointment.notes!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
          if (isPending && isUpcoming) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelAppointment,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Cancel Appointment'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _rescheduleAppointment,
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
} 