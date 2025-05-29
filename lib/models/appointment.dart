import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String userId;
  final String hospitalId;
  final String hospitalName;
  final DateTime date;
  final TimeOfDay time;
  final String type;
  final String reason;
  final String status;
  final String? notes;
  final String? doctorName;
  final String? doctorSpecialty;
  final int duration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.hospitalId,
    required this.hospitalName,
    required this.date,
    required this.time,
    required this.type,
    required this.reason,
    required this.status,
    this.notes,
    this.doctorName,
    this.doctorSpecialty,
    required this.duration,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['userId'],
      hospitalId: json['hospitalId'],
      hospitalName: json['hospital']['name'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(json['time'].split(':')[0]),
        minute: int.parse(json['time'].split(':')[1]),
      ),
      type: json['type'],
      reason: json['reason'],
      status: json['status'],
      notes: json['notes'],
      doctorName: json['doctorName'],
      doctorSpecialty: json['doctorSpecialty'],
      duration: json['duration'] ?? 30,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hospitalId': hospitalId,
      'date': date.toIso8601String(),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'type': type,
      'reason': reason,
      'status': status,
      'notes': notes,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'duration': duration,
    };
  }
} 