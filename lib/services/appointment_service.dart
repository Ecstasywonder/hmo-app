import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hmo_app/models/appointment.dart';
import 'package:hmo_app/services/auth_service.dart';
import 'package:hmo_app/config/api_config.dart';

class AppointmentService extends ChangeNotifier {
  final String baseUrl = '${ApiConfig.baseUrl}/appointments';
  final AuthService _authService;

  AppointmentService(this._authService);

  Future<List<Appointment>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await http.get(
        Uri.parse('$baseUrl/my-appointments').replace(queryParameters: queryParams),
        headers: await _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  Future<Appointment> getAppointmentDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load appointment details');
      }
    } catch (e) {
      throw Exception('Failed to load appointment details: $e');
    }
  }

  Future<Appointment> bookAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _authService.getAuthHeaders(),
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 201) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  Future<Appointment> updateAppointment(String id, Map<String, dynamic> appointmentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _authService.getAuthHeaders(),
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update appointment');
      }
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _authService.getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  Future<Appointment> rescheduleAppointment(String id, DateTime date, TimeOfDay time) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$id/reschedule'),
        headers: await _authService.getAuthHeaders(),
        body: json.encode({
          'date': date.toIso8601String(),
          'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        }),
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to reschedule appointment');
      }
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  Future<Appointment> confirmAppointment(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$id/confirm'),
        headers: await _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to confirm appointment');
      }
    } catch (e) {
      throw Exception('Failed to confirm appointment: $e');
    }
  }
} 