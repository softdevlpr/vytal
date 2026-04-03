import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_constants.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'test_result_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSymptomsPage extends StatefulWidget {
  final VoidCallback onBackToHome; //  added

  const AddSymptomsPage({super.key, required this.onBackToHome});

  @override
  State<AddSymptomsPage> createState() => _AddSymptomsPageState();
}

class _AddSymptomsPageState extends State<AddSymptomsPage> {
  String? _selectedSymptom;
  int _step = 0;
  final Map<String, int> _answers = {};
  bool _loading = false;

  String _uid = '';

  List<Map<String, dynamic>> get _questions =>
      _selectedSymptom != null ? kSymptomQuestions[_selectedSymptom!] ?? [] : [];

  Map<String, dynamic>? get _currentQuestion =>
      _step >= 1 && _step <= 6 ? _questions[_step - 1] : null;

  void _selectSymptom(String symptom) {
    setState(() {
      _selectedSymptom = symptom;
      _step = 1;
      _answers.clear();
    });
  }

  void _answerQuestion(int value) {
    final q = _currentQuestion!;
    setState(() {
      _answers[q['id']] = value;
    });
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

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid') ?? '';
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    await _loadUid();

    if (_uid.isEmpty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not logged in',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.urgentRed,
        ),
      );
      return;
    }

    try {
      final result = await ApiService.predict(
        symptom: _selectedSymptom!,
        answers: _answers,
      );

      final tests = (result['recommended_tests'] as List)
          .map((t) => RecommendedTest.fromMap(t))
          .toList();

      final log = SymptomLog(
        uid: _uid,
        primarySymptom: _selectedSymptom!,
        answers: _answers,
        urgency: result['urgency'],
        recommendedTests: tests,
        severityScore: (_answers['Q2'] ?? 1) * 2 +
            _answers.values.where((v) => v == 1).length,
        loggedAt: DateTime.now(),
      );

      await ApiService.saveSymptomLog(log);

      if (!mounted) return;
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestResultPage(
          log: log,
            onBackToHome: () {
              widget.onBackToHome(); // switch to Home tab

              Navigator.pop(context); // just go back ONE screen
      },
    ),
  ),
);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.',
              style: GoogleFonts.poppins()),
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
          onPressed: _step == 0
              ? widget.onBackToHome // FIXED
              : _back,
        ),
        title: Text(
          _step == 0 ? 'Select Symptom' : _selectedSymptom ?? '',
          style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _step == 0
              ? _symptomPicker()
              : _questionFlow(),
    );
  }

  // ── SYMPTOM PICKER ──────────────────────────────────────────────────────────
  Widget _symptomPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you experiencing?',
              style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Select one symptom to begin',
              style: GoogleFonts.poppins(
                  color: AppColors.white54, fontSize: 13)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: kSymptoms.length,
            itemBuilder: (_, i) => _symptomTile(kSymptoms[i]),
          ),
        ],
      ),
    );
  }

  Widget _symptomTile(String symptom) {
    return GestureDetector(
      onTap: () => _selectSymptom(symptom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_symptomIcon(symptom),
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(symptom,
                  style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  // ── QUESTION FLOW ──────────────────────────────────────────────────────────
  Widget _questionFlow() {
    final q = _currentQuestion!;
    final isScale = q['type'] == 'scale';
    final currentAnswer = _answers[q['id']];
    final progress = _step / 6.0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Question $_step of 6',
                  style: GoogleFonts.poppins(
                      color: AppColors.white54, fontSize: 13)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                      color: AppColors.primary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.card,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(q['text'],
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.5)),
          ),

          const SizedBox(height: 32),

          if (isScale) ...[
            Row(
              children: [
                _scaleOption(1, 'Mild', AppColors.routineGreen, currentAnswer),
                const SizedBox(width: 10),
                _scaleOption(2, 'Moderate', AppColors.soonAmber, currentAnswer),
                const SizedBox(width: 10),
                _scaleOption(3, 'Severe', AppColors.urgentRed, currentAnswer),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(child: _ynOption(0, 'No', Icons.close, currentAnswer)),
                const SizedBox(width: 16),
                Expanded(
                    child: _ynOption(1, 'Yes', Icons.check, currentAnswer)),
              ],
            ),
          ],

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: currentAnswer != null ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _step == 6 ? 'Get My Tests' : 'Next',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scaleOption(int value, String label, Color color, int? selected) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _answerQuestion(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected ? color : Colors.white12, width: 2),
          ),
          child: Column(
            children: [
              Icon(Icons.circle,
                  color: isSelected ? color : Colors.white24, size: 14),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.poppins(
                      color: isSelected ? color : AppColors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ynOption(int value, String label, IconData icon, int? selected) {
    final isSelected = selected == value;
    final color = value == 1 ? AppColors.primary : AppColors.white54;
    return GestureDetector(
      onTap: () => _answerQuestion(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: isSelected ? color : Colors.white12, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white24, size: 28),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.poppins(
                    color: isSelected ? color : AppColors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  IconData _symptomIcon(String symptom) {
    switch (symptom) {
      case 'Chest Pain': return Icons.favorite_border;
      case 'Shortness of Breath': return Icons.air;
      case 'Dizziness': return Icons.rotate_right;
      case 'High BP': return Icons.monitor_heart;
      case 'Sweating': return Icons.water_drop;
      case 'Nausea': return Icons.sick;
      case 'Fatigue': return Icons.battery_1_bar;
      case 'Arm Pain': return Icons.accessibility_new;
      case 'Jaw Pain': return Icons.face;
      case 'Irregular Heartbeat': return Icons.timeline;
      case 'Swelling Legs': return Icons.directions_walk;
      case 'Fainting': return Icons.warning_amber;
      default: return Icons.medical_services;
    }
  }
}
