import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const _lightTextColor = Colors.black87;
  static const _lightBackgroundColor = Colors.white;
  static const _lightCardColor = Colors.white;
  static const _lightIconColor = Colors.black87;

  // Dark Theme Colors
  static const _darkTextColor = Colors.white;
  static final _darkBackgroundColor = Colors.grey[900]!;
  static final _darkCardColor = Colors.grey[800]!;
  static const _darkIconColor = Colors.white;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: _lightIconColor),
      titleTextStyle: TextStyle(
        color: _lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardTheme(
      color: _lightCardColor,
      elevation: 2,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _lightIconColor,
      textColor: _lightTextColor,
    ),
    iconTheme: const IconThemeData(
      color: _lightIconColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _lightTextColor),
      displayMedium: TextStyle(color: _lightTextColor),
      displaySmall: TextStyle(color: _lightTextColor),
      headlineMedium: TextStyle(color: _lightTextColor),
      headlineSmall: TextStyle(color: _lightTextColor),
      titleLarge: TextStyle(color: _lightTextColor),
      titleMedium: TextStyle(color: _lightTextColor),
      titleSmall: TextStyle(color: _lightTextColor),
      bodyLarge: TextStyle(color: _lightTextColor),
      bodyMedium: TextStyle(color: _lightTextColor),
      bodySmall: TextStyle(color: Colors.grey),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: _darkIconColor),
      titleTextStyle: const TextStyle(
        color: _darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: _darkCardColor,
      elevation: 2,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _darkIconColor,
      textColor: _darkTextColor,
    ),
    iconTheme: const IconThemeData(
      color: _darkIconColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _darkTextColor),
      displayMedium: TextStyle(color: _darkTextColor),
      displaySmall: TextStyle(color: _darkTextColor),
      headlineMedium: TextStyle(color: _darkTextColor),
      headlineSmall: TextStyle(color: _darkTextColor),
      titleLarge: TextStyle(color: _darkTextColor),
      titleMedium: TextStyle(color: _darkTextColor),
      titleSmall: TextStyle(color: _darkTextColor),
      bodyLarge: TextStyle(color: _darkTextColor),
      bodyMedium: TextStyle(color: _darkTextColor),
      bodySmall: TextStyle(color: Colors.grey),
    ),
    dividerColor: Colors.white24,
    dialogTheme: DialogTheme(
      backgroundColor: _darkCardColor,
      titleTextStyle: const TextStyle(
        color: _darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: _darkTextColor,
        fontSize: 16,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkCardColor,
      contentTextStyle: const TextStyle(color: _darkTextColor),
    ),
  );

  static TextTheme getTextTheme(double scaleFactor) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 96 * scaleFactor),
      displayMedium: TextStyle(fontSize: 60 * scaleFactor),
      displaySmall: TextStyle(fontSize: 48 * scaleFactor),
      headlineMedium: TextStyle(fontSize: 34 * scaleFactor),
      headlineSmall: TextStyle(fontSize: 24 * scaleFactor),
      titleLarge: TextStyle(fontSize: 20 * scaleFactor),
      bodyLarge: TextStyle(fontSize: 16 * scaleFactor),
      bodyMedium: TextStyle(fontSize: 14 * scaleFactor),
      bodySmall: TextStyle(fontSize: 12 * scaleFactor),
    );
  }

  static Color getBackgroundColor(bool isDark) {
    return isDark ? _darkBackgroundColor : _lightBackgroundColor;
  }

  static Color getCardColor(bool isDark) {
    return isDark ? _darkCardColor : _lightCardColor;
  }

  static ThemeData getAnimatedTheme(bool isDark, double textScale) {
    final baseTheme = isDark ? darkTheme : lightTheme;
    final textTheme = getTextTheme(textScale).apply(
      bodyColor: isDark ? _darkTextColor : _lightTextColor,
      displayColor: isDark ? _darkTextColor : _lightTextColor,
    );
    
    return baseTheme.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: getBackgroundColor(isDark),
      cardTheme: CardTheme(
        color: getCardColor(isDark),
      ),
    );
  }
}