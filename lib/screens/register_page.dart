import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'main_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedGender;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/onboarding2.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _input(nameController, "Full Name"),
                  _input(ageController, "Age", isNumber: true),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    dropdownColor: Colors.black,
                    hint: const Text("Gender"),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                      DropdownMenuItem(value: "Other", child: Text("Other")),
                    ],
                    onChanged: (val) => setState(() => selectedGender = val),
                  ),

                  _input(emailController, "Email"),
                  _input(passwordController, "Password", isPassword: true),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text("Already have account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint,
      {bool isNumber = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender == null ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _show("Fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.register(
        name: nameController.text,
        age: ageController.text,
        gender: selectedGender!,
        email: emailController.text,
        password: passwordController.text,
      );

      if (res['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        _show(res['error'] ?? "Registration failed");
      }
    } catch (e) {
      _show("Server error");
    }

    setState(() => isLoading = false);
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
