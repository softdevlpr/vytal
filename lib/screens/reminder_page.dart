import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // flutterLocalNotificationsPlugin + channel constants
import 'package:timezone/timezone.dart' as tz;

// ─────────────────────────────────────────────────────────────────────────────
//  REMINDER PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // ── Form controllers ───────────────────────────────────────────────────────
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // ── Form state ─────────────────────────────────────────────────────────────
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isRecurring = false;
  List<String> _selectedDays = [];

  // ── Data ───────────────────────────────────────────────────────────────────
  List<dynamic> _reminders = [];

  // ── Constants ──────────────────────────────────────────────────────────────
  final String _baseUrl = "http://10.0.2.2:3000";

  static const List<String> _weekDays = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
  ];

  // Map day name -> Dart DateTime weekday constant
  static const Map<String, int> _dayToWeekday = {
    "Mon": DateTime.monday,
    "Tue": DateTime.tuesday,
    "Wed": DateTime.wednesday,
    "Thu": DateTime.thursday,
    "Fri": DateTime.friday,
    "Sat": DateTime.saturday,
    "Sun": DateTime.sunday,
  };

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  NETWORK
  // ═══════════════════════════════════════════════════════════════════════════

  /// Loads all reminders for userId=1, then auto-deletes expired one-time ones.
  Future<void> fetchReminders() async {
    try {
      final res =
          await http.get(Uri.parse("$_baseUrl/api/reminders?userId=1"));

      if (res.statusCode == 200) {
        final List<dynamic> all = List<dynamic>.from(jsonDecode(res.body));
        final now = DateTime.now();
        final List<dynamic> valid = [];

        for (final r in all) {
          if (r["isRecurring"] == true) {
            // Weekly reminders are never auto-deleted
            valid.add(r);
          } else {
            final scheduled = _parseScheduledDateTime(r);
            if (scheduled != null && scheduled.isAfter(now)) {
              valid.add(r);
            } else {
              // [CHANGE 1] One-time reminder has expired: delete from backend
              _deleteReminder(r["id"]);
            }
          }
        }

        setState(() => _reminders = valid);
      }
    } catch (e) {
      debugPrint("fetchReminders error: $e");
    }
  }

  /// Sends DELETE for a reminder by [id]. Silent — does not refresh UI.
  Future<void> _deleteReminder(dynamic id) async {
    if (id == null) return;
    try {
      await http.delete(Uri.parse("$_baseUrl/api/reminders/$id"));
      debugPrint("Deleted expired reminder id=$id");
    } catch (e) {
      debugPrint("_deleteReminder error: $e");
    }
  }

  /// Parses a reminder's "scheduledDate" + "timeOfDay" into a [DateTime].
  /// Returns null when either field is missing (legacy records / weekly reminders).
  DateTime? _parseScheduledDateTime(dynamic r) {
    try {
      final dateStr = r["scheduledDate"] as String?;
      final timeStr = r["timeOfDay"] as String?; // "08:00 AM" or "HH:MM"
      if (dateStr == null || timeStr == null) return null;

      final date = DateTime.parse(dateStr);
      final parts = timeStr.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      if (parts.length > 2) {
        final period = parts[2].toUpperCase();
        if (period == "PM" && hour != 12) hour += 12;
        if (period == "AM" && hour == 12) hour = 0;
      }
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Shared [NotificationDetails] used by every scheduled notification.
  static NotificationDetails get _notifDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          kNotificationChannelId,   // must match channel created in main.dart
          kNotificationChannelName,
          channelDescription: kNotificationChannelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      );

  /// Schedules notification(s) for the current form state.
  ///
  /// - One-time: single [zonedSchedule] at [_selectedDate] + [_selectedTime].
  /// - Weekly: one [zonedSchedule] per selected day with
  ///   [matchDateTimeComponents: dayOfWeekAndTime] so it repeats every 7 days.
  Future<void> scheduleNotification(String title) async {
    if (_selectedTime == null) return;

    if (_isRecurring && _selectedDays.isNotEmpty) {
      // ── Weekly notifications ─────────────────────────────────────────
      for (final day in _selectedDays) {
        final int weekday = _dayToWeekday[day]!;
        final tz.TZDateTime nextOccurrence =
            _nextWeekdayOccurrence(weekday, _selectedTime!);

        // Unique ID per day + time slot (avoids collisions across days)
        final int id =
            weekday * 10000 + (_selectedTime!.hour * 60 + _selectedTime!.minute);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          "Weekly reminder — it's time!",
          nextOccurrence,
          _notifDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // Key: repeats every 7 days automatically
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'weekly_$day',
        );

        debugPrint(
            "Weekly notif scheduled: $day at ${_selectedTime!.format(context)}, next=$nextOccurrence");
      }
    } else {
      // ── One-time notification ────────────────────────────────────────
      if (_selectedDate == null) return;

      final tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      if (scheduledTime.isBefore(now)) {
        debugPrint("Scheduled time is in the past — notification skipped");
        return;
      }

      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        "It's time for your reminder!",
        scheduledTime,
        _notifDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'onetime',
      );

      debugPrint("One-time notif scheduled for $scheduledTime");
    }
  }

  /// Returns the next [tz.TZDateTime] that falls on [weekday] at [time],
  /// always at least 1 minute in the future.
  tz.TZDateTime _nextWeekdayOccurrence(int weekday, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Advance day-by-day until we land on the right weekday in the future
    while (candidate.weekday != weekday ||
        candidate.isBefore(now.add(const Duration(minutes: 1)))) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SAVE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveReminder() async {
    // Validate: title + time always required; date required for one-time
     final androidImpl = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation
          AndroidFlutterLocalNotificationsPlugin>();
  await androidImpl?.requestNotificationsPermission();
    if (_titleController.text.trim().isEmpty || _selectedTime == null) return;
    if (!_isRecurring && _selectedDate == null) return;
    if (_isRecurring && _selectedDays.isEmpty) {
      _showSnack("Please select at least one day for weekly repeat.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/reminders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": 1,
          "title": _titleController.text.trim(),
          "notes": _notesController.text.trim(),
          // ISO date stored so expiry check works in fetchReminders()
          "scheduledDate": _selectedDate?.toIso8601String(),
          "timeOfDay": _selectedTime!.format(context),
          "isRecurring": _isRecurring,
          "daysOfWeek": _selectedDays,
        }),
      );

      if (response.statusCode == 201) {
        await scheduleNotification(_titleController.text.trim());
        await fetchReminders();
        _resetForm();
        _showSnack("Reminder saved!");
      } else {
        _showSnack("Failed to save reminder (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("_saveReminder error: $e");
      _showSnack("Error saving reminder.");
    }
  }

  void _resetForm() {
    _titleController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _isRecurring = false;
      _selectedDays.clear();
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        elevation: 0,
        title: Text(
          "Set Reminder",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── INPUT FIELDS ───────────────────────────────────────
                    _inputField("Reminder note", _titleController),
                    const SizedBox(height: 12),
                    _inputField("Notes (optional)", _notesController),
                    const SizedBox(height: 16),

                    // ── DATE / TIME PICKERS ────────────────────────────────
                    _pickerTile(
                      title: _selectedDate == null
                          ? "Pick date"
                          : "Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    _pickerTile(
                      title: _selectedTime == null
                          ? "Pick time"
                          : "Time: ${_selectedTime!.format(context)}",
                      icon: Icons.access_time_outlined,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 12),

                    // ── REPEAT TOGGLE ──────────────────────────────────────
                    _recurringToggle(),

                    // ── DAY PICKER (visible only when recurring) ───────────
                    if (_isRecurring) ...[
                      const SizedBox(height: 12),
                      _weekdayPicker(),
                    ],

                    const SizedBox(height: 20),

                    // ── SAVE BUTTON ────────────────────────────────────────
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
                        child: Text(
                          "Save Reminder",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── LIST HEADER ────────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Your Reminders",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── REMINDERS LIST ─────────────────────────────────────
                    _reminders.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_none,
                                    color: Colors.white24, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  "No reminders set yet",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white38),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reminders.length,
                            itemBuilder: (context, i) {
                              final r = _reminders[i];
                              return r["isRecurring"] == true
                                  ? _weeklyCard(r)
                                  : _oneTimeCard(r);
                            },
                          ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FORM WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: GoogleFonts.poppins(color: Colors.white))),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _recurringToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: _isRecurring,
        onChanged: (val) => setState(() {
          _isRecurring = val;
          if (!val) _selectedDays.clear();
        }),
        title: Text("Repeat Weekly",
            style: GoogleFonts.poppins(color: Colors.white)),
        subtitle: Text(
          _isRecurring ? "Choose days below" : "One-time reminder",
          style:
              GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
        ),
        activeColor: const Color(0xFF9D4EDD),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// [CHANGE 2] Animated circular day-of-week picker for weekly reminders.
  Widget _weekdayPicker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF9D4EDD).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Repeat on",
            style: GoogleFonts.poppins(
              color: const Color(0xFFBB6FF0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final selected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () => setState(() => selected
                    ? _selectedDays.remove(day)
                    : _selectedDays.add(day)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
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
                              color: const Color(0xFF9D4EDD)
                                  .withOpacity(0.45),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      day[0],
                      style: GoogleFonts.poppins(
                        color: selected ? Colors.white : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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

  // ═══════════════════════════════════════════════════════════════════════════
  //  REMINDER CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Simple card for one-time reminders.
  Widget _oneTimeCard(dynamic r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
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
                        size: 13, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      "${r["timeOfDay"] ?? ""}  •  One-time",
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                if ((r["notes"] ?? "").toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    r["notes"],
                    style: GoogleFonts.poppins(
                        color: Colors.white24, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// [CHANGE 2] Rich, visually distinct card for weekly repeating reminders.
  Widget _weeklyCard(dynamic r) {
    final List<String> days = List<String>.from(r["daysOfWeek"] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1245), Color(0xFF1C1C2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D4EDD).withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: title + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D4EDD).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9D4EDD).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.repeat,
                          size: 11, color: Color(0xFFBB6FF0)),
                      const SizedBox(width: 4),
                      Text(
                        "Repeats weekly",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFBB6FF0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: time
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF9D4EDD)),
                const SizedBox(width: 6),
                Text(
                  r["timeOfDay"] ?? "",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFBB6FF0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 3: day dots — all 7 shown, active ones highlighted
            Row(
              children: _weekDays.map((day) {
                final active = days.contains(day);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? const Color(0xFF9D4EDD)
                          : const Color(0xFF2A2A3C),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: const Color(0xFF9D4EDD)
                                    .withOpacity(0.4),
                                blurRadius: 6,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        day[0],
                        style: GoogleFonts.poppins(
                          color:
                              active ? Colors.white : Colors.white24,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Row 4: optional notes
            if ((r["notes"] ?? "").toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                r["notes"],
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PICKERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}
