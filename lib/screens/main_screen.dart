import 'package:flutter/material.dart';
import 'home_page.dart';
import 'plan_page.dart';
import 'insights_page.dart';
import 'profile_settings_page.dart';
import 'add_symptoms_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  void goToHome() {
    setState(() {
      currentIndex = 0;
    });
  }

  //  pass callback to pages
  late final List<Widget> pages = [
    const HomePage(),
    PlanPage(onBackToHome: goToHome),
    AddSymptomsPage(onBackToHome: goToHome), //  update this page too
    InsightsPage(onBackToHome: goToHome),   //  update this page too
    ProfileSettingsPage(onBackToHome: goToHome), //  update this page too
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //  handles Android system back button
      onWillPop: () async {
        if (currentIndex != 0) {
          goToHome();
          return false; //  don’t exit app
        }
        return true; //  allow exit if already on Home
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F011E),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: const Color(0xFF1E1E2C),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(Icons.home, "Home", 0),
              navItem(Icons.check_circle, "Tips", 1),
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
      ),
    );
  }

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
