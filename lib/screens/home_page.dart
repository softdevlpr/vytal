import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('name') ?? '';

    setState(() {
      _firstName = fullName.isNotEmpty ? fullName.split(' ').first : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              const SizedBox(height: 20),
              _dailyAffirmation(),
              const SizedBox(height: 25),

              Text(
                "Your Actions",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              _navigationCard(
                title: "Track Symptoms",
                subtitle: "Log how you feel today",
                icon: Icons.favorite_border,
                isPrimary: true,
                onTap: () => widget.onNavigate(2),
              ),

              const SizedBox(height: 12),

              _navigationCard(
                title: "Insights",
                subtitle: "Understand your patterns",
                icon: Icons.bar_chart,
                onTap: () => widget.onNavigate(3),
              ),

              const SizedBox(height: 12),

              _navigationCard(
                title: "Daily Tips",
                subtitle: "Get relevant health tips",
                icon: Icons.calendar_today,
                onTap: () => widget.onNavigate(1),
              ),

              const SizedBox(height: 12),

              _navigationCard(
                title: "Profile",
                subtitle: "Manage your account",
                icon: Icons.person,
                onTap: () => widget.onNavigate(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF9D4EDD),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello${_firstName.isNotEmpty ? ', $_firstName' : ''} 👋",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "How are you feeling today?",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Icon(Icons.settings, color: Colors.white70),
      ],
    );
  }

  Widget _dailyAffirmation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9D4EDD),
            Color(0xFF5A0EFF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Affirmation 🌱",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "I choose to listen to my body and care for it with kindness today.",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [
                    Color(0xFF9D4EDD),
                    Color(0xFF5A0EFF),
                  ],
                )
              : null,
          color: isPrimary ? null : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
