import 'package:flutter/material.dart';
import 'add_symptoms_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      bottomNavigationBar: _bottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// DAILY AFFIRMATION
              _dailyAffirmation(),

              const SizedBox(height: 24),

              /// ACTIVE CARD (CLICKABLE)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddSymptomsPage(),
                    ),
                  );
                },
                child: _taskCard(
                  title: "Start tracking symptoms",
                  isActive: true,
                ),
              ),

              const SizedBox(height: 12),

              _taskCard(
                title: "Check out your insights",
                isActive: false,
              ),

              const SizedBox(height: 12),

              _taskCard(
                title: "Unlock homepage",
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// DAILY AFFIRMATION
  Widget _dailyAffirmation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7F00FF),
            Color(0xFFE100FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Daily Affirmation 🌱",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "I am taking care of my body and mind today.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// TASK CARD
  Widget _taskCard({required String title, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6A00F4) : const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 16,
            ),
          ),
          if (isActive)
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white),
        ],
      ),
    );
  }

  /// BOTTOM NAV BAR
  Widget _bottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0F011E),
      selectedItemColor: const Color(0xFF9D4EDD),
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
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
    );
  }
}
