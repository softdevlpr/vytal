import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LifestylePlanPage extends StatefulWidget {
  const LifestylePlanPage({super.key});

  @override
  State<LifestylePlanPage> createState() => _LifestylePlanPageState();
}

class _LifestylePlanPageState extends State<LifestylePlanPage> {

  final String baseUrl = "http://10.0.2.2:8000";

  Map<String, List<String>> categorizedTips = {};
  String selectedCategory = "Healthy Lifestyle";
  bool isLoading = true;

  /// ✅ CATEGORY NAMES MUST MATCH BACKEND EXACTLY
  final List<String> categories = [
    "Healthy Lifestyle",
    "Weight Management",
    "Fitness & Strength",
    "Wellness Support",
    "Energy and Productivity"
  ];

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

      /// ✅ If no symptoms → still load random tips instead of blank
      if (storedSymptoms.isEmpty) {
        await loadRandomForAllCategories();
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"symptoms": storedSymptoms}),
      );

      if (response.statusCode != 200) {
        await loadRandomForAllCategories();
        return;
      }

      final data = jsonDecode(response.body);
      List tips = data["recommended_tips"] ?? [];

      Map<String, List<String>> grouped = {
        for (var cat in categories) cat: []
      };

      /// ✅ SAFE PARSING
      for (var tip in tips) {
        String category = tip["category"] ?? "";
        String text = tip["tip"] ?? "";

        if (grouped.containsKey(category)) {
          grouped[category]!.add(text);
        }
      }

      /// ✅ Fill empty categories with random tips
      for (var cat in categories) {
        if (grouped[cat]!.isEmpty) {
          final randomRes =
              await http.get(Uri.parse("$baseUrl/random_tips"));

          if (randomRes.statusCode == 200) {
            final randomData = jsonDecode(randomRes.body);
            List randomTips = randomData["tips"] ?? [];

            grouped[cat] = randomTips
                .take(3)
                .map<String>((t) => t["tip"] ?? "")
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

      /// fallback
      await loadRandomForAllCategories();
    }
  }

  /// ✅ fallback loader (important)
  Future<void> loadRandomForAllCategories() async {
    Map<String, List<String>> grouped = {
      for (var cat in categories) cat: []
    };

    try {
      final res = await http.get(Uri.parse("$baseUrl/random_tips"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List tips = data["tips"] ?? [];

        for (var cat in categories) {
          grouped[cat] = tips
              .take(3)
              .map<String>((t) => t["tip"] ?? "")
              .toList();
        }
      }
    } catch (e) {
      print("RANDOM ERROR: $e");
    }

    setState(() {
      categorizedTips = grouped;
      isLoading = false;
    });
  }

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
          children: [

            /// 🔘 CATEGORY BUTTONS
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selectedCategory == category
                            ? Colors.purple
                            : const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 📦 TIPS LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categorizedTips[selectedCategory] == null ||
                          categorizedTips[selectedCategory]!.isEmpty
                      ? const Center(
                          child: Text(
                            "No tips available",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView(
                          children:
                              categorizedTips[selectedCategory]!
                                  .map((tip) => _LifestyleTile(
                                        icon: Icons.check_circle,
                                        title: tip,
                                      ))
                                  .toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 TILE
class _LifestyleTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _LifestyleTile({
    required this.icon,
    required this.title,
  });

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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
