import 'package:flutter/material.dart';

// Pages
import 'add_symptoms_page.dart';
import 'insights_page.dart';
import 'plan_page.dart';
import 'profile_settings_page.dart';
import 'reminder_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

              /// PROFILE HEADER
              _profileHeader(context),

              const SizedBox(height: 20),

              /// DAILY AFFIRMATION
              _dailyAffirmation(),

              const SizedBox(height: 24),

              /// START TRACKING
              _navigationCard(
                context,
                title: "Start tracking symptoms",
                isActive: true,
                page: const AddSymptomsPage(),
              ),

              const SizedBox(height: 12),

              /// INSIGHTS
              _navigationCard(
                context,
                title: "Check out your insights",
                isActive: false,
                page: const InsightsPage(),
              ),

              const SizedBox(height: 12),

              /// PLAN
              _navigationCard(
                context,
                title: "View your plan",
                isActive: false,
                page: const PlanPage(),
              ),

              const SizedBox(height: 12),

              /// REMINDER
              _navigationCard(
                context,
                title: "Set a reminder",
                isActive: false,
                page: const ReminderPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// PROFILE HEADER
  Widget _profileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF9D4EDD),
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hello 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "How are you feeling today?",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white70),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileSettingsPage(),
              ),
            );
          },
        ),
      ],
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
            style: TextStyle(color: Colors.white70, fontSize: 14),
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

  /// NAVIGATION CARD (Reusable)
  Widget _navigationCard(
    BuildContext context, {
    required String title,
    required bool isActive,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6A00F4)
              : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 16,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
