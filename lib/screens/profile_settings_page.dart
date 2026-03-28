// lib/pages/profile_settings_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Account',
            style: GoogleFonts.poppins(color: AppColors.white)),
        content: Text(
            'This will permanently delete your account and all health data. This cannot be undone.',
            style: GoogleFonts.poppins(color: AppColors.white54, height: 1.5)),
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

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await ApiService.deleteUser(uid);
    await FirebaseAuth.instance.currentUser?.delete();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
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

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          _fieldRow('Name', _nameController, enabled: _editMode),
          const Divider(color: Colors.white10),
          _fieldRow('Age', _ageController,
              enabled: _editMode, keyboardType: TextInputType.number),
          const Divider(color: Colors.white10),
          _genderRow(),
        ],
      ),
    );
  }

  Widget _fieldRow(String label, TextEditingController ctrl,
      {bool enabled = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: AppColors.white54, fontSize: 13)),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              enabled: enabled,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                  color: AppColors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Not set',
                hintStyle: GoogleFonts.poppins(
                    color: Colors.white24, fontSize: 14),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('Gender',
                style: GoogleFonts.poppins(
                    color: AppColors.white54, fontSize: 13)),
          ),
          const Spacer(),
          if (!_editMode)
            Text(_selectedGender ?? 'Not set',
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontSize: 14))
          else
            DropdownButton<String>(
              value: _selectedGender,
              dropdownColor: AppColors.card,
              style: GoogleFonts.poppins(
                  color: AppColors.white, fontSize: 14),
              underline: const SizedBox(),
              hint: Text('Select',
                  style: GoogleFonts.poppins(
                      color: Colors.white24, fontSize: 14)),
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('Save Changes',
            style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }
}
