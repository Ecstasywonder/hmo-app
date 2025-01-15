import 'package:flutter/material.dart';
import 'package:hmo_app/services/storage_service.dart';

class UserPreferencesService extends ChangeNotifier {
  final _storage = StorageService();
  
  // Privacy Settings
  bool _showEmail = true;
  bool _showPhone = true;
  bool _showAddress = true;
  bool _shareHealthData = false;

  // Notification Settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _appointmentReminders = true;
  bool _healthTips = true;

  // Theme Settings
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;
  double _textScaleFactor = 1.0;

  // Add system theme preference
  bool _useSystemTheme = false;

  // Getters
  bool get showEmail => _showEmail;
  bool get showPhone => _showPhone;
  bool get showAddress => _showAddress;
  bool get shareHealthData => _shareHealthData;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get appointmentReminders => _appointmentReminders;
  bool get healthTips => _healthTips;
  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  double get textScaleFactor => _textScaleFactor;
  bool get useSystemTheme => _useSystemTheme;

  // Constructor
  UserPreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _storage.loadPreferences();
    
    // Load privacy settings
    _showEmail = prefs['showEmail'] ?? true;
    _showPhone = prefs['showPhone'] ?? true;
    _showAddress = prefs['showAddress'] ?? true;
    _shareHealthData = prefs['shareHealthData'] ?? false;

    // Load notification settings
    _pushNotifications = prefs['pushNotifications'] ?? true;
    _emailNotifications = prefs['emailNotifications'] ?? true;
    _appointmentReminders = prefs['appointmentReminders'] ?? true;
    _healthTips = prefs['healthTips'] ?? true;

    // Load theme settings
    _isDarkMode = prefs['isDarkMode'] ?? false;
    _primaryColor = Color(prefs['primaryColor'] ?? Colors.blue.value);
    _textScaleFactor = prefs['textScaleFactor'] ?? 1.0;

    // Load system theme preference
    _useSystemTheme = prefs['useSystemTheme'] ?? false;
    
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    await _storage.savePreferences({
      'showEmail': _showEmail,
      'showPhone': _showPhone,
      'showAddress': _showAddress,
      'shareHealthData': _shareHealthData,
      'pushNotifications': _pushNotifications,
      'emailNotifications': _emailNotifications,
      'appointmentReminders': _appointmentReminders,
      'healthTips': _healthTips,
      'isDarkMode': _isDarkMode,
      'primaryColor': _primaryColor.value,
      'textScaleFactor': _textScaleFactor,
      'useSystemTheme': _useSystemTheme,
    });
  }

  void updatePrivacySettings({
    bool? showEmail,
    bool? showPhone,
    bool? showAddress,
    bool? shareHealthData,
  }) {
    if (showEmail != null) _showEmail = showEmail;
    if (showPhone != null) _showPhone = showPhone;
    if (showAddress != null) _showAddress = showAddress;
    if (shareHealthData != null) _shareHealthData = shareHealthData;
    _savePreferences();
    notifyListeners();
  }

  void updateNotificationSettings({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? appointmentReminders,
    bool? healthTips,
  }) {
    if (pushNotifications != null) _pushNotifications = pushNotifications;
    if (emailNotifications != null) _emailNotifications = emailNotifications;
    if (appointmentReminders != null) _appointmentReminders = appointmentReminders;
    if (healthTips != null) _healthTips = healthTips;
    _savePreferences();
    notifyListeners();
  }

  void updateThemeSettings({
    bool? isDarkMode,
    Color? primaryColor,
    double? textScaleFactor,
    bool? useSystemTheme,
  }) {
    bool shouldNotify = false;

    if (useSystemTheme != null && useSystemTheme != _useSystemTheme) {
      _useSystemTheme = useSystemTheme;
      shouldNotify = true;
    }

    // Only update dark mode if not using system theme
    if (!_useSystemTheme && isDarkMode != null && isDarkMode != _isDarkMode) {
      _isDarkMode = isDarkMode;
      shouldNotify = true;
    }

    if (primaryColor != null && primaryColor != _primaryColor) {
      _primaryColor = primaryColor;
      shouldNotify = true;
    }

    if (textScaleFactor != null && textScaleFactor != _textScaleFactor) {
      _textScaleFactor = textScaleFactor;
      shouldNotify = true;
    }

    if (shouldNotify) {
      _savePreferences();
      notifyListeners();
    }
  }
} 