import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class StorageServiceImpl implements StorageService {
  @override
  Future<void> save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  
  @override
  Future<void> init() async {
    // No initialization needed for SharedPreferences, but method provided for interface compatibility.
    await SharedPreferences.getInstance();
  }
  
  @override
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> allPrefs = {};
    for (var key in keys) {
      allPrefs[key] = prefs.get(key);
    }
    return allPrefs;
  }
  
  @override
  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in preferences.entries) {
      final value = entry.value;
      if (value is String) {
        await prefs.setString(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(entry.key, value);
      }
      // Other types are not supported by SharedPreferences
    }
  }
}