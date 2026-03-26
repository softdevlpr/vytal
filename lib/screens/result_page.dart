import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            buildSection("Primary Tests", result['primary_tests'] ?? []),
            buildSection("Secondary Tests", result['secondary_tests'] ?? []),
            buildSection("Optional Tests", result['optional_tests'] ?? []),
          ],
        ),
      ),
    );
  }

  /// ✅ Safe + Null-proof section builder
  Widget buildSection(String title, List<dynamic> tests) {
    if (tests.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        ...tests.map((test) {
          final testName = test['test'] ?? 'Unknown';
          final description = test['description'] ?? 'No description';
          final probability = test['probability'] ?? 0;

          return Card(
            color: const Color(0xFF1E1E2C),
            child: ListTile(
              title: Text(
                testName,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                description,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                "$probability%",
                style: const TextStyle(color: Colors.greenAccent),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
