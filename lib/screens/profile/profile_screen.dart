import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hmo_app/services/auth_service.dart';
import 'package:hmo_app/services/user_preferences_service.dart';
import 'package:hmo_app/widgets/theme_builder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  
  // Sample user data - replace with actual user data
  final Map<String, dynamic> _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 234 567 890',
    'address': '123 Street, City',
    'profileImage': 'https://via.placeholder.com/100',
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _userData['profileImage'] = image.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userData['name']);
    final phoneController = TextEditingController(text: _userData['phone']);
    final addressController = TextEditingController(text: _userData['address']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('https://via.placeholder.com/100'),
              ),
              TextButton(
                onPressed: () {
                  // Implement image picker
                },
                child: const Text('Change Photo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _userData['name'] = nameController.text;
                _userData['phone'] = phoneController.text;
                _userData['address'] = addressController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    final prefs = Provider.of<UserPreferencesService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive notifications on device'),
                value: prefs.pushNotifications,
                onChanged: (value) {
                  setState(() {
                    prefs.updateNotificationSettings(pushNotifications: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive email updates'),
                value: prefs.emailNotifications,
                onChanged: (value) {
                  setState(() {
                    prefs.updateNotificationSettings(emailNotifications: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Appointment Reminders'),
                subtitle: const Text('Get reminded of appointments'),
                value: prefs.appointmentReminders,
                onChanged: (value) {
                  setState(() {
                    prefs.updateNotificationSettings(
                      appointmentReminders: value,
                    );
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Health Tips'),
                subtitle: const Text('Receive health tips and advice'),
                value: prefs.healthTips,
                onChanged: (value) {
                  setState(() {
                    prefs.updateNotificationSettings(healthTips: value);
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('French'),
              value: 'French',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    final prefs = Provider.of<UserPreferencesService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Show Email'),
                subtitle: const Text('Make email visible to others'),
                value: prefs.showEmail,
                onChanged: (value) {
                  setState(() {
                    prefs.updatePrivacySettings(showEmail: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Show Phone'),
                subtitle: const Text('Make phone number visible'),
                value: prefs.showPhone,
                onChanged: (value) {
                  setState(() {
                    prefs.updatePrivacySettings(showPhone: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Show Address'),
                subtitle: const Text('Make address visible'),
                value: prefs.showAddress,
                onChanged: (value) {
                  setState(() {
                    prefs.updatePrivacySettings(showAddress: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Share Health Data'),
                subtitle: const Text('Share health data with providers'),
                value: prefs.shareHealthData,
                onChanged: (value) {
                  setState(() {
                    prefs.updatePrivacySettings(shareHealthData: value);
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: theme.textTheme.titleLarge,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: _showEditProfileDialog,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_userData['profileImage']),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Member since Jan 2024',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Sections
              _buildSection(
                context,
                'Personal Information',
                [
                  _buildInfoItem(Icons.email, 'Email', _userData['email']),
                  _buildInfoItem(Icons.phone, 'Phone', _userData['phone']),
                  _buildInfoItem(Icons.location_on, 'Address', _userData['address']),
                ],
              ),
              const SizedBox(height: 24),

              _buildSection(
                context,
                'Preferences',
                [
                  _buildSettingItem(
                    context,
                    Icons.notifications,
                    'Notifications',
                    _notificationsEnabled ? 'Enabled' : 'Disabled',
                    _showNotificationSettings,
                  ),
                  _buildSettingItem(
                    context,
                    Icons.language,
                    'Language',
                    _selectedLanguage,
                    _showLanguageSettings,
                  ),
                  _buildSettingItem(
                    context,
                    Icons.security,
                    'Privacy',
                    'Manage privacy settings',
                    _showPrivacySettings,
                  ),
                  _buildSettingItem(
                    context,
                    Icons.color_lens,
                    'Theme',
                    'Manage theme settings',
                    _showThemeSettings,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSection(
                context,
                'Legal',
                [
                  _buildSettingItem(
                    context,
                    Icons.description,
                    'Terms of Service',
                    'View terms of service',
                    () => Navigator.pushNamed(context, '/terms'),
                  ),
                  _buildSettingItem(
                    context,
                    Icons.privacy_tip,
                    'Privacy Policy',
                    'View privacy policy',
                    () => Navigator.pushNamed(context, '/privacy'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Provider.of<AuthService>(context, listen: false)
                                  .logout(context);
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 