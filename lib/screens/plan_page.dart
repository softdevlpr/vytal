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

  // -----------------------------
  // GET USER ID (IMPORTANT FIX)
  // -----------------------------
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // If not exists, create one
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

      List<String> storedSymptoms =
          prefs.getStringList("symptoms_history") ?? [];

      String userId = await getUserId();

      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "symptoms": storedSymptoms,
        }),
      );

      Map<String, List<String>> grouped = {
        for (var c in categories) c: []
      };

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List tips = data["recommended_tips"] ?? [];

        for (var block in tips) {
          String category = block["category"] ?? "";
          List tipsList = block["tips"] ?? [];

          if (grouped.containsKey(category)) {
            grouped[category] = tipsList
                .map<String>((t) => t["text"] ?? "")
                .where((t) => t.isNotEmpty)
                .toList();
          }
        }
      }

      setState(() {
        categorizedTips = grouped;
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
              onRefresh: fetchTips, // pull to refresh fixes stale tips issue
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: categories.map((category) {
                  final tips = categorizedTips[category] ?? [];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryTipsPage(
                            category: category,
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
