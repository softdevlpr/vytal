

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/app_constants.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String _period = 'week';
  Map<String, dynamic> _data = {};
  bool _loading = true;

  String _uid = '';

  @override
  void initState() {
    super.initState();

    // listen to auth state instead of one-time fetch
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          _uid = user.uid;
        });
        _load();
      } else {
        setState(() {
          _uid = '';
          _loading = false;
        });
        print("User not logged in");
      }
    });
  }

  Future<void> _load() async {
    if (_uid.isEmpty) return;

    setState(() => _loading = true);

    final data =
        await ApiService.getInsights(uid: _uid, period: _period);

    setState(() {
      _data = data;
      _loading = false;
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Insights',
            style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _periodSelector(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _data.isEmpty
                    ? _emptyState()
                    : _insightsContent(),
          ),
        ],
      ),
    );
  }

  // ── PERIOD SELECTOR ─────────────────────────────────────────────────────────
  Widget _periodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['week', 'month', 'year'].map((p) {
          final isSelected = _period == p;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _period = p);
                _load();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primary : null,
                  color: isSelected ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  p[0].toUpperCase() + p.substring(1),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.white54,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // باقي code unchanged...
