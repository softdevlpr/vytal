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

  //  Emulator URL (change later for real phone)
  final String baseUrl = "http://10.0.2.2:8000";

  Map<String, List<String>> categorizedTips = {};
  String selectedCategory = "Healthy Lifestyle";
  bool isLoading = true;

  final List<String> categories = [
    "Healthy Lifestyle",
    "Weight Management",
    "Fitness & Strength",
    "Condition Support",
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

      // 🔥 Get all past symptoms
      List<String> storedSymptoms =
          prefs.getStringList("symptoms_history") ?? [];

      // If no data yet
      if (storedSymptoms.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // 🔥 Call backend with ALL symptoms
      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"symptoms": storedSymptoms}),
      );

      final data = jsonDecode(response.body);
      List tips = data["recommended_tips"];

      // 🔥 Create category map
      Map<String, List<String>> grouped = {
        for (var cat in categories) cat: []
      };

      // 🔥 Group tips by category
      for (var tip in tips) {
        String category = tip["category"];
        String text = tip["tip"];

        if (grouped.containsKey(category)) {
          grouped[category]!.add(text);
        }
      }

      // 🔥 Fill empty categories using random tips
      for (var cat in categories) {
        if (grouped[cat]!.isEmpty) {
          final randomRes =
              await http.get(Uri.parse("$baseUrl/random_tips"));

          final randomData = jsonDecode(randomRes.body);
          List randomTips = randomData["tips"];

          grouped[cat] = randomTips
              .take(3)
              .map<String>((t) => t["tip"])
              .toList();
        }
      }

      setState(() {
        categorizedTips = grouped;
        isLoading = false;
      });

    } catch (e) {
      print("Error: $e");
    }
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

            // 🔘 CATEGORY BUTTONS
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

            // 📦 TIPS LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categorizedTips.isEmpty
                      ? const Center(
                          child: Text(
                            "No data yet. Add symptoms first.",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView(
                          children:
                              (categorizedTips[selectedCategory] ?? [])
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

// 🔹 SAME UI TILE (UNCHANGED STYLE)
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
