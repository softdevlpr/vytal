import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class TipsPage extends StatefulWidget {
  final String category;

  const TipsPage({super.key, required this.category});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List tips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTips();
  }

  Future<void> fetchTips() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/tips?category=${widget.category}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          tips = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.category.replaceAll("_", " ").toUpperCase()),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tips.length,
              itemBuilder: (_, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tips[index]["text"],
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                );
              },
            ),
    );
  }
}
