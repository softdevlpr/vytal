import 'package:flutter/material.dart';
import 'diet_plan_page.dart';
import 'lifestyle_plan_page.dart';
import 'exercise_plan_page.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        elevation: 0,
        title: const Text("Your Daily Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DietPlanPage(),
                  ),
                );
              },
              child: _planCard(
                title: "Diet Plan",
                subtitle: "Personalized meals for your body",
                icon: Icons.restaurant,
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LifestylePlanPage(),
                  ),
                );
              },
              child: _planCard(
                title: "Lifestyle",
                subtitle: "Sleep, hydration & habits",
                icon: Icons.self_improvement,
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExercisePlanPage(),
                  ),
                );
              },
              child: _planCard(
                title: "Exercise",
                subtitle: "Gentle workouts & activity",
                icon: Icons.fitness_center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A00F4), Color(0xFF9D4EDD)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
