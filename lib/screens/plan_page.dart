import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tips_page.dart';

class LifestylePage extends StatelessWidget {
  const LifestylePage({super.key});

  final List<Map<String, String>> categories = const [
    {"title": "Healthy Lifestyle", "key": "healthy_lifestyle"},
    {"title": "Weight Management", "key": "weight_management"},
    {"title": "Fitness & Strength", "key": "fitness_strength"},
    {"title": "Wellness Support", "key": "wellness_support"},
    {"title": "Energy & Productivity", "key": "energy_productivity"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Daily Tips",
          style: GoogleFonts.poppins(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categories.map((cat) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TipsPage(category: cat["key"]!),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.white),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        cat["title"]!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white54),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
