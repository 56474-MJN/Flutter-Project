import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Add Assignment', style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium),
              const SizedBox(height: 8),
              TextField(controller: _titleCtl,
                  decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text(
                    _pickedDate == null ? 'Pick due date' : _pickedDate!
                        .toLocal().toString().split(' ')[0])),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (d != null) setState(() => _pickedDate = d);
                  },
                  child: const Text('Choose'),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async  {
                      if (_titleCtl.text.trim().isEmpty || _pickedDate == null)
                        return;
                      await FirebaseFirestore.instance
                          .collection('assignments')
                          .add({
                        'title': _titleCtl.text.trim(),
                        'due': Timestamp.fromDate(_pickedDate!),
                        'completed': false,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .orderBy('due')
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              final dueDate =
              (data['due'] as Timestamp).toDate().toString().split(' ')[0];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  value: data['completed'],
                  onChanged: (v)async {
                    FirebaseFirestore.instance
                        .collection('assignments')
                        .doc(doc.id)
                        .update({'completed': v ?? false});
                  },

                  title: Text(data['title']),
                  subtitle: Text('Due: $dueDate'),

                  secondary: PopupMenuButton<String>(
                    itemBuilder: (_) =>
                    const [
                      PopupMenuItem(
                        value: 'del',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (v) {
                      if (v == 'del') {
                        FirebaseFirestore.instance
                            .collection('assignments')
                            .doc(doc.id)
                            .delete();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add_task),
      ),
    );
  }
}