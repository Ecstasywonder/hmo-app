import 'package:flutter/material.dart';
import 'package:hmo_app/widgets/theme_builder.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme) => Scaffold(
        appBar: AppBar(
          title: Text('Privacy Policy', style: theme.textTheme.titleLarge),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Information Collection', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'We collect information that you provide directly to us, including personal and health information necessary for providing healthcare services.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('Use of Information', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'We use the information we collect to provide, maintain, and improve our services, communicate with you, and protect our users.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('Data Security', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'We implement appropriate security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('Information Sharing', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'We do not share your personal information with third parties except as described in this policy or with your consent.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Text('Your Rights', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'You have the right to access, update, or delete your personal information. You can also opt out of certain data collection and use.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 