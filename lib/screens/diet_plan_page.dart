import 'package:flutter/material.dart';

class DietPlanPage extends StatelessWidget {
  const DietPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: const Text("Diet Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            _PlanItem(
              title: "Morning",
              description: "Warm water + fruits",
            ),
            _PlanItem(
              title: "Lunch",
              description: "Balanced meal with protein & veggies",
            ),
            _PlanItem(
              title: "Dinner",
              description: "Light meal before 8 PM",
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanItem extends StatelessWidget {
  final String title;
  final String description;

  const _PlanItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
