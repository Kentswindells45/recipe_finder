// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadHaptic();
  }

  Future<void> _loadHaptic() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticFeedback = prefs.getBool('hapticFeedback') ?? false;
    });
  }

  Future<void> _updateHaptic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticFeedback', value);
    setState(() {
      _hapticFeedback = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'General Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback on Add'),
            value: _hapticFeedback,
            onChanged: _updateHaptic,
            secondary: Icon(Icons.vibration, color: colorScheme.primary),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (val) {
              themeProvider.toggleTheme(val);
            },
            secondary: Icon(Icons.dark_mode, color: colorScheme.primary),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.primary),
            title: const Text('Recipe Finder'),
            subtitle: const Text(
              'Version 1.0.0\nA modern app to manage and sync your favorite recipes.',
            ),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined, color: colorScheme.primary),
            title: const Text('Contact Support'),
            subtitle: const Text('opppongkevin1@gmail.com'),
            onTap: () {
              // Optionally launch email intent
            },
          ),
        ],
      ),
    );
  }
}
