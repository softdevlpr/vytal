import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class ImpactQuestionPage extends StatefulWidget {
  final String symptom;

  const ImpactQuestionPage({super.key, required this.symptom});

  @override
  State<ImpactQuestionPage> createState() => _ImpactQuestionPageState();
}

class _ImpactQuestionPageState extends State<ImpactQuestionPage> {
  List questions = [];
  int currentIndex = 0;

  /// store answers
  Map<String, int> answers = {};

  bool isLoading = true;

  /// current selected value (radio)
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  /// FETCH QUESTIONS
  Future<void> fetchQuestions() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/get_questions"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "symptom": widget.symptom,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          questions = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  /// SAVE ANSWER
  void saveAnswer() {
    final questionId = questions[currentIndex]["id"];
    answers[questionId] = selectedValue ?? 0;
  }

  /// NEXT / SUBMIT
  void nextQuestion() {
    saveAnswer();

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedValue = null;
      });
    } else {
      predict();
    }
  }

  /// CALL ML
  Future<void> predict() async {
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

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(data["test"]),
            content: Text(data["description"]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("Predict error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex]["text"];
    final isLast = currentIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// QUESTION
            Text(
              question,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 26, // 🔥 increased
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            /// YES RADIO
            RadioListTile<int>(
              value: 1,
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
              title: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              activeColor: Colors.green,
            ),

            /// NO RADIO
            RadioListTile<int>(
              value: 0,
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
              title: Text(
                "No",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              activeColor: Colors.red,
            ),

            const Spacer(),

            /// NEXT / SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedValue == null ? null : nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isLast ? "Submit" : "Next",
                  style: const TextStyle(fontSize: 18), // ❌ unchanged
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// DISCLAIMER (unchanged)
            const Text(
              "Vytal does not provide a medical diagnosis and should not replace the judgement of a licensed healthcare practitioner.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 10),

            /// PROGRESS
            Text(
              "${currentIndex + 1} / ${questions.length}",
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
