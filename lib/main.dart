import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; // flutter_timezone package
import 'screens/login_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/home_page.dart';
import 'screens/plan_page.dart';
import 'screens/insights_page.dart';
import 'screens/add_symptoms_page.dart';
import 'screens/profile_settings_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  GLOBAL NOTIFICATION PLUGIN INSTANCE
//  Declared globally so reminder_page.dart (and any other screen) can import
//  and use it directly via `import '../main.dart';`
// ─────────────────────────────────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ─────────────────────────────────────────────────────────────────────────────
//  NOTIFICATION CHANNEL CONSTANTS
//  Keep in one place so channel IDs are never mismatched between
//  initialization and scheduling.
// ─────────────────────────────────────────────────────────────────────────────
const String kNotificationChannelId = 'reminder_channel';
const String kNotificationChannelName = 'Reminders';
const String kNotificationChannelDesc = 'Scheduled reminder notifications';

// ─────────────────────────────────────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣  Timezone — must happen before any zonedSchedule call.
  //     flutter_timezone reads the device/emulator's actual tz (e.g. "Asia/Kolkata")
  //     so notifications fire at the correct local time, not UTC.
  tz.initializeTimeZones();
  try {
    final String localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));
    debugPrint('⏰ Timezone set to: $localTz');
  } catch (e) {
    // Fallback: keep UTC — still functional, times will be offset
    debugPrint('⚠️ Could not read local timezone, defaulting to UTC: $e');
  }

  // 2️⃣  Notification plugin — Android settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    // Optional: handle notification tap while app is in foreground
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('🔔 Notification tapped: ${response.payload}');
    },
  );

  // 3️⃣  Create the Android notification channel explicitly.
  //     On emulators this ensures the channel exists before any notification
  //     is scheduled — avoids "channel not found" silent failures.
  await _createNotificationChannel();

  // 4️⃣  Request POST_NOTIFICATIONS permission (Android 13+ / API 33+).
  //     On older APIs this is a no-op.
  await _requestNotificationPermission();

  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Creates the notification channel used by all reminders.
/// Safe to call multiple times — Android is idempotent for existing channels.
Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    kNotificationChannelId,
    kNotificationChannelName,
    description: kNotificationChannelDesc,
    importance: Importance.max,        // Heads-up notification on emulator
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  debugPrint('✅ Notification channel created: $kNotificationChannelId');
}

/// Requests POST_NOTIFICATIONS permission on Android 13+.
/// Uses the built-in flutter_local_notifications request API —
/// no extra permission_handler package required.
Future<void> _requestNotificationPermission() async {
  final androidImpl = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImpl != null) {
    final bool? granted = await androidImpl.requestNotificationsPermission();
    debugPrint(granted == true
        ? '✅ Notification permission granted'
        : '⚠️ Notification permission denied or not required');

    // Also request exact-alarm permission (Android 12+)
    final bool? exactAlarm =
        await androidImpl.requestExactAlarmsPermission();
    debugPrint(exactAlarm == true
        ? '✅ Exact alarm permission granted'
        : '⚠️ Exact alarm permission not granted (emulator usually pre-grants)');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F011E),
      ),
      home: OnboardingPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM NAV CONTROLLER  (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────
class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    LifestylePage(),
    AddSymptomsPage(),
    InsightsPage(),
    ProfileSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F011E),
        selectedItemColor: const Color(0xFF9D4EDD),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb), label: "Tips"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 36), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Insights"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
