import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Screens
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/plan_page.dart';
import 'screens/insights_page.dart';
import 'screens/add_symptoms_page.dart';

// 🔥 GLOBAL NOTIFICATION INSTANCE
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 ANDROID SETTINGS
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // 🔥 INITIALIZE
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(), LifestylePage(), InsightsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F011E),
        selectedItemColor: const Color(0xFF9D4EDD),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex < 2 ? _currentIndex : _currentIndex + 1,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddSymptomsPage()),
            );
          } else {
            setState(() {
              _currentIndex = index > 2 ? index - 1 : index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: "Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: "Timeline",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Insights",
          ),
        ],
      ),
    );
  }
}
