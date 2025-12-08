import 'package:class6/screens/remainders.dart';
import 'package:class6/screens/schedule.dart';
import 'package:class6/screens/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsScreen(onThemeToggle: widget.onThemeToggle),
              ),
            ),
          ),
        ],
      ),

      // ---------------------------------------------
      //    MAIN BODY
      // ---------------------------------------------
      body: RefreshIndicator(
        onRefresh: () async =>
        await Future.delayed(const Duration(milliseconds: 400)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                // --------------------------------------------
                // NEXT CLASS (FIXED LOGIC)
                // --------------------------------------------
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .orderBy('startSort') // Order by the time integer
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _OverviewCard(
                            title: 'Next Class', value: 'Loading...');
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const _OverviewCard(
                            title: 'Next Class', value: 'No upcoming class');
                      }

                      final docs = snapshot.data!.docs;
                      final now = DateTime.now();
                      // Calculate current time in sortable integer format (e.g., 1:19 AM -> 119)
                      final nowSort = now.hour * 100 + now.minute;

                      /// Get only upcoming classes today
                      final upcoming = docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        // Ensure startSort exists and is an integer, otherwise treat as 0
                        final sort = data['startSort'] is int ? data['startSort'] : 0;

                        // Filter: keep only classes whose time is AFTER the current time
                        return sort > nowSort;
                      }).toList();

                      Map<String, dynamic>? next;

                      if (upcoming.isEmpty) {
                        // If all classes for today have passed, the next class is the first one tomorrow
                        // Since the list is ordered by startSort, the first doc is the earliest class.
                        next = docs.first.data() as Map<String, dynamic>;
                      } else {
                        // Otherwise, the next class is the first one in the filtered list
                        next = upcoming.first.data() as Map<String, dynamic>;
                      }

                      return _OverviewCard(
                        title: "Next Class",
                        value:
                        "${next['subject'] ?? 'N/A'}\nRoom: ${next['room'] ?? '-'}\n${next['startTime'] ?? 'N/A'}",
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // --------------------------------------------
                // ASSIGNMENTS COUNT
                // --------------------------------------------
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('assignments')
                        .where('completed', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const _OverviewCard(
                            title: 'Assignments Due', value: '...');
                      }
                      return _OverviewCard(
                        title: 'Assignments Due',
                        value: '${snapshot.data!.docs.length}',
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --------------------------------------------
            // QUICK ACTIONS
            // --------------------------------------------
            Text('Quick Actions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionTile(
                  icon: Icons.calendar_month,
                  label: 'Schedule',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                  ),
                ),
                _ActionTile(
                  icon: Icons.assignment,
                  label: 'Assignments',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
                  ),
                ),
                _ActionTile(
                  icon: Icons.alarm,
                  label: 'Reminders',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RemindersScreen()),
                  ),
                ),
                _ActionTile(
                  icon: Icons.calculate,
                  label: 'GPA',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const gpa_calculators()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =================================================
            //   UPCOMING ASSIGNMENTS
            // =================================================
            Text('Upcoming Assignments',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('assignments')
                  .where('completed', isEqualTo: false)
                  .orderBy('due')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text("Loading..."));
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const _EmptyCard(msg: "No upcoming assignments");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final dt = (data['due'] is Timestamp)
                        ? (data['due'] as Timestamp).toDate()
                        : DateTime.now();
                    final date = DateFormat('yyyy-MM-dd').format(dt);

                    return Card(
                      color: const Color(0xFFF4F1FF),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.assignment,
                            color: Theme.of(context).colorScheme.primary),
                        title: Text(data['title'] ?? 'N/A'),
                        subtitle: Text("Due: $date"),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String msg;
  const _EmptyCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF4F1FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(msg),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 34, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}