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

  Map<String, int> answers = {};
  bool isLoading = true;
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/get_questions"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"symptom": widget.symptom}),
    );

    if (response.statusCode == 200) {
      setState(() {
        questions = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  void saveAnswer() {
    final id = questions[currentIndex]["id"];
    answers[id] = selectedValue ?? 0;
  }

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

  Future<void> predict() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"answers": answers}),
    );

    final data = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data["test"]),
        content: Text(data["description"]),
      ),
    );
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
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            /// YES
            RadioListTile<int>(
              value: 1,
              groupValue: selectedValue,
              onChanged: (v) => setState(() => selectedValue = v),
              title: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.green,
            ),

            /// NO
            RadioListTile<int>(
              value: 0,
              groupValue: selectedValue,
              onChanged: (v) => setState(() => selectedValue = v),
              title: Text(
                "No",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.red,
            ),

            const Spacer(),

            /// ✅ BUTTON (FIXED COLOR 💜)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedValue == null ? null : nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD), // 💜 restored
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isLast ? "Submit" : "Next",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// DISCLAIMER
            Text(
              "Vytal does not provide a medical diagnosis and should not replace the judgement of a licensed healthcare practitioner.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
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
