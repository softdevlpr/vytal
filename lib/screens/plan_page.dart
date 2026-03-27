import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'category_tips_page.dart';

class LifestylePage extends StatefulWidget {
  const LifestylePage({super.key});

  @override
  State<LifestylePage> createState() => _LifestylePageState();
}

class _LifestylePageState extends State<LifestylePage> {
  final String baseUrl = "http://10.0.2.2:8000";

  final List<String> categories = [
    "Healthy Lifestyle",
    "Weight Management",
    "Fitness & Strength",
    "Condition Support",
    "Energy and Productivity"
  ];

  Map<String, List<String>> categorizedTips = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTips();
  }

  Future<void> fetchTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> storedSymptoms =
          prefs.getStringList("symptoms_history") ?? [];

      Map<String, int> symptomScores = {};

      String? storedScores = prefs.getString("symptom_scores");

      if (storedScores != null && storedScores.isNotEmpty) {
        symptomScores = Map<String, int>.from(jsonDecode(storedScores));
      }

      String topSymptom = "";
      int maxScore = 0;

      symptomScores.forEach((key, value) {
        if (value > maxScore) {
          maxScore = value;
          topSymptom = key;
        }
      });

      Map<String, List<String>> grouped = {
        for (var cat in categories) cat: []
      };

      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "symptoms": storedSymptoms,
          "symptom_scores": symptomScores
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List tips = data["recommended_tips"] ?? [];

        for (var categoryBlock in tips) {
          String category = categoryBlock["category"] ?? "";
          List tipsList = categoryBlock["tips"] ?? [];

          if (grouped.containsKey(category)) {
            for (var tip in tipsList) {
              String text = tip["text"] ?? "";
              if (text.isNotEmpty) {
                grouped[category]!.add(text);
              }
            }
          }
        }
      }

      final randomRes = await http.get(
        Uri.parse("$baseUrl/random_tips"),
      );

      if (randomRes.statusCode == 200) {
        final randomData = jsonDecode(randomRes.body);
        List randomTips = randomData["tips"] ?? [];

        /// 🔥 FIX: shuffle so every category gets different tips
        randomTips.shuffle();

        int index = 0;

        for (var cat in categories) {
          bool isRelevant = topSymptom.isNotEmpty &&
              cat.toLowerCase().contains(topSymptom.replaceAll("_", " "));

          if (grouped[cat]!.isEmpty) {
            int takeCount = isRelevant ? 5 : 3;

            List<String> selected = [];

            for (int i = 0; i < takeCount; i++) {
              if (index >= randomTips.length) {
                index = 0; // restart if needed
              }

              selected.add(randomTips[index]["text"] ?? "");
              index++;
            }

            grouped[cat] = selected;
          }
        }
      }

      setState(() {
        categorizedTips = grouped;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Daily Tips", style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryTipsPage(
                            category: category,
                            tips: categorizedTips[category] ?? [],
                          ),
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
                          const Icon(Icons.lightbulb_outline,
                              color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category,
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
