import 'package:flutter/material.dart';
import 'impact_question_page.dart';

class AddSymptomsPage extends StatefulWidget {
  const AddSymptomsPage({super.key});

  @override
  State<AddSymptomsPage> createState() => _AddSymptomsPageState();
}

class _AddSymptomsPageState extends State<AddSymptomsPage> {

  /// ✅ MUST MATCH flow.json keys
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

  /// ✅ ONLY ONE selection
  String? selectedSymptom;

  /// ✅ FIX: Proper text formatting (Chest Pain instead of CHEST PAIN)
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Skip", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),

      /// ✅ FIX: Scroll + full height handling
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TITLE
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
                    final isSelected = selectedSymptom == symptom;

                    return ListTile(
                      title: Text(
                        formatText(symptom), // ✅ FIXED
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
                          selectedSymptom = symptom;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30), // ✅ FIX: Spacer removed

              /// NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 60, // ✅ Bigger button
                child: ElevatedButton(
                  onPressed: selectedSymptom == null
                      ? null
                      : () {
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
                      borderRadius: BorderRadius.circular(18), // smoother
                    ),
                    elevation: 5,
                  ),

                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // extra bottom space
            ],
          ),
        ),
      ),
    );
  }
}
