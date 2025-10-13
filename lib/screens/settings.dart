import 'package:flutter/material.dart';
import '../data/demo_data.dart';
class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  const SettingsScreen({required this.onThemeToggle, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = false;
  String _name = 'Student Name';
  String _semester = 'Semester 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_name, style: Theme.of(context).textTheme.titleMedium),
                  Text(_semester),
                ])
              ]),
            ),
          ),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Display name'), onChanged: (v) => setState(() => _name = v)),
          const SizedBox(height: 8),
          TextField(decoration: const InputDecoration(labelText: 'Semester'), onChanged: (v) => setState(() => _semester = v)),
          const SizedBox(height: 12),

          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.info_outline),
            label: const Text('About'),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Student Companion',
                applicationVersion: '1.0',
                children: const [Text('A sample frontend app for your semester project (Material 3).')],
              );
            },
          ),
        ]),
      ),
    );
  }
}
