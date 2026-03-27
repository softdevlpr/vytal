import 'package:flutter/material.dart';
import 'impact_question_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          /// 🔥 SCROLLABLE PART
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Get test recommendations",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                            color: isSelected
                                ? const Color(0xFF9D4EDD)
                                : Colors.white38,
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
                ],
              ),
            ),
          ),

          /// 🔥 FIXED BUTTON
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: selectedSymptom == null
                    ? null
                    : () async {
                        final prefs =
                            await SharedPreferences.getInstance();

                        List<String> storedSymptoms =
                            prefs.getStringList("symptoms_history") ?? [];

                        // 🔥 Add selected symptom
                        storedSymptoms.add(selectedSymptom!);

                        await prefs.setStringList(
                            "symptoms_history", storedSymptoms);

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
