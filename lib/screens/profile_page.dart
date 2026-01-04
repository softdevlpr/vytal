import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController(text: "Shambhavi Sinha");
  final _emailController = TextEditingController(text: "shambhavi@email.com");
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F011E),
        elevation: 0,
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// PROFILE AVATAR
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF9D4EDD),
              child: Icon(Icons.person, size: 45, color: Colors.white),
            ),

            const SizedBox(height: 12),

            const Text(
              "Shambhavi Sinha",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            /// PERSONAL INFO
            _sectionTitle("Personal Information"),
            _inputField("Full Name", _nameController),
            _inputField("Email", _emailController),

            const SizedBox(height: 20),

            /// CHANGE PASSWORD
            _sectionTitle("Change Password"),
            _inputField(
              "Current Password",
              _oldPasswordController,
              isPassword: true,
            ),
            _inputField(
              "New Password",
              _newPasswordController,
              isPassword: true,
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
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
                onPressed: _saveProfile,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// LOGOUT
            TextButton(
              onPressed: _logout,
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
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

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// SAVE PROFILE
  void _saveProfile() {
    // TODO: connect to backend / Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  /// LOGOUT
  void _logout() {
    Navigator.pop(context);
  }
}
