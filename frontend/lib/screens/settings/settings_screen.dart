import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/repositories/auth_repository.dart';
import 'package:taskdo/data/providers/secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Default values
  int _pomodoroDuration = 25;
  int _breakDuration = 5;
  bool _notificationsEnabled = true;
  String _theme = 'Light';
  
  // User data
  String _userName = 'User';
  String _userEmail = '';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserProfile();
  }
  
  Future<void> _loadSettings() async {
    // Load settings from secure storage
    final storage = context.read<SecureStorageProvider>();
    
    try {
      final pomodoroDuration = await storage.read(key: 'pomodoroDuration');
      final breakDuration = await storage.read(key: 'breakDuration');
      final notificationsEnabled = await storage.read(key: 'notificationsEnabled');
      final theme = await storage.read(key: 'theme');
      
      setState(() {
        _pomodoroDuration = pomodoroDuration != null ? int.parse(pomodoroDuration) : 25;
        _breakDuration = breakDuration != null ? int.parse(breakDuration) : 5;
        _notificationsEnabled = notificationsEnabled == 'true';
        _theme = theme ?? 'Light';
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }
  
  Future<void> _loadUserProfile() async {
    try {
      // Get user profile from API
      final authRepository = context.read<AuthRepository>();
      final user = await authRepository.getCurrentUser();
      
      if (user != null) {
        setState(() {
          _userName = user.email.split('@')[0]; // Use the part before @ as name
          _userEmail = user.email;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      
      // If we can't get the user profile from the API, try to get email from storage
      try {
        final storage = context.read<SecureStorageProvider>();
        final email = await storage.getUserEmail();
        
        if (email != null && email.isNotEmpty) {
          setState(() {
            _userName = email.split('@')[0]; // Use the part before @ as name
            _userEmail = email;
          });
        }
      } catch (storageError) {
        print('Error loading user email from storage: $storageError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: AppTheme.heading3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail.isEmpty ? 'Email not available' : _userEmail,
                        style: AppTheme.bodyText,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'TaskDo User',
                        style: AppTheme.smallText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Edit profile functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile editing coming soon')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Settings',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              'Pomodoro Duration',
              '$_pomodoroDuration minutes',
              Icons.timer,
              () {
                _showDurationPicker(
                  title: 'Pomodoro Duration',
                  initialValue: _pomodoroDuration,
                  onChanged: (value) async {
                    setState(() {
                      _pomodoroDuration = value;
                    });
                    
                    // Save to secure storage
                    final storage = context.read<SecureStorageProvider>();
                    await storage.write(key: 'pomodoroDuration', value: value.toString());
                  },
                );
              },
            ),
            _buildSettingTile(
              'Break Duration',
              '$_breakDuration minutes',
              Icons.free_breakfast,
              () {
                _showDurationPicker(
                  title: 'Break Duration',
                  initialValue: _breakDuration,
                  onChanged: (value) async {
                    setState(() {
                      _breakDuration = value;
                    });
                    
                    // Save to secure storage
                    final storage = context.read<SecureStorageProvider>();
                    await storage.write(key: 'breakDuration', value: value.toString());
                  },
                );
              },
            ),
            _buildSettingTile(
              'Notifications',
              _notificationsEnabled ? 'Enabled' : 'Disabled',
              Icons.notifications,
              () {
                // Do nothing on tap, switch handles state changes
              },
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  
                  // Save to secure storage
                  final storage = context.read<SecureStorageProvider>();
                  storage.write(key: 'notificationsEnabled', value: value.toString());
                },
              ),
            ),
            _buildSettingTile(
              'Theme',
              _theme,
              Icons.color_lens,
              () {
                _showThemePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              'Change Password',
              '',
              Icons.lock,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset coming soon')),
                );
              },
            ),
            _buildSettingTile(
              'Privacy Settings',
              '',
              Icons.security,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings coming soon')),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: AppTheme.bodyText),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: AppTheme.smallText) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showDurationPicker({
    required String title,
    required int initialValue,
    required Function(int) onChanged,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedValue = initialValue;
        
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: selectedValue.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '$selectedValue minutes',
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedValue = value.round();
                      });
                    },
                  ),
                  Text('$selectedValue minutes', style: AppTheme.bodyText),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onChanged(selectedValue);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption('Light'),
              _buildThemeOption('Dark'),
              _buildThemeOption('System'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(String themeName) {
    return ListTile(
      title: Text(themeName),
      leading: Radio<String>(
        value: themeName,
        groupValue: _theme,
        onChanged: (value) async {
          setState(() {
            _theme = value!;
          });
          
          // Save to secure storage
          final storage = context.read<SecureStorageProvider>();
          await storage.write(key: 'theme', value: value!);
          
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 