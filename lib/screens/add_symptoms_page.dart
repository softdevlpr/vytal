import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_constants.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'test_result_page.dart';

class AddSymptomsPage extends StatefulWidget {
  const AddSymptomsPage({super.key});

  @override
  State<AddSymptomsPage> createState() => _AddSymptomsPageState();
}

class _AddSymptomsPageState extends State<AddSymptomsPage> {
  String? _selectedSymptom;
  int _step = 0;

  final Map<String, int> _answers = {};
  bool _loading = false;

  List<Map<String, dynamic>> get _questions =>
      _selectedSymptom != null
          ? kSymptomQuestions[_selectedSymptom!] ?? []
          : [];

  Map<String, dynamic>? get _currentQuestion =>
      (_selectedSymptom != null &&
              _step > 0 &&
              _step <= _questions.length)
          ? _questions[_step - 1]
          : null;

  void _selectSymptom(String symptom) {
    setState(() {
      _selectedSymptom = symptom;
      _step = 1;
      _answers.clear();
    });
  }

  void _answerQuestion(int value) {
    final q = _currentQuestion;
    if (q == null) return;

    setState(() {
      _answers[q['id']] = value;
    });
  }

  void _next() {
    if (_step < _questions.length) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 1) {
      setState(() {
        _step = 0;
        _selectedSymptom = null;
        _answers.clear();
      });
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _submit() async {
    if (_selectedSymptom == null) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService.predict(
        symptom: _selectedSymptom!,
        answers: _answers,
      );

      final tests = (result['recommended_tests'] as List)
          .map((t) => RecommendedTest.fromMap(t))
          .toList();

      final log = SymptomLog(
        uid: 'local_user',
        primarySymptom: _selectedSymptom!,
        answers: _answers,
        urgency: result['urgency'],
        recommendedTests: tests,
        severityScore:
            (_answers['Q2'] ?? 1) * 2 +
            _answers.values.where((v) => v == 1).length,
        loggedAt: DateTime.now(),
      );

      await ApiService.saveSymptomLog(log);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TestResultPage(log: log)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to process symptoms")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: _step == 0 ? () => Navigator.pop(context) : _back,
        ),
        title: Text(
          _step == 0 ? 'Select Symptom' : (_selectedSymptom ?? ''),
          style: GoogleFonts.poppins(color: AppColors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _step == 0
              ? _symptomPicker()
              : _questionFlow(),
    );
  }

  // FIXED SYMPTOM GRID (icons restored)
  Widget _symptomPicker() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kSymptoms.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, i) {
        final symptom = kSymptoms[i];

        return GestureDetector(
          onTap: () => _selectSymptom(symptom),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.health_and_safety,
                        size: 40, color: Colors.redAccent),
                    const SizedBox(height: 10),
                    Text(
                      symptom,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //  FIXED QUESTION UI (YES/NO buttons restored)
  Widget _questionFlow() {
    final q = _currentQuestion;

    if (q == null) {
      return const Center(child: Text("No questions found"));
    }

    final currentAnswer = _answers[q['id']];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q['text'],
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 30),

          //  YES / NO BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => _answerQuestion(1),
                  child: const Text("YES"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => _answerQuestion(0),
                  child: const Text("NO"),
                ),
              ),
            ],
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: currentAnswer != null ? _next : null,
            child: Text(_step == _questions.length ? 'Get Tests' : 'Next'),
          ),
        ],
      ),
    );
  }
}
