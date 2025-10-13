import 'package:flutter/material.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _creditsCtl = TextEditingController();
  String _selectedGrade = 'A';

  @override
  void dispose() {
    _nameCtl.dispose();
    _creditsCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dummy sample data for UI display (not stored)
    final courses = [
      {'name': 'Software Engineering', 'credits': 3.0, 'grade': 'A'},
      {'name': 'Database Systems', 'credits': 4.0, 'grade': 'B+'},
      {'name': 'HCI', 'credits': 2.0, 'grade': 'A-'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, i) {
                  final c = courses[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(c['name'].toString()),
                      subtitle: Text(
                        'Credits: ${c['credits']} • Grade: ${c['grade']}',
                      ),
                      trailing: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            TextField(
              controller: _nameCtl,
              decoration: const InputDecoration(labelText: 'Course name'),
              enabled: false, // disabled since no backend
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _creditsCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credits'),
              enabled: false,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGrade,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: null, // disabled dropdown
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: null, // disabled
                    child: const Text('Add Course'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: null, // disabled
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Current GPA: 3.67',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
