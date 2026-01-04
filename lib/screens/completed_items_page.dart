import 'package:flutter/material.dart';

class CompletedItemsPage extends StatelessWidget {
  const CompletedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: const Text("Completed Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _CompletedCard(title: "Vitamin D – 7 days"),
            _CompletedCard(title: "Meditation – 5 sessions"),
          ],
        ),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String title;
  const _CompletedCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.greenAccent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Completed item",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
