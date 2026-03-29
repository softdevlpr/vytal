import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ✅ GLOBAL NOTIFICATION INSTANCE
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isRecurring = false;
  List<String> _selectedDays = [];

  final List<String> weekDays = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  ];

  final String baseUrl = "http://10.0.2.2:3000";

  List<dynamic> _reminders = [];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    fetchReminders();
  }

  // ================= NOTIFICATION INIT =================
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    tz.initializeTimeZones();
  }

  // ================= FETCH =================
  Future<void> fetchReminders() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/reminders?userId=1"));

      if (res.statusCode == 200) {
        setState(() {
          _reminders = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  // ================= NOTIFICATION =================
  Future<void> scheduleNotification(String title) async {
    if (_selectedDate == null || _selectedTime == null) return;

    final now = tz.TZDateTime.now(tz.local);

    final scheduledTime = tz.TZDateTime(
      tz.local,
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (scheduledTime.isBefore(now)) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      "It's time for your reminder ⏰",
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ================= SAVE =================
  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty || _selectedTime == null) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/reminders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": 1,
          "title": _titleController.text,
          "notes": _notesController.text,
          "timeOfDay": _selectedTime!.format(context),
          "isRecurring": _isRecurring,
          "daysOfWeek": _selectedDays,
        }),
      );

      if (response.statusCode == 201) {
        await scheduleNotification(_titleController.text);
        await fetchReminders();

        _titleController.clear();
        _notesController.clear();

        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _isRecurring = false;
          _selectedDays.clear();
        });
      }
    } catch (e) {
      print("Save error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: Text(
          "Set Reminder",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField("Reminder note", _titleController),
            const SizedBox(height: 12),

            _inputField("Notes (optional)", _notesController),
            const SizedBox(height: 16),

            _pickerTile(
              title: _selectedDate == null
                  ? "Pick date"
                  : "Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),

            const SizedBox(height: 12),

            _pickerTile(
              title: _selectedTime == null
                  ? "Pick time"
                  : "Time: ${_selectedTime!.format(context)}",
              icon: Icons.access_time,
              onTap: _pickTime,
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              value: _isRecurring,
              onChanged: (val) {
                setState(() {
                  _isRecurring = val;
                  if (!val) _selectedDays.clear();
                });
              },
              title: Text(
                "Repeat Weekly",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              activeColor: const Color(0xFF9D4EDD),
            ),

            if (_isRecurring)
              Wrap(
                spacing: 8,
                children: weekDays.map((day) {
                  final selected = _selectedDays.contains(day);
                  return ChoiceChip(
                    label: Text(day),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selected
                            ? _selectedDays.remove(day)
                            : _selectedDays.add(day);
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saveReminder,
                child: Text("Save Reminder", style: GoogleFonts.poppins()),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Reminders",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _reminders.isEmpty
                  ? Center(
                      child: Text(
                        "No reminders set yet",
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        return _reminderCard(_reminders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderCard(dynamic r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r["title"],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${r["timeOfDay"]} • ${r["isRecurring"] ? r["daysOfWeek"].join(", ") : "One-time"}",
            style: GoogleFonts.poppins(color: Colors.white54),
          ),
          if (r["notes"] != "")
            Text(r["notes"],
                style: GoogleFonts.poppins(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _pickerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white54,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }
}
