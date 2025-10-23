
import 'package:flutter/material.dart';

import 'login.dart';
class SplashScreen extends StatefulWidget {
  final Function(bool) onThemeChange;
  const SplashScreen({required this.onThemeChange, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginScreen(onThemeChange: widget.onThemeChange),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.school,
              size: 60,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text('Student Companion',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Plan. Track. Succeed.',
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ),
    );
  }
}