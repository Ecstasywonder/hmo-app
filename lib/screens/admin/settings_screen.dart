import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hmo_app/services/user_preferences_service.dart';
import 'package:hmo_app/widgets/theme_builder.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme) => Scaffold(
        appBar: AppBar(
          title: Text('Settings', style: theme.textTheme.titleLarge),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Account'),
            _buildProfileCard(),
            const SizedBox(height: 24),
            
            _buildSectionHeader('Notifications'),
            _buildSettingsSwitchTile(
              'Email Notifications',
              'Receive email updates about claims and approvals',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildSettingsSwitchTile(
              'Push Notifications',
              'Receive push notifications on your device',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Appearance'),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme Settings'),
              subtitle: const Text('Customize app appearance'),
              onTap: _showThemeSettings,
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Security'),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              onTap: () => _showChangePasswordDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Enable extra security'),
              onTap: () {
                // Handle 2FA setup
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Legal'),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              subtitle: const Text('View terms of service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              subtitle: const Text('View privacy policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Legal Compliance'),
              subtitle: const Text('View compliance status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show compliance status dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Legal Compliance', style: theme.textTheme.titleLarge),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HIPAA Compliance', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Status: Compliant', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Text('Data Protection', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Status: Up to date', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Text('Last Audit: January 2024', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: theme.textTheme.labelLarge),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('System'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Version 1.0.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'CareLink Admin',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 CareLink. All rights reserved.',
                  children: [
                    const SizedBox(height: 16),
                    Text('Healthcare Management System', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text('Admin Portal', style: theme.textTheme.bodyMedium),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Check for Updates'),
              onTap: () {
                // Show checking for updates dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Updates', style: theme.textTheme.titleLarge),
                    content: Text(
                      'Your application is up to date.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: theme.textTheme.labelLarge),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: const Icon(
                Icons.person_outline,
                size: 32,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'admin@carelink.com',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // Handle profile edit
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings() {
    final prefs = Provider.of<UserPreferencesService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => ThemeBuilder(
        builder: (theme) => AlertDialog(
          title: Text('Theme Settings', style: theme.textTheme.titleLarge),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('Dark Mode', style: theme.textTheme.bodyLarge),
                  subtitle: Text(
                    'Enable dark theme',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: prefs.isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      prefs.updateThemeSettings(isDarkMode: value);
                    });
                  },
                ),
                ListTile(
                  title: Text('Text Size', style: theme.textTheme.bodyLarge),
                  trailing: DropdownButton<double>(
                    value: prefs.textScaleFactor,
                    items: [
                      DropdownMenuItem(
                        value: 0.8,
                        child: Text('Small', style: theme.textTheme.bodyMedium),
                      ),
                      DropdownMenuItem(
                        value: 1.0,
                        child: Text('Normal', style: theme.textTheme.bodyMedium),
                      ),
                      DropdownMenuItem(
                        value: 1.2,
                        child: Text('Large', style: theme.textTheme.bodyMedium),
                      ),
                      DropdownMenuItem(
                        value: 1.4,
                        child: Text('Extra Large', style: theme.textTheme.bodyMedium),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.updateThemeSettings(textScaleFactor: value);
                      }
                    },
                  ),
                ),
                // Additional admin-specific theme settings
                ListTile(
                  title: Text('System Theme', style: theme.textTheme.bodyLarge),
                  subtitle: Text(
                    'Follow system theme settings',
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: Switch(
                    value: prefs.useSystemTheme,
                    onChanged: (value) {
                      setState(() {
                        prefs.updateThemeSettings(useSystemTheme: value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: theme.textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
} 