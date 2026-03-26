import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_page.dart';

class ImpactQuestionPage extends StatefulWidget {
  final String symptom;
  final List<String> selectedSymptoms;

  const ImpactQuestionPage({
    super.key,
    required this.symptom,
    required this.selectedSymptoms,
  });

  @override
  State<ImpactQuestionPage> createState() => _ImpactQuestionPageState();
}

class _ImpactQuestionPageState extends State<ImpactQuestionPage> {
  double impact = 0;

  /// ✅ Mapping UI → ML features
  final Map<String, String> symptomMapping = {
    "Headache": "dizziness",
    "Fatigue": "fatigue",
    "Anxiety": "irregular_heartbeat",
    "Sore throat": "nausea",
    "Sneezing": "short_breath",
  };

  /// ✅ Build payload
  Map<String, int> buildPayload() {
    Map<String, int> payload = {
      "chest_pain": 0,
      "short_breath": 0,
      "dizziness": 0,
      "high_bp": 0,
      "sweating": 0,
      "nausea": 0,
      "fatigue": 0,
      "arm_pain": 0,
      "jaw_pain": 0,
      "irregular_heartbeat": 0,
      "swelling_legs": 0,
      "fainting": 0,
    };

    for (var symptom in widget.selectedSymptoms) {
      final mapped = symptomMapping[symptom];
      if (mapped != null) {
        payload[mapped] = 1;
      }
    }

    return payload;
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
            onPressed: () {},
            child: const Text("Skip", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const LinearProgressIndicator(
              value: 0.25,
              backgroundColor: Colors.white12,
              color: Color(0xFF9D4EDD),
            ),
            const SizedBox(height: 20),

            const Text(
              "During the past day",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),

            const Text(
              "What was the impact on daily functioning?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            /// CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    widget.symptom,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  Slider(
                    value: impact,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: impact.round().toString(),
                    activeColor: const Color(0xFF9D4EDD),
                    onChanged: (value) {
                      setState(() {
                        impact = value;
                      });
                    },
                  ),

                  Text(
                    impact == 0
                        ? "No impact"
                        : "Impact level: ${impact.round()}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// NEXT BUTTON (FINAL FIX)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final payload = buildPayload();

                  try {
                    final result = await ApiService.predictTests(payload);

                    /// ✅ Navigate to Result Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultPage(result: result),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Prediction failed")),
                    );
                  }
                },
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
