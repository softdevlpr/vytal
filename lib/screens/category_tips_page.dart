import 'package:flutter/material.dart';

class CategoryTipsPage extends StatelessWidget {
  final String category;
  final List<String> tips;

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

      body: tips.isEmpty
          ? const Center(
              child: Text(
                "No tips available",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tips.length,
              itemBuilder: (_, index) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    tips[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18, // 🔥 bigger
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
