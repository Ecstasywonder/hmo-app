import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/appointment_service.dart';
import 'package:hmo_app/widgets/error_widget.dart';
import 'package:hmo_app/widgets/loading_widget.dart';
import 'package:hmo_app/models/appointment.dart';
import 'package:hmo_app/theme/app_colors.dart';
import 'package:hmo_app/widgets/empty_state_widget.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  int _currentPage = 1;
  bool _hasMoreData = true;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMoreData && !_isLoading) {
          _loadMoreAppointments();
        }
      }
    });
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final appointments = await appointmentService.getAppointments(
        page: _currentPage,
        limit: _pageSize,
      );

      setState(() {
        _upcomingAppointments = appointments.where((apt) => 
          apt.date.isAfter(DateTime.now()) &&
          apt.status != 'cancelled'
        ).toList();
        _pastAppointments = appointments.where((apt) => 
          apt.date.isBefore(DateTime.now()) ||
          apt.status == 'cancelled'
        ).toList();
        _hasMoreData = appointments.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointments';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAppointments() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final appointments = await appointmentService.getAppointments(
        page: _currentPage + 1,
        limit: _pageSize,
      );

      if (appointments.isNotEmpty) {
        setState(() {
          final newUpcoming = appointments.where((apt) => 
            apt.date.isAfter(DateTime.now()) &&
            apt.status != 'cancelled'
          ).toList();
          final newPast = appointments.where((apt) => 
            apt.date.isBefore(DateTime.now()) ||
            apt.status == 'cancelled'
          ).toList();

          _upcomingAppointments.addAll(newUpcoming);
          _pastAppointments.addAll(newPast);
          _currentPage++;
          _hasMoreData = appointments.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load more appointments')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() {
    _currentPage = 1;
    _hasMoreData = true;
    return _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      body: _error != null
          ? CustomErrorWidget(
              error: _error!,
              onRetry: _loadAppointments,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(_upcomingAppointments, isUpcoming: true),
                _buildAppointmentList(_pastAppointments, isUpcoming: false),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/book-appointment'),
        label: const Text('Book Appointment'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, {required bool isUpcoming}) {
    if (_isLoading && appointments.isEmpty) {
      return const LoadingWidget();
    }

    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.calendar_today,
        title: isUpcoming ? 'No Upcoming Appointments' : 'No Past Appointments',
        message: isUpcoming
            ? 'You have no upcoming appointments scheduled'
            : 'You have no past appointments',
        buttonText: isUpcoming ? 'Book Appointment' : null,
        onButtonPressed: isUpcoming
            ? () => Navigator.pushNamed(context, '/book-appointment')
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == appointments.length) {
            return _buildLoadingIndicator();
          }

          final appointment = appointments[index];
          return _buildAppointmentCard(appointment, isUpcoming);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isUpcoming) {
    final statusColor = _getStatusColor(appointment.status);
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointment.date);
    final formattedTime = DateFormat('hh:mm a').format(
      DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
        appointment.time.hour,
        appointment.time.minute,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/appointment-details',
          arguments: appointment.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.type,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                      appointment.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_hospital_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.hospitalName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(formattedDate),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(formattedTime),
                ],
              ),
              if (isUpcoming && appointment.status == 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _showCancelDialog(appointment),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showRescheduleDialog(appointment),
                      child: const Text('Reschedule'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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

  Future<void> _showCancelDialog(Appointment appointment) async {
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
      _cancelAppointment(appointment);
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      await appointmentService.cancelAppointment(appointment.id);
      _onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel appointment')),
      );
    }
  }

  void _showRescheduleDialog(Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/reschedule-appointment',
      arguments: appointment.id,
    );
  }
} 