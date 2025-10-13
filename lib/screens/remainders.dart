import 'package:flutter/material.dart';
import '../data/demo_data.dart';
class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _titleCtl = TextEditingController();
  final _timeCtl = TextEditingController();

  void _openAddReminder() {
    _titleCtl.clear();
    _timeCtl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Reminder', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Reminder Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeCtl,
                decoration: const InputDecoration(labelText: 'When (e.g., Tomorrow 6:00 PM)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_titleCtl.text.trim().isEmpty) return;
                        setState(() {
                          DemoData.reminders.insert(0, {
                            'title': _titleCtl.text.trim(),
                            'time': _timeCtl.text.trim(),
                          });
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = DemoData.reminders;
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, i) {
          final r = reminders[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: Text(r['title'].toString()),
              subtitle: Text(r['time'].toString()),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => DemoData.reminders.removeAt(i)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReminder,
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}

