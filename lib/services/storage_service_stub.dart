// Conditional imports for platform-specific storage implementations
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';


// Define the StorageService interface
abstract class StorageService {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

// storage_service_stub.dart (for unsupported platforms)
class StorageServiceImpl implements StorageService {
  @override
  Future<void> save(String key, String value) async {
    throw UnimplementedError('Storage not supported on this platform.');
  }

  @override
  Future<String?> read(String key) async {
    throw UnimplementedError('Storage not supported on this platform.');
  }

  @override
  Future<void> delete(String key) async {
    throw UnimplementedError('Storage not supported on this platform.');
  }
}

// storage_service_web.dart (for web)
class StorageServiceImplWeb implements StorageService {
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
}

// storage_service_io.dart (for mobile/desktop)
class StorageServiceImplIO implements StorageService {
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
}
