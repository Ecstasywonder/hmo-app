import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/user_preferences_service.dart';
import 'package:hmo_app/theme/app_theme.dart';
import 'package:hmo_app/widgets/animated_theme.dart';

class ThemeBuilder extends StatelessWidget {
  final Widget Function(ThemeData theme) builder;
  final Duration animationDuration;

  const ThemeBuilder({
    super.key,
    required this.builder,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesService>(
      builder: (context, prefs, _) {
        final theme = AppTheme.getAnimatedTheme(
          prefs.isDarkMode,
          prefs.textScaleFactor,
        );
        
        return AnimatedThemeWrapper(
          theme: theme,
          duration: animationDuration,
          child: builder(theme),
        );
      },
    );
  }
} 