import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class gpa_calculators extends StatefulWidget {
  const gpa_calculators({super.key});

  @override
  State<gpa_calculators> createState() => _gpa_calculatorsState();
}

class _gpa_calculatorsState extends State<gpa_calculators> {
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _creditsCtl = TextEditingController();
  String _selectedGrade = 'A';

  double _gradeToPoint(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  void _openDialog({String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      _nameCtl.text = data['name'];
      _creditsCtl.text = data['credits'].toString();
      _selectedGrade = data['grade'];
    } else {
      _nameCtl.clear();
      _creditsCtl.clear();
      _selectedGrade = 'A';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data != null ? 'Edit Course' : 'Add Course',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Course name'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _creditsCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credits'),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: const InputDecoration(labelText: 'Grade'),
                items: [
                  'A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'
                ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGrade = v!),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (_nameCtl.text.isEmpty || _creditsCtl.text.isEmpty) return;

                        final col = FirebaseFirestore.instance.collection('gpa_courses');
                        final docData = {
                          'name': _nameCtl.text.trim(),
                          'credits': double.tryParse(_creditsCtl.text.trim()) ?? 0,
                          'grade': _selectedGrade,
                          'createdAt': DateTime.now(),
                        };

                        if (docId == null) {
                          await col.add(docData);
                        } else {
                          await col.doc(docId).update(docData);
                        }

                        Navigator.pop(context);
                      },
                      child: Text(data != null ? 'Update' : 'Add Course'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _nameCtl.clear();
                        _creditsCtl.clear();
                        setState(() => _selectedGrade = 'A');
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _creditsCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('gpa_courses');
    final query = col.orderBy('createdAt');

    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openDialog(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data()! as Map<String, dynamic>;

                      final credits = (data['credits'] as num).toDouble();
                      final grade = data['grade'] as String;

                      return Card(
                        child: ListTile(
                          title: Text(data['name']),
                          subtitle: Text("Credits: $credits • Grade: $grade"),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "edit") {
                                _openDialog(docId: doc.id, data: data);
                              } else if (value == "delete") {
                                col.doc(doc.id).delete();
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: "edit", child: Text("Edit")),
                              PopupMenuItem(value: "delete", child: Text("Delete")),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(),

            StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Text("GPA: 0.00");

                final docs = snap.data!.docs;
                double totalCredits = 0;
                double totalPoints = 0;

                for (var doc in docs) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final credits = (data['credits'] as num).toDouble();
                  final grade = data['grade'] as String;

                  totalCredits += credits;
                  totalPoints += credits * _gradeToPoint(grade);
                }

                final gpa = totalCredits == 0 ? 0 : totalPoints / totalCredits;

                return Text(
                  "Current GPA: ${gpa.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
