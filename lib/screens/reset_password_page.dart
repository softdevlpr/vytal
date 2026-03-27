import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Reset for: ${widget.email}"),

            const SizedBox(height: 20),

            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(hintText: "New Password"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: confirmPass,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Confirm Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (newPass.text == confirmPass.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password Reset Successful")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                }
              },
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
