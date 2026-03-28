import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  // Day index map for scheduling recurring notifications (DateTime weekday: Mon=1, Sun=7)
  final Map<String, int> _dayToWeekday = {
    "Mon": DateTime.monday,
    "Tue": DateTime.tuesday,
    "Wed": DateTime.wednesday,
    "Thu": DateTime.thursday,
    "Fri": DateTime.friday,
    "Sat": DateTime.saturday,
    "Sun": DateTime.sunday,
  };

  final String baseUrl = "http://10.0.2.2:3000";

  List<dynamic> _reminders = [];

  @override
  void initState() {
    super.initState();
    // Initialize timezone data for scheduled notifications
    tz.initializeTimeZones();
    fetchReminders();
  }

  // ─────────────────────────────────────────
  //  NETWORK: FETCH REMINDERS
  // ─────────────────────────────────────────

  Future<void> fetchReminders() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/reminders?userId=1"));

      if (res.statusCode == 200) {
        final fetched = List<dynamic>.from(jsonDecode(res.body));

        // [CHANGE 1] Auto-delete expired one-time reminders
        final now = DateTime.now();
        final List<dynamic> toKeep = [];

        for (final r in fetched) {
          if (r["isRecurring"] == true) {
            // Weekly reminders are always kept
            toKeep.add(r);
          } else {
            // Parse the scheduled date + time for one-time reminders
            final scheduledDateTime = _parseReminderDateTime(r);

            if (scheduledDateTime != null && scheduledDateTime.isAfter(now)) {
              // Future reminder — keep it
              toKeep.add(r);
            } else {
              // Expired one-time reminder — delete from backend silently
              _deleteExpiredReminder(r["id"]);
            }
          }
        }

        setState(() {
          _reminders = toKeep;
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  /// Parses a reminder map into a [DateTime] using its date + timeOfDay fields.
  /// Returns null if the reminder has no date field (legacy data).
  DateTime? _parseReminderDateTime(dynamic r) {
    try {
      // Expect backend to store ISO date string in "scheduledDate" field
      final dateStr = r["scheduledDate"] as String?;
      final timeStr = r["timeOfDay"] as String?; // e.g. "08:00 AM"

      if (dateStr == null || timeStr == null) return null;

      final date = DateTime.parse(dateStr);

      // Parse "HH:MM AM/PM" format
      final timeParts = timeStr.split(RegExp(r'[: ]'));
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final String? period = timeParts.length > 2 ? timeParts[2] : null;

      if (period != null) {
        if (period.toUpperCase() == "PM" && hour != 12) hour += 12;
        if (period.toUpperCase() == "AM" && hour == 12) hour = 0;
      }

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Calls the backend to remove an expired one-time reminder by ID.
  Future<void> _deleteExpiredReminder(dynamic id) async {
    if (id == null) return;
    try {
      await http.delete(Uri.parse("$baseUrl/api/reminders/$id"));
      debugPrint("🗑️ Deleted expired reminder: $id");
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  // ─────────────────────────────────────────
  //  NOTIFICATIONS
  // ─────────────────────────────────────────

  /// Schedules a local notification for the given [title].
  ///
  /// - One-time: schedules a single alarm at [_selectedDate] + [_selectedTime].
  /// - Weekly recurring: schedules one repeating notification per selected day.
  Future<void> scheduleNotification(String title) async {
    if (_selectedTime == null) return;

    if (_isRecurring && _selectedDays.isNotEmpty) {
      // [CHANGE 3] Schedule one notification per selected weekday
      for (final day in _selectedDays) {
        final weekday = _dayToWeekday[day]!;
        final nextOccurrence = _nextWeekdayTime(weekday, _selectedTime!);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          // Unique ID: combine day index + time hash to avoid collisions
          weekday * 10000 + _selectedTime!.hashCode.abs() % 10000,
          title,
          "It's time for your weekly reminder ⏰",
          nextOccurrence,
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
          // Repeat every 7 days for weekly recurrence
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        debugPrint("✅ Weekly notification scheduled for $day at ${_selectedTime!.format(context)}");
      }
    } else {
      // [CHANGE 3] One-time notification
      if (_selectedDate == null) return;

      final scheduledTime = tz.TZDateTime(
        tz.local,
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final now = tz.TZDateTime.now(tz.local);

      if (scheduledTime.isBefore(now)) {
        debugPrint("❌ Time is in past, not scheduling");
        return;
      }

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

      debugPrint("✅ One-time notification scheduled");
    }
  }

  /// Returns the next [tz.TZDateTime] for a given [weekday] at [time].
  tz.TZDateTime _nextWeekdayTime(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Advance to the correct weekday
    while (candidate.weekday != weekday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

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
            // ── FORM ──────────────────────────────
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

            // ── RECURRING TOGGLE ──────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
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
                subtitle: _isRecurring
                    ? Text(
                        "Select the days below",
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      )
                    : null,
                activeColor: const Color(0xFF9D4EDD),
              ),
            ),

            // [CHANGE 2] Improved weekly day-picker UI
            if (_isRecurring) ...[
              const SizedBox(height: 12),
              _weekdayPicker(),
            ],

            const SizedBox(height: 20),

            // ── SAVE BUTTON ───────────────────────
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

            // ── REMINDERS LIST HEADER ─────────────
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

            // ── REMINDERS LIST ────────────────────
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
                        final r = _reminders[index];
                        // [CHANGE 2] Use distinct card for weekly vs one-time
                        return r["isRecurring"] == true
                            ? _weeklyReminderCard(r)
                            : _oneTimeReminderCard(r);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WIDGETS: DAY PICKER
  // ─────────────────────────────────────────

  /// [CHANGE 2] A row of circular day-toggle buttons for weekly recurrence.
  Widget _weekdayPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Repeat on",
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              final selected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected
                        ? _selectedDays.remove(day)
                        : _selectedDays.add(day);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? const Color(0xFF9D4EDD)
                        : const Color(0xFF2A2A3C),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFBB6FF0)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF9D4EDD).withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      day[0], // Single letter: M, T, W…
                      style: GoogleFonts.poppins(
                        color: selected ? Colors.white : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WIDGETS: REMINDER CARDS
  // ─────────────────────────────────────────

  /// [CHANGE 2] Card for one-time reminders — clean and simple.
  Widget _oneTimeReminderCard(dynamic r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r["title"] ?? "",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      "${r["timeOfDay"]}  •  One-time",
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                if ((r["notes"] ?? "").toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    r["notes"],
                    style:
                        GoogleFonts.poppins(color: Colors.white24, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// [CHANGE 2] Card for weekly reminders — visually distinct with purple accent.
  Widget _weeklyReminderCard(dynamic r) {
    final List<String> days =
        List<String>.from(r["daysOfWeek"] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1245), Color(0xFF1E1E2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D4EDD).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title + "Weekly" badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    r["title"] ?? "",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D4EDD).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF9D4EDD).withOpacity(0.5)),
                  ),
                  child: Text(
                    "Weekly",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFBB6FF0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Time row
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF9D4EDD)),
                const SizedBox(width: 5),
                Text(
                  r["timeOfDay"] ?? "",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFBB6FF0),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Day chips row
            Row(
              children: weekDays.map((day) {
                final active = days.contains(day);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? const Color(0xFF9D4EDD)
                          : const Color(0xFF2A2A3C),
                    ),
                    child: Center(
                      child: Text(
                        day[0],
                        style: GoogleFonts.poppins(
                          color: active ? Colors.white : Colors.white24,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Optional notes
            if ((r["notes"] ?? "").toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                r["notes"],
                style:
                    GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WIDGETS: SHARED INPUT HELPERS
  // ─────────────────────────────────────────

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
      padding: const EdgeInsets.all(4),
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

  // ─────────────────────────────────────────
  //  PICKERS
  // ─────────────────────────────────────────

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

  // ─────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty || _selectedTime == null) return;

    // For non-recurring, a date must also be selected
    if (!_isRecurring && _selectedDate == null) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/reminders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": 1,
          "title": _titleController.text,
          "notes": _notesController.text,
          // Store ISO date so expiry check works on next fetch
          "scheduledDate": _selectedDate?.toIso8601String(),
          "timeOfDay": _selectedTime!.format(context),
          "isRecurring": _isRecurring,
          "daysOfWeek": _selectedDays,
        }),
      );

      if (response.statusCode == 201) {
        // [CHANGE 3] Schedule the appropriate notification(s)
        await scheduleNotification(_titleController.text);

        await fetchReminders();

        // Reset form state
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
      debugPrint("Save error: $e");
    }
  }
}
