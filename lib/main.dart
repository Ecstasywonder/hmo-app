import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/auth_service.dart';
import 'package:hmo_app/services/user_preferences_service.dart';
import 'package:hmo_app/screens/auth/login_screen.dart';
import 'package:hmo_app/theme/app_theme.dart';
import 'package:hmo_app/services/storage_service.dart';
import 'package:hmo_app/widgets/animated_theme.dart';
import 'package:hmo_app/screens/legal/terms_of_service_screen.dart';
import 'package:hmo_app/screens/legal/privacy_policy_screen.dart';
import 'package:hmo_app/screens/medical/user_medical_records_screen.dart';
import 'package:hmo_app/services/admin_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserPreferencesService()),
        ChangeNotifierProvider(create: (_) => AdminNotificationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesService>(
      builder: (context, prefs, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = prefs.useSystemTheme 
            ? platformBrightness == Brightness.dark
            : prefs.isDarkMode;
            
        final themeData = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        final theme = themeData.copyWith(
          textTheme: AppTheme.getTextTheme(prefs.textScaleFactor),
        );
        
        return AnimatedThemeWrapper(
          theme: theme,
          child: MaterialApp(
            title: 'CareLink',
            theme: theme,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/terms': (context) => const TermsOfServiceScreen(),
              '/privacy': (context) => const PrivacyPolicyScreen(),
              '/medical-records': (context) => const UserMedicalRecordsScreen(),
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
