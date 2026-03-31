// lib/pages/insights_page.dart

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
  String _period = 'week'; // week / month / year
  Map<String, dynamic> _data = {};
  bool _loading = true;

  // ✅ CHANGED: dynamic UID
  String _uid = '';

  @override
  void initState() {
    super.initState();

    // ✅ CHANGED: get Firebase user UID
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _uid = user.uid;
      _load();
    } else {
      print("User not logged in");
      _loading = false;
    }
  }

  Future<void> _load() async {
    // ✅ ADDED: safety check
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

  // ── MAIN CONTENT ────────────────────────────────────────────────────────────
  Widget _insightsContent() {
    final totalLogs = _data['total_logs'] ?? 0;
    final topSymptom = _data['top_symptom'] ?? 'None';
    final urgencyBreakdown =
        Map<String, int>.from(_data['urgency_breakdown'] ?? {});
    final List<dynamic> chartPoints = _data['chart_points'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _summaryCard('Total Logs', '$totalLogs', Icons.bar_chart,
                  AppColors.primary),
              const SizedBox(width: 12),
              _summaryCard('Top Symptom', topSymptom,
                  Icons.favorite_border, AppColors.soonAmber),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _summaryCard('Urgent',
                  '${urgencyBreakdown['Urgent'] ?? 0}', Icons.warning,
                  AppColors.urgentRed),
              const SizedBox(width: 8),
              _summaryCard('Soon',
                  '${urgencyBreakdown['Soon'] ?? 0}', Icons.schedule,
                  AppColors.soonAmber),
              const SizedBox(width: 8),
              _summaryCard('Routine',
                  '${urgencyBreakdown['Routine'] ?? 0}', Icons.check_circle,
                  AppColors.routineGreen),
            ],
          ),

          const SizedBox(height: 24),

          if (chartPoints.isNotEmpty) ...[
            Text('Severity Trend',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white10, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}',
                            style: GoogleFonts.poppins(
                                color: AppColors.white54, fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= chartPoints.length) {
                            return const SizedBox();
                          }
                          return Text(
                              chartPoints[idx]['label']?.toString() ?? '',
                              style: GoogleFonts.poppins(
                                  color: AppColors.white54, fontSize: 9));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartPoints
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(),
                              (e.value['score'] ?? 0).toDouble()))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                                radius: 3,
                                color: AppColors.primary,
                                strokeWidth: 0,
                                strokeColor: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          if ((_data['symptom_frequency'] as Map?)?.isNotEmpty ?? false) ...[
            Text('Symptom Frequency',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...(_data['symptom_frequency'] as Map<String, dynamic>)
                .entries
                .toList()
                .take(6)
                .map((e) => _frequencyBar(e.key, e.value as int,
                    (_data['total_logs'] ?? 1) as int)),
          ],

          const SizedBox(height: 24),

          if (_data['improvement'] != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.routineGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.routineGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: AppColors.routineGreen, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_data['improvement'],
                        style: GoogleFonts.poppins(
                            color: AppColors.routineGreen,
                            fontSize: 13,
                            height: 1.5)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: GoogleFonts.poppins(
                    color: AppColors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _frequencyBar(String symptom, int count, int total) {
    final pct = total > 0 ? count / total : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(symptom,
                  style: GoogleFonts.poppins(
                      color: AppColors.white, fontSize: 12)),
              Text('$count times',
                  style: GoogleFonts.poppins(
                      color: AppColors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.card,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: AppColors.white54, size: 60),
            const SizedBox(height: 16),
            Text('No data yet',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Log your first symptom to see insights here.',
                style: GoogleFonts.poppins(
                    color: AppColors.white54, fontSize: 13)),
          ],
        ),
      );
}
