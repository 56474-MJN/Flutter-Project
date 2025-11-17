import 'package:class6/screens/remainders.dart';
import 'package:class6/screens/schedule.dart';
import 'package:class6/screens/settings.dart';
import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import 'assignment.dart';
import 'gpa_calculators.dart';
class HomeDashboard extends StatefulWidget {
  final Function(bool) onThemeToggle;
  const HomeDashboard({required this.onThemeToggle, super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(onThemeToggle: widget.onThemeToggle)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: _OverviewCard(title: 'Next Class', value: DemoData.nextClassSimple())),
                const SizedBox(width: 12),
                Expanded(child: _OverviewCard(title: 'Assignments Due', value: '${DemoData.pendingAssignmentsCount()}')),
              ],
            ),
            const SizedBox(height: 16),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionTile(icon: Icons.calendar_month, label: 'Schedule', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()))),
                _ActionTile(icon: Icons.assignment, label: 'Assignments', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsScreen()))),
                _ActionTile(icon: Icons.alarm, label: 'Reminders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  RemindersScreen()))),
                _ActionTile(icon: Icons.calculate, label: 'GPA', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GpaCalculatorScreen()))),
              ],
            ),
            const SizedBox(height: 20),
            Text('Upcoming Assignments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...DemoData.assignments.take(3).map((a) {
              return Card(
                color: const Color(0xFFF4F1FF),
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.assignment,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(a['title']),
                  subtitle: Text('Due: ${a['dueLabel']}'),
                  trailing: a['completed']
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  const _OverviewCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF4F1FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ]),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 34,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label),
          ]),
        ),
      ),
    );
  }
}