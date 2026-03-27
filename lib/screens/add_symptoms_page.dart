import 'package:flutter/material.dart';
import 'impact_question_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddSymptomsPage extends StatefulWidget {
  const AddSymptomsPage({super.key});

  @override
  State<AddSymptomsPage> createState() => _AddSymptomsPageState();
}

class _AddSymptomsPageState extends State<AddSymptomsPage> {
  final List<String> symptoms = [
    "chest_pain",
    "short_breath",
    "dizziness",
    "high_bp",
    "sweating",
    "nausea",
    "fatigue",
    "arm_pain",
    "jaw_pain",
    "irregular_heartbeat",
    "swelling_legs",
    "fainting"
  ];

  String? selectedSymptom;

  String formatText(String text) {
    return text
        .split("_")
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(" ");
  }

  Future<void> saveSymptomScore() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, int> scores = {};

    final stored = prefs.getString("symptom_scores");

    if (stored != null && stored.isNotEmpty) {
      scores = Map<String, int>.from(jsonDecode(stored));
    }

    //  ONLY increase here (Next button click)
    scores[selectedSymptom!] = (scores[selectedSymptom!] ?? 0) + 1;

    await prefs.setString("symptom_scores", jsonEncode(scores));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: symptoms.map((symptom) {
                  final isSelected = selectedSymptom == symptom;

                  return ListTile(
                    title: Text(
                      formatText(symptom),
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isSelected ? const Color(0xFF9D4EDD) : Colors.white38,
                    ),
                    onTap: () {
                      setState(() {
                        selectedSymptom = symptom;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: selectedSymptom == null
                    ? null
                    : () async {
                        //  score increases ONLY here
                        await saveSymptomScore();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImpactQuestionPage(
                              symptom: selectedSymptom!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                ),
                child: const Text("Next"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
