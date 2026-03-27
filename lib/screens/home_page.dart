import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'add_symptoms_page.dart';
import 'insights_page.dart';
import 'plan_page.dart';
import 'profile_settings_page.dart';
import 'reminder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  void handleNavigation(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LifestylePage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddSymptomsPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InsightsPage()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileSettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(context),
              const SizedBox(height: 20),
              _dailyAffirmation(),
              const SizedBox(height: 25),

              Text(
                "Your Actions",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              _navigationCard(
                context,
                title: "Track Symptoms",
                subtitle: "Log how you feel today",
                icon: Icons.favorite_border,
                isPrimary: true,
                page: const AddSymptomsPage(),
              ),

              const SizedBox(height: 12),

              _navigationCard(
                context,
                title: "Insights",
                subtitle: "Understand your patterns",
                icon: Icons.bar_chart,
                page: const InsightsPage(),
              ),

              const SizedBox(height: 12),

              _navigationCard(
                context,
                title: "Tips",
                subtitle: "Your personalized plan",
                icon: Icons.check_circle,
                page: const LifestylePage(),
              ),

              const SizedBox(height: 12),

              _navigationCard(
                context,
                title: "Reminders",
                subtitle: "Never miss anything",
                icon: Icons.notifications_none,
                page: const ReminderPage(),
              ),
            ],
          ),
        ),
      ),

      /// ✅ FIXED BOTTOM NAV BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0xFF1E1E2C),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home, "Home", 0),

            navItem(Icons.check_circle, "Plan", 1),

            /// CENTER +
            GestureDetector(
              onTap: () => handleNavigation(2),
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

  Widget navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => handleNavigation(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF9D4EDD)
                : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isSelected
                  ? const Color(0xFF9D4EDD)
                  : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF9D4EDD),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello 👋",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "How are you feeling today?",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Icon(Icons.settings, color: Colors.white70),
      ],
    );
  }

  Widget _dailyAffirmation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9D4EDD),
            Color(0xFF5A0EFF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Affirmation 🌱",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "I choose to listen to my body and care for it with kindness today.",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [
                    Color(0xFF9D4EDD),
                    Color(0xFF5A0EFF),
                  ],
                )
              : null,
          color: isPrimary ? null : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
