import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _timeCtl = TextEditingController();
  final TextEditingController _roomCtl = TextEditingController();

  void _openAddDialog({String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      _titleCtl.text = data['title'];
      _timeCtl.text = data['time'];
      _roomCtl.text = data['room'];
    } else {
      _titleCtl.clear();
      _timeCtl.clear();
      _roomCtl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(data != null ? 'Edit Class' : 'Add Class',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 8),
              TextField(controller: _timeCtl, decoration: const InputDecoration(labelText: 'Time')),
              const SizedBox(height: 8),
              TextField(controller: _roomCtl, decoration: const InputDecoration(labelText: 'Room')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (_titleCtl.text.isEmpty || _timeCtl.text.isEmpty) return;
                      final col = FirebaseFirestore.instance.collection('classes');
                      if (docId == null) {
                        await col.add({
                          'title': _titleCtl.text.trim(),
                          'time': _timeCtl.text.trim(),
                          'room': _roomCtl.text.trim(),
                          'createdAt': DateTime.now(),
                        });
                      } else {
                        await col.doc(docId).update({
                          'title': _titleCtl.text.trim(),
                          'time': _timeCtl.text.trim(),
                          'room': _roomCtl.text.trim(),
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: Text(data != null ? 'Update' : 'Save'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('classes').orderBy('createdAt').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data()! as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(child: Text(data['time'].toString().split(':')[0])),
                  title: Text(data['title']),
                  subtitle: Text('${data['time']} • ${data['room']}'),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (_) => const [
                      PopupMenuItem(child: Text('Edit'), value: 'edit'),
                      PopupMenuItem(child: Text('Delete'), value: 'del'),
                    ],
                    onSelected: (v) {
                      if (v == 'del') {
                        FirebaseFirestore.instance.collection('classes').doc(doc.id).delete();
                      } else if (v == 'edit') {
                        _openAddDialog(docId: doc.id, data: data);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openAddDialog(), child: const Icon(Icons.add)),
    );
  }
}
