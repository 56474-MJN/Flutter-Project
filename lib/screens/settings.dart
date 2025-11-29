import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  const SettingsScreen({required this.onThemeToggle, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = false;
  String _name = '';
  String _semester = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('profiles').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _name = data['name'] ?? 'Student Name';
            _semester = data['semester'] ?? 'Semester 1';
            _nameController.text = _name;
            _semesterController.text = _semester;
          });
        } else {
          // Initialize with default values
          _nameController.text = _name;
          _semesterController.text = _semester;
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Initialize with default values even if error occurs
      _nameController.text = _name;
      _semesterController.text = _semester;
    }
  }

  void _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to save profile'))
        );
        return;
      }

      final newName = _nameController.text.trim().isEmpty ? 'Student Name' : _nameController.text.trim();
      final newSemester = _semesterController.text.trim().isEmpty ? 'Semester 1' : _semesterController.text.trim();

      await _firestore.collection('profiles').doc(user.uid).set({
        'name': newName,
        'semester': newSemester,
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));

      setState(() {
        _name = newName;
        _semester = newSemester;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!'))
      );
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving profile. Please try again.'))
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
        actions: [

        ],
      ),
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
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
              hintText: 'Enter your name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _semesterController,
            decoration: const InputDecoration(
              labelText: 'Semester',
              border: OutlineInputBorder(),
              hintText: 'Enter your semester',
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          FilledButton(
            onPressed: _saveProfile,
            child: const Text('Save Profile'),
          ),
        ]),
      ),
    );
  }
}