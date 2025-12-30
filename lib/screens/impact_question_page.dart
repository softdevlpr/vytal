import 'package:flutter/material.dart';

class ImpactQuestionPage extends StatefulWidget {
  final String symptom;

  const ImpactQuestionPage({super.key, required this.symptom});

  @override
  State<ImpactQuestionPage> createState() => _ImpactQuestionPageState();
}

class _ImpactQuestionPageState extends State<ImpactQuestionPage> {
  double impact = 0;

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
          )
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
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

            /// NEXT
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Next question (2/4)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
