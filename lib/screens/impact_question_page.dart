import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImpactQuestionPage extends StatefulWidget {
  final String symptom;

  const ImpactQuestionPage({super.key, required this.symptom});

  @override
  State<ImpactQuestionPage> createState() => _ImpactQuestionPageState();
}

class _ImpactQuestionPageState extends State<ImpactQuestionPage> {

  List questions = [];
  int currentIndex = 0;

  /// Store answers like { "fatigue": 1 }
  Map<String, int> answers = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  /// 🔥 STEP 1: Fetch questions
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
      print("Error fetching questions: $e");
    }
  }

  /// 🔥 Save answer (Yes=1, No=0)
  void saveAnswer(int value) {
    final questionId = questions[currentIndex]["id"];
    answers[questionId] = value;
  }

  /// 🔥 Next button logic
  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      /// LAST QUESTION → CALL PREDICT
      predict();
    }
  }

  /// 🔥 CALL ML MODEL
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
                  Navigator.pop(context); // back to home
                },
                child: const Text("OK"),
              ),
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

            /// QUESTION TEXT
            Text(
              question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            /// YES BUTTON
            ElevatedButton(
              onPressed: () {
                saveAnswer(1);
                nextQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Yes"),
            ),

            const SizedBox(height: 20),

            /// NO BUTTON
            ElevatedButton(
              onPressed: () {
                saveAnswer(0);
                nextQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("No"),
            ),

            const Spacer(),

            /// Progress indicator
            Text(
              "${currentIndex + 1} / ${questions.length}",
              style: const TextStyle(color: Colors.white54),
            )
          ],
        ),
      ),
    );
  }
}
