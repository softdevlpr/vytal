// lib/pages/profile_settings_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_constants.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  UserModel? _user;
  bool _loading = true;
  bool _editMode = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ✅ LOAD USER WITHOUT FIREBASE
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid') ?? '';

    if (uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final user = await ApiService.getUser(uid);

    setState(() {
      _user = user;
      _loading = false;

      if (user != null) {
        _nameController.text = user.name;
        _ageController.text = user.age?.toString() ?? '';
        _selectedGender = user.gender;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    final updated = _user!.copyWith(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      gender: _selectedGender,
    );

    await ApiService.updateUser(updated);

    setState(() {
      _user = updated;
      _editMode = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.routineGreen,
      ));
    }
  }

  // ✅ LOGOUT WITHOUT FIREBASE
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');

    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  // ✅ DELETE ACCOUNT WITHOUT FIREBASE
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Account',
            style: GoogleFonts.poppins(color: AppColors.white)),
        content: Text(
            'This will permanently delete your account and all health data. This cannot be undone.',
            style: GoogleFonts.poppins(
                color: AppColors.white54, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgentRed),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid') ?? '';

    if (uid.isNotEmpty) {
      await ApiService.deleteUser(uid);
      await prefs.remove('uid');
    }

    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (_) => false);
    }
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
        title: Text('Profile & Settings',
            style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _editMode = !_editMode),
            child: Text(
              _editMode ? 'Cancel' : 'Edit',
              style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _avatar(),
                  const SizedBox(height: 28),
                  _profileCard(),
                  const SizedBox(height: 24),
                  if (_editMode) _saveButton(),
                  if (!_editMode) ...[
                    _settingTile(
                      icon: Icons.logout,
                      label: 'Log Out',
                      color: AppColors.soonAmber,
                      onTap: _logout,
                    ),
                    const SizedBox(height: 12),
                    _settingTile(
                      icon: Icons.delete_forever,
                      label: 'Delete Account',
                      color: AppColors.urgentRed,
                      onTap: _deleteAccount,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // 👇 Rest UI code unchanged (avatar, profile card, etc.)

  Widget _avatar() {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary,
          child: Text(
            _user?.name.isNotEmpty == true
                ? _user!.name[0].toUpperCase()
                : '?',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        Text(_user?.name ?? '',
            style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
        Text(_user?.email ?? '',
            style: GoogleFonts.poppins(
                color: AppColors.white54, fontSize: 13)),
      ],
    );
  }

  // (remaining UI unchanged)
}
