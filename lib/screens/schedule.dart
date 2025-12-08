import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _subjectCtl = TextEditingController();
  final TextEditingController _roomCtl = TextEditingController();
  TimeOfDay? _selectedTime;

  /// -----------------------------
  /// PICK TIME
  /// -----------------------------
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// -----------------------------
  /// SAVE CLASS (UPDATED to include startSort)
  /// -----------------------------
  Future<void> _saveClass() async {
    if (_subjectCtl.text.isEmpty ||
        _roomCtl.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    // Convert TimeOfDay to a DateTime object for formatting
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final formattedTime = DateFormat("hh:mm a").format(dt);

    // CRITICAL FIX: Calculate the sortable integer (e.g., 9:30 AM -> 930)
    final startSort = _selectedTime!.hour * 100 + _selectedTime!.minute;

    // Save to Firestore
    await FirebaseFirestore.instance.collection('classes').add({
      'subject': _subjectCtl.text,
      'startTime': formattedTime,
      'room': _roomCtl.text,
      'startSort': startSort, // <--- ADDED: Essential for filtering next class
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Class Added")));

    _subjectCtl.clear();
    _roomCtl.clear();
    setState(() => _selectedTime = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Schedule"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SUBJECT
            TextField(
              controller: _subjectCtl,
              decoration: const InputDecoration(labelText: "Subject"),
            ),

            const SizedBox(height: 20),

            /// ROOM
            TextField(
              controller: _roomCtl,
              decoration: const InputDecoration(labelText: "Room Number"),
            ),

            const SizedBox(height: 20),

            /// TIME PICKER
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text("Pick Time"),
                ),
                const SizedBox(width: 20),
                Text(
                  _selectedTime == null
                      ? "No time selected"
                      : _selectedTime!.format(context),
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            ElevatedButton(
              onPressed: _saveClass,
              child: const Text("Save Class"),
            ),

            const SizedBox(height: 25),

            const Text(
              "Saved Classes:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// -----------------------------
            /// LIVE FIRESTORE DATA LIST
            /// -----------------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .orderBy('startSort') // Order by the new sort field
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No classes added yet"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(data['subject'] ?? 'N/A'),
                          subtitle: Text(
                              "Time: ${data['startTime'] ?? 'N/A'}  |  Room: ${data['room'] ?? 'N/A'}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}