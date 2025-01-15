import 'package:flutter/material.dart';

class AdminNotificationService extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  
  List<Map<String, dynamic>> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n['read']).length;

  void addNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'timestamp': DateTime.now(),
      'read': false,
    });
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
} 