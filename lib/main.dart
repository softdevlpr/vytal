import 'package:flutter/material.dart';

// Screens
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/plan_page.dart';
import 'screens/insights_page.dart';
import 'screens/add_symptoms_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginPage(), // Start with LoginPage
    );
  }
}

/// -------------------------------
/// BOTTOM NAV CONTROLLER

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _currentIndex = 0;

  // Pages for tabs (do NOT include the + button here)
  final List<Widget> _pages = [HomePage(), PlanPage(), InsightsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F011E),
        selectedItemColor: const Color(0xFF9D4EDD),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        // Map _currentIndex to BottomNavigationBar index
        currentIndex: _currentIndex < 2 ? _currentIndex : _currentIndex + 1,
        onTap: (index) {
          if (index == 2) {
            // Middle + button tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddSymptomsPage()),
            );
          } else {
            // Map BottomNav index to _pages index
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
