import 'package:flutter/material.dart';
import '../data/demo_data.dart';
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _timeCtl = TextEditingController();
  final TextEditingController _roomCtl = TextEditingController();

  void _openAddDialog() {
    _titleCtl.clear();
    _timeCtl.clear();
    _roomCtl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Add Class', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 8),
              TextField(controller: _timeCtl, decoration: const InputDecoration(labelText: 'Time (e.g., 09:00 - 10:00)')),
              const SizedBox(height: 8),
              TextField(controller: _roomCtl, decoration: const InputDecoration(labelText: 'Room')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_titleCtl.text.trim().isEmpty || _timeCtl.text.trim().isEmpty) return;
                      setState(() {
                        DemoData.classes.add({'title': _titleCtl.text.trim(), 'time': _timeCtl.text.trim(), 'room': _roomCtl.text.trim()});
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ])
            ]),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _timeCtl.dispose();
    _roomCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classes = DemoData.classes;
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, i) {
          final c = classes[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(child: Text(c['time'].toString().split(':')[0])),
              title: Text(c['title']),
              subtitle: Text('${c['time']} • ${c['room']}'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem(child: Text('Edit'), value: 'edit'),
                  PopupMenuItem(child: Text('Delete'), value: 'del'),
                ],
                onSelected: (v) {
                  if (v == 'del') {
                    setState(() => DemoData.classes.removeAt(i));
                  } else if (v == 'edit') {
                    _titleCtl.text = c['title'];
                    _timeCtl.text = c['time'];
                    _roomCtl.text = c['room'];
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('Edit Class', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Subject')),
                            const SizedBox(height: 8),
                            TextField(controller: _timeCtl, decoration: const InputDecoration(labelText: 'Time')),
                            const SizedBox(height: 8),
                            TextField(controller: _roomCtl, decoration: const InputDecoration(labelText: 'Room')),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      DemoData.classes[i] = {'title': _titleCtl.text.trim(), 'time': _timeCtl.text.trim(), 'room': _roomCtl.text.trim()};
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Update'),
                                ),
                              ),
                            ])
                          ]),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openAddDialog, child: const Icon(Icons.add)),
    );
  }
}