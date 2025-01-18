import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/models/appointment.dart';
import 'package:hmo_app/services/appointment_service.dart';
import 'package:hmo_app/widgets/loading_widget.dart';
import 'package:hmo_app/widgets/error_widget.dart';
import 'package:hmo_app/widgets/empty_state_widget.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment>? _upcomingAppointments;
  List<Appointment>? _pastAppointments;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final now = DateTime.now();

      // Load upcoming appointments
      final upcoming = await appointmentService.getAppointments(
        startDate: now,
        status: 'pending,confirmed',
      );

      // Load past appointments
      final past = await appointmentService.getAppointments(
        endDate: now,
        status: 'completed,cancelled',
      );

      setState(() {
        _upcomingAppointments = upcoming;
        _pastAppointments = past;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointments: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to book appointment screen
          Navigator.pushNamed(context, '/appointments/book');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading appointments...');
    }

    if (_error != null) {
      return CustomErrorWidget(
              error: _error!,
              onRetry: _loadAppointments,
      );
    }

    return TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(_upcomingAppointments, isUpcoming: true),
                _buildAppointmentList(_pastAppointments, isUpcoming: false),
              ],
    );
  }

  Widget _buildAppointmentList(List<Appointment>? appointments, {required bool isUpcoming}) {
    if (appointments == null || appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_busy,
        title: isUpcoming ? 'No Upcoming Appointments' : 'No Past Appointments',
        message: isUpcoming
            ? 'You don\'t have any upcoming appointments. Book one now!'
            : 'You haven\'t had any appointments yet.',
        buttonText: isUpcoming ? 'Book Appointment' : null,
        onButtonPressed: isUpcoming
            ? () => Navigator.pushNamed(context, '/appointments/book')
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to appointment details screen
          Navigator.pushNamed(
          context,
            '/appointments/details',
          arguments: appointment.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      appointment.hospitalName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.time.hour.toString().padLeft(2, '0')}:${appointment.time.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (appointment.doctorName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dr. ${appointment.doctorName}',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.reason,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 