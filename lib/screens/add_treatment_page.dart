import 'package:flutter/material.dart';

class AddTreatmentPage extends StatelessWidget {
  const AddTreatmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        title: const Text("Add Treatment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _inputField("Treatment name"),
            _inputField("Duration"),
            _inputField("Notes"),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // TODO: Save treatment to backend
                  Navigator.pop(context);
                },
                child: const Text("Save Treatment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E1E2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
