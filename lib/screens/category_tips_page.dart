import 'package:flutter/material.dart';

class CategoryTipsPage extends StatelessWidget {
  final String category;
  final List<dynamic> tips;

  const CategoryTipsPage({
    super.key,
    required this.category,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        elevation: 0,
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final cleanTips = tips.where((tip) {
      if (tip == null) return false;

      if (tip is String) {
        return tip.trim().isNotEmpty;
      }

      if (tip is Map && tip["tip_text"] != null) {
        return tip["tip_text"].toString().trim().isNotEmpty;
      }

      return tip.toString().trim().isNotEmpty;
    }).toList();

    if (cleanTips.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.white54, size: 50),
            SizedBox(height: 10),
            Text(
              "No tips available",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cleanTips.length,
      itemBuilder: (_, index) {
        final tip = cleanTips[index];

        String tipText;

        if (tip is String) {
          tipText = tip;
        } else if (tip is Map && tip.containsKey("tip_text")) {
          tipText = tip["tip_text"] ?? "";
        } else {
          tipText = tip.toString();
        }

        if (tipText.trim().isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E1E2C),
                Color(0xFF2A2A3D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    tipText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
