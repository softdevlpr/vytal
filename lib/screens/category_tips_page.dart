import 'package:flutter/material.dart';

class CategoryTipsPage extends StatelessWidget {
  final String category;
  final List<dynamic> tips;

  const CategoryTipsPage({
    super.key,
    required this.category,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: Text(category),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 🚨 SAFE CHECK
    if (tips.isEmpty) {
      return const Center(
        child: Text(
          "No tips available",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (_, index) {
        final tip = tips[index];

        // ✅ HANDLE BOTH CASES:
        // 1. String format
        // 2. Map format from backend
        String tipText;

        if (tip is String) {
          tipText = tip;
        } else if (tip is Map && tip.containsKey("tip_text")) {
          tipText = tip["tip_text"] ?? "";
        } else {
          tipText = tip.toString();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            tipText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),
        );
      },
    );
  }
}
