// lib/pages/add_symptoms_page.dart

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
      _step >= 1 && _step <= 6 ? _questions[_step - 1] : null;

  void _selectSymptom(String symptom) {
    setState(() {
      _selectedSymptom = symptom;
      _step = 1;
      _answers.clear();
    });

    print('[DEBUG] Selected symptom: $symptom');
  }

  void _answerQuestion(int value) {
    final q = _currentQuestion!;
    setState(() {
      _answers[q['id']] = value;
    });

    print('[DEBUG] Answered ${q['id']} = $value');
  }

  void _next() {
    if (_step < 6) {
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
    setState(() => _loading = true);

    try {
      print('[DEBUG] Submitting symptom flow...');
      print('[DEBUG] Answers: $_answers');

      final result = await ApiService.predict(
        symptom: _selectedSymptom!,
        answers: _answers,
      );

      print('[DEBUG] ML Result: $result');

      final tests = (result['recommended_tests'] as List)
          .map((t) => RecommendedTest.fromMap(t))
          .toList();

      final log = SymptomLog(
        uid: 'local_user', // Firebase removed
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
        MaterialPageRoute(
          builder: (_) => TestResultPage(log: log),
        ),
      );
    } catch (e) {
      print('[ERROR] Submit failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to process symptoms',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.urgentRed,
        ),
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
          _step == 0 ? 'Select Symptom' : _selectedSymptom ?? '',
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

  Widget _symptomPicker() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kSymptoms.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _selectSymptom(kSymptoms[i]),
        child: Card(child: Center(child: Text(kSymptoms[i]))),
      ),
    );
  }

  Widget _questionFlow() {
    final q = _currentQuestion!;
    final currentAnswer = _answers[q['id']];

    return Column(
      children: [
        Text(q['text']),

        ElevatedButton(
          onPressed: currentAnswer != null ? _next : null,
          child: Text(_step == 6 ? 'Get Tests' : 'Next'),
        ),
      ],
    );
  }
}
