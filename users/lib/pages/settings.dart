import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _location = true;
  bool _dataSharing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _location = prefs.getBool('location_services') ?? true;
      _dataSharing = prefs.getBool('data_sharing') ?? false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Settings'), leading: const BackButton()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(alignment: Alignment.centerLeft, child: Text('Account', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color))),
            const SizedBox(height: 8),
            _tile('Update Profile', onTap: () => Navigator.pushNamed(context, '/account_settings')),
            _tile('Change Password', onTap: () => Navigator.pushNamed(context, '/change_password')),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Privacy', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color))),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Location Services'),
              value: _location,
              onChanged: (v) => setState(() => _location = v),
              secondary: const Icon(Icons.location_on_rounded, color: AppColors.safetyBlue),
              activeColor: AppColors.safetyBlue,
              activeTrackColor: AppColors.safetyBlue.withOpacity(0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
            ),
            SwitchListTile(
              title: const Text('Data Sharing'),
              value: _dataSharing,
              onChanged: (v) => setState(() => _dataSharing = v),
              secondary: const Icon(Icons.storage_rounded, color: AppColors.safetyBlue),
              activeColor: AppColors.safetyBlue,
              activeTrackColor: AppColors.safetyBlue.withOpacity(0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('App', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color))),
            const SizedBox(height: 8),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService().themeMode,
              builder: (context, themeMode, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_rounded, color: AppColors.safetyBlue),
                      title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_getThemeText(themeMode)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _themeIcon(Icons.light_mode, ThemeMode.light, themeMode),
                          const SizedBox(width: 8),
                          _themeIcon(Icons.dark_mode, ThemeMode.dark, themeMode),
                          const SizedBox(width: 8),
                          _themeIcon(Icons.settings_system_daydream, ThemeMode.system, themeMode),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeIcon(IconData icon, ThemeMode mode, ThemeMode currentMode) {
    final isSelected = mode == currentMode;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? AppColors.safetyBlue : Colors.grey,
      onPressed: () => ThemeService().setTheme(mode),
      tooltip: _getThemeText(mode),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Widget _tile(String label, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      leading: const Icon(Icons.person, color: Colors.transparent),
      minLeadingWidth: 0,
    );
  }
}
