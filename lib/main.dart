import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'screens/login_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/home_page.dart';
import 'screens/plan_page.dart';
import 'screens/insights_page.dart';
import 'screens/add_symptoms_page.dart';
import 'screens/profile_settings_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();

  runApp(const MyApp());
}

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

/// 🔥 MAIN NAV CONTROLLER (USED AFTER LOGIN)
class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int currentIndex = 0;

  final List<Widget> pages = [
  HomePage(),
  LifestylePage(), //  REPLACED
  AddSymptomsPage(),
  InsightsPage(),
  ProfileSettingsPage(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),

      /// 🔥 PAGE SWITCH
      body: pages[currentIndex],

      /// 🔥 CUSTOM BOTTOM NAV
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0xFF1E1E2C),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home, "Home", 0),
            navItem(Icons.check_circle, "Plan", 1),

            /// ➕ CENTER BUTTON
            GestureDetector(
              onTap: () {
                setState(() {
                  currentIndex = 2;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),

            navItem(Icons.bar_chart, "Insights", 3),
            navItem(Icons.person, "Profile", 4),
          ],
        ),
      ),
    );
  }

  /// 🔥 NAV ITEM
  Widget navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF9D4EDD) : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? const Color(0xFF9D4EDD) : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
