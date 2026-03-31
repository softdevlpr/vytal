// lib/pages/plan_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_constants.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<LifestyleTip>> _tipsByCategory = {};
  final Map<String, bool> _loading = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: kLifestyleCategories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
        _loadCategory(kLifestyleCategories[_tabController.index]);
      }
    });
    _loadCategory(kLifestyleCategories[0]);
  }

  Future<void> _loadCategory(String category) async {
    if (_tipsByCategory.containsKey(category)) return;
    setState(() => _loading[category] = true);
    print(ApiService.getTips);
    final tips = await ApiService.getTips(
      category: category,
      // Pass user's top symptoms for personalization
      // relatedSymptoms: userTopSymptoms,
      limit: 8,
    );
    setState(() {
      _tipsByCategory[category] = tips;
      _loading[category] = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          onPressed: () => {
            Navigator.pop(context);
          },
        ),
        title: Text('Daily Tips',
            style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Category tabs (horizontal scroll)
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kLifestyleCategories.length,
              itemBuilder: (_, i) {
                final cat = kLifestyleCategories[i];
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () {
                    _tabController.animateTo(i);
                    setState(() => _selectedIndex = i);
                    _loadCategory(cat);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppGradients.primary
                          : null,
                      color: isSelected ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Icon(kCategoryIcons[cat],
                            color: isSelected
                                ? AppColors.white
                                : AppColors.white54,
                            size: 16),
                        const SizedBox(width: 6),
                        Text(cat,
                            style: GoogleFonts.poppins(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.white54,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Tips list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: kLifestyleCategories.map((cat) {
                final isLoading = _loading[cat] ?? false;
                final tips = _tipsByCategory[cat] ?? [];
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tips.length,
                  itemBuilder: (_, i) => _tipCard(tips[i], i),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(LifestyleTip tip, int index) {
    final colors = [
      const Color(0xFF9D4EDD),
      const Color(0xFF3A86FF),
      const Color(0xFF06D6A0),
      const Color(0xFFFFB703),
      const Color(0xFFEF476F),
    ];
    final accent = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFromString(tip.icon), color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(tip.title,
                      style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(tip.body,
                style: GoogleFonts.poppins(
                    color: AppColors.white70,
                    fontSize: 13,
                    height: 1.6)),
            if (tip.relatedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: tip.relatedSymptoms
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: GoogleFonts.poppins(
                                  color: accent, fontSize: 10)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFromString(String name) {
    const map = {
      'water_drop':       Icons.water_drop,
      'eco':              Icons.eco,
      'no_food':          Icons.no_food,
      'smoke_free':       Icons.smoke_free,
      'no_drinks':        Icons.no_drinks,
      'restaurant':       Icons.restaurant,
      'monitor_heart':    Icons.monitor_heart,
      'directions_walk':  Icons.directions_walk,
      'assignment':       Icons.assignment,
      'bedtime':          Icons.bedtime,
      'apple':            Icons.apple,
      'trending_up':      Icons.trending_up,
      'self_improvement': Icons.self_improvement,
      'chair':            Icons.chair,
      'air':              Icons.air,
      'fitness_center':   Icons.fitness_center,
      'spa':              Icons.spa,
      'psychology':       Icons.psychology,
      'people':           Icons.people,
      'wb_sunny':         Icons.wb_sunny,
      'timer':            Icons.timer,
      'restaurant_menu':  Icons.restaurant_menu,
      'free_breakfast':   Icons.free_breakfast,
      'alarm':            Icons.alarm,
    };
    return map[name] ?? Icons.lightbulb_outline;
  }
}
