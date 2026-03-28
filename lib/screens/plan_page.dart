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

  List<dynamic> backendCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTips();
  }

  // -----------------------------
  // USER ID
  // -----------------------------
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString("user_id");

    if (userId == null) {
      userId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString("user_id", userId);
    }

    return userId;
  }

  // -----------------------------
  // FETCH TIPS (FIXED)
  // -----------------------------
  Future<void> fetchTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> scoreMap =
        jsonDecode(prefs.getString("symptom_scores") ?? "{}");

      String latestSymptom = "";

      if (scoreMap.isNotEmpty) {
        latestSymptom = scoreMap.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
}

      String userId = await getUserId();

      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "symptoms": latestSymptom.isNotEmpty ? [latestSymptom] : [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        backendCategories = data["recommended_tips"] ?? [];
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchTips,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: categories.map((categoryName) {
                  final categoryData = backendCategories.firstWhere(
                    (c) => c["category"] == categoryName,
                    orElse: () => null,
                  );

                  final List tips =
                      categoryData != null ? categoryData["tips"] : [];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryTipsPage(
                            category: categoryName,
                            tips: tips,
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
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              categoryName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Text(
                            "${tips.length}",
                            style: const TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(width: 8),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white54,
                          ),
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
