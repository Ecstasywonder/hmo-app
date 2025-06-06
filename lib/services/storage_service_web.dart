import 'dart:html' as html;
import 'storage_service.dart';

class StorageServiceImpl implements StorageService {
  @override
  Future<void> save(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }

  @override
  Future<void> init() async {
    // No initialization needed for localStorage on web.
  }

  @override
  Future<Map<String, dynamic>> loadPreferences() async {
    final Map<String, dynamic> allPrefs = {};
    for (final key in html.window.localStorage.keys) {
      allPrefs[key] = html.window.localStorage[key];
    }
    return allPrefs;
  }

  @override
  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    preferences.forEach((key, value) {
      html.window.localStorage[key] = value.toString();
    });
  }
}