import 'package:flutter/material.dart';

class LifestylePlanPage extends StatelessWidget {
  const LifestylePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: const Text("Lifestyle Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _LifestyleTile(
              icon: Icons.bedtime,
              title: "Sleep 7–8 hours",
            ),
            _LifestyleTile(
              icon: Icons.water_drop,
              title: "Drink 2–3L water",
            ),
            _LifestyleTile(
              icon: Icons.self_improvement,
              title: "10 min mindfulness",
            ),
          ],
        ),
      ),
    );
  }
}

class _LifestyleTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _LifestyleTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
