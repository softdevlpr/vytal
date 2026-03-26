import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddSymptomsPage extends StatefulWidget {
  const AddSymptomsPage({super.key});

  @override
  State<AddSymptomsPage> createState() => _AddSymptomsPageState();
}

class _AddSymptomsPageState extends State<AddSymptomsPage> {

  /// ⚠️ MUST MATCH BACKEND CSV COLUMNS
  final List<String> symptoms = [
    "sneezing",
    "anxiety",
    "headache",
    "fatigue",
    "sore_throat",
  ];

  final Set<String> selectedSymptoms = {};

  /// 🔥 Convert to backend format
  Map<String, int> buildAnswers() {
    Map<String, int> answers = {};

    for (var symptom in symptoms) {
      answers[symptom] = selectedSymptoms.contains(symptom) ? 1 : 0;
    }

    return answers;
  }

  /// 🔥 API CALL
  Future<void> predict() async {
    final answers = buildAnswers();

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "answers": answers,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final test = data["test"];
        final description = data["description"];

        /// 👉 Show result
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(test),
            content: Text(description),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Skip", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get symptom recommendations",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            /// CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: symptoms.map((symptom) {
                  final isSelected = selectedSymptoms.contains(symptom);

                  return ListTile(
                    title: Text(
                      symptom.replaceAll("_", " ").toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? const Color(0xFF9D4EDD)
                          : Colors.white38,
                    ),
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selectedSymptoms.remove(symptom)
                            : selectedSymptoms.add(symptom);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const Spacer(),

            /// NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: selectedSymptoms.isEmpty ? null : predict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Next", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
