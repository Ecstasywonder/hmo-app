import 'package:flutter/material.dart';
import 'package:hmo_app/widgets/theme_builder.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme) => Scaffold(
        appBar: AppBar(
          title: Text('Terms of Service', style: theme.textTheme.titleLarge),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Acceptance of Terms', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('2. Use License', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Permission is granted to temporarily access the application for personal, non-commercial use only.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('3. Healthcare Information', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'The healthcare information provided in this application is for general informational purposes only. It is not intended as a substitute for professional medical advice.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('4. User Account', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('5. Privacy', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Your use of this application is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the application and informs users of our data collection practices.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 