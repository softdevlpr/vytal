// lib/pages/test_result_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_constants.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TestResultPage extends StatefulWidget {
  final SymptomLog log;
  const TestResultPage({super.key, required this.log});

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  List<LifestyleTip> _tips = [];
  List<Clinic> _clinics = [];
  bool _loadingTips = true;
  bool _loadingClinics = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
    _loadClinics();
  }

  Future<void> _loadTips() async {
    final tips =
        await ApiService.getTips(uid: widget.log.uid);
    setState(() {
      _tips = tips;
      _loadingTips = false;
    });
  }

  Future<void> _loadClinics() async {
    final testNames =
        widget.log.recommendedTests.map((t) => t.name).toList();
    final clinics = await ApiService.getClinicsForTests(testNames);
    setState(() {
      _clinics = clinics;
      _loadingClinics = false;
    });
  }

  Color get _urgencyColor => urgencyColor(widget.log.urgency);

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
        title: Text('Your Results',
            style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _urgencyBanner(),
            const SizedBox(height: 24),
            _sectionTitle('Recommended Tests'),
            const SizedBox(height: 12),
            ...widget.log.recommendedTests.map(_testCard),
            const SizedBox(height: 24),
            _sectionTitle('Lifestyle Tips for You'),
            const SizedBox(height: 12),
            _loadingTips
                ? _shimmer(80)
                : _tips.isEmpty
                    ? _emptyState('No tips available')
                    : Column(children: _tips.map(_tipCard).toList()),
            const SizedBox(height: 24),
            _sectionTitle('Where to Get Tested in Jaipur'),
            const SizedBox(height: 12),
            _loadingClinics
                ? _shimmer(120)
                : _clinics.isEmpty
                    ? _emptyState('No clinics found')
                    : Column(children: _clinics.map(_clinicCard).toList()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── URGENCY BANNER ──────────────────────────────────────────────────────────
  Widget _urgencyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _urgencyColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _urgencyColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _urgencyColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(widget.log.urgency,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.log.primarySymptom,
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            kUrgencyDefinitions[widget.log.urgency] ?? '',
            style: GoogleFonts.poppins(
                color: AppColors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── TEST CARD ───────────────────────────────────────────────────────────────
  Widget _testCard(RecommendedTest test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('${test.rank}',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name,
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(test.description,
                    style: GoogleFonts.poppins(
                        color: AppColors.white54, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TIP CARD ────────────────────────────────────────────────────────────────
  Widget _tipCard(LifestyleTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(tip.body,
                    style: GoogleFonts.poppins(
                        color: AppColors.white54, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CLINIC CARD ─────────────────────────────────────────────────────────────
  Widget _clinicCard(Clinic clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(clinic.name,
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(clinic.type,
                    style: GoogleFonts.poppins(
                        color: AppColors.primary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.white54, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(clinic.address,
                    style: GoogleFonts.poppins(
                        color: AppColors.white54, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.white54, size: 14),
              const SizedBox(width: 4),
              Text(clinic.openHours,
                  style: GoogleFonts.poppins(
                      color: AppColors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _call(clinic.phone),
                  icon: const Icon(Icons.call, size: 16),
                  label: Text('Call', style: GoogleFonts.poppins(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openMaps(clinic.mapsUrl),
                  icon: const Icon(Icons.directions, size: 16),
                  label: Text('Directions',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600));

  Widget _shimmer(double height) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
      );

  Widget _emptyState(String msg) => Center(
        child: Text(msg,
            style: GoogleFonts.poppins(
                color: AppColors.white54, fontSize: 13)),
      );
}
