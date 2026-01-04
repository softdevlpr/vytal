import 'package:flutter/material.dart';

class ExercisePlanPage extends StatelessWidget {
  const ExercisePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: const Text("Exercise Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _ExerciseCard(
              title: "Stretching",
              duration: "10 minutes",
            ),
            _ExerciseCard(
              title: "Walking",
              duration: "20 minutes",
            ),
            _ExerciseCard(
              title: "Breathing",
              duration: "5 minutes",
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String duration;

  const _ExerciseCard({
    required this.title,
    required this.duration,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            duration,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
