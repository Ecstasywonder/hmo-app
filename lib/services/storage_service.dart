import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' if (dart.library.io) 'dart:io' show window;
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    if (!kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    if (kIsWeb) {
      window.localStorage['user_preferences'] = json.encode(preferences);
    } else {
      await _prefs.setString('user_preferences', json.encode(preferences));
    }
  }

  Future<Map<String, dynamic>> loadPreferences() async {
    if (kIsWeb) {
      final data = window.localStorage['user_preferences'];
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
    } else {
      final String? data = _prefs.getString('user_preferences');
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
    }
    return {};
  }
} 