
import 'package:class6/screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const StudentCompanionApp());
}

class StudentCompanionApp extends StatefulWidget {
  const StudentCompanionApp({super.key});

  @override
  State<StudentCompanionApp> createState() => _StudentCompanionAppState();
}

class _StudentCompanionAppState extends State<StudentCompanionApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Companion',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(onThemeChange: _toggleTheme),
    );
  }
}

class DemoData {
  static List<Map<String, dynamic>> classes = [
    {'title': 'Data Structures', 'time': '09:00 - 10:00', 'room': 'Room 201'},
    {'title': 'Web Development', 'time': '10:30 - 11:30', 'room': 'Room 103'},
    {'title': 'Mobile App Dev', 'time': '13:00 - 14:00', 'room': 'Room 305'},
  ];

  static List<Map<String, dynamic>> assignments = [
    {
      'title': 'DS Assignment 1',
      'due': DateTime.now().add(const Duration(days: 3)),
      'dueLabel': DateTime.now().add(const Duration(days: 3)).toLocal().toString().split(' ')[0],
      'completed': false
    },
    {
      'title': 'Web Project',
      'due': DateTime.now().add(const Duration(days: 7)),
      'dueLabel': DateTime.now().add(const Duration(days: 7)).toLocal().toString().split(' ')[0],
      'completed': false
    },
  ];

  static List<Map<String, String>> reminders = [
    {'title': 'Study for DS', 'time': 'Tomorrow 18:00'},
    {'title': 'Submit Web Project', 'time': 'In 3 days'},
  ];

  static List<Map<String, dynamic>> courses = [
    {'name': 'Data Structures', 'credits': 3.0, 'grade': 'A'},
    {'name': 'Web Dev', 'credits': 3.0, 'grade': 'B+'},
  ];

  static String nextClassSimple() {
    if (classes.isEmpty) return 'No classes';
    final c = classes.first;
    return '${c['title']} at ${c['time']}';
  }

  static int pendingAssignmentsCount() {
    return assignments.where((a) => a['completed'] == false).length;
  }
}
