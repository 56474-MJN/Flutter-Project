import 'package:flutter/material.dart';
import '../data/demo_data.dart';
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController _titleCtl = TextEditingController();
  DateTime? _pickedDate;

  void _openAdd() {
    _titleCtl.clear();
    _pickedDate = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Add Assignment', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text(_pickedDate == null ? 'Pick due date' : _pickedDate!.toLocal().toString().split(' ')[0])),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => _pickedDate = d);
                  },
                  child: const Text('Choose'),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_titleCtl.text.trim().isEmpty || _pickedDate == null) return;
                      setState(() {
                        DemoData.assignments.insert(0, {
                          'title': _titleCtl.text.trim(),
                          'due': _pickedDate,
                          'dueLabel': _pickedDate!.toLocal().toString().split(' ')[0],
                          'completed': false,
                        });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignments = DemoData.assignments;
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, i) {
          final a = assignments[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: CheckboxListTile(
              value: a['completed'],
              onChanged: (v) => setState(() => a['completed'] = v ?? false),
              title: Text(a['title']),
              subtitle: Text('Due: ${a['dueLabel']}'),
              secondary: PopupMenuButton<String>(
                itemBuilder: (_) => const [PopupMenuItem(child: Text('Delete'), value: 'del')],
                onSelected: (v) {
                  if (v == 'del') {
                    setState(() => DemoData.assignments.removeAt(i));
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openAdd, child: const Icon(Icons.add_task)),
    );
  }
}
