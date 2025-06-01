import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' if (dart.library.io) 'dart:io' show window;
import 'dart:convert';

abstract class StorageServiceBase {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class StorageService implements StorageServiceBase {
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

  @override
  Future<void> save(String key, String value) async {
    if (kIsWeb) {
      window.localStorage[key] = value;
    } else {
      await _prefs.setString(key, value);
    }
  }

  @override
  Future<String?> read(String key) async {
    if (kIsWeb) {
      return window.localStorage[key];
    } else {
      return _prefs.getString(key);
    }
  }

  @override
  Future<void> delete(String key) async {
    if (kIsWeb) {
      window.localStorage.remove(key);
    } else {
      await _prefs.remove(key);
    }
  }
}