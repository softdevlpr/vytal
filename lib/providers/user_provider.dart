// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String _uid = ''; // ✅ store UID locally in provider

  UserModel? get user => _user;
  bool get loading => _loading;
  String get name => _user?.name ?? '';
  String get uid => _uid;

  /// Call this once after login/signup to hydrate the provider
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUid = prefs.getString('uid') ?? '';

    if (storedUid.isEmpty) return;

    _uid = storedUid;
    _loading = true;
    notifyListeners();

    _user = await ApiService.getUser(_uid);

    _loading = false;
    notifyListeners();
  }

  Future<void> updateUser(UserModel updated) async {
    await ApiService.updateUser(updated);
    _user = updated;
    notifyListeners();
  }

  /// Increment symptom score locally and persist
  Future<void> incrementSymptomScore(String symptom) async {
    if (_user == null) return;

    final scores = Map<String, int>.from(_user!.symptomScores);
    scores[symptom] = (scores[symptom] ?? 0) + 1;

    _user = UserModel(
      uid: _user!.uid,
      name: _user!.name,
      email: _user!.email,
      age: _user!.age,
      gender: _user!.gender,
      avatarUrl: _user!.avatarUrl,
      symptomScores: scores,
      preferredCategories: _user!.preferredCategories,
    );

    notifyListeners();
    // Backend updates via logs API
  }

  /// Returns user's top N symptoms by log count
  List<String> topSymptoms({int n = 3}) {
    if (_user == null) return [];

    final sorted = _user!.symptomScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(n).map((e) => e.key).toList();
  }

  /// Clear user (used on logout)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');

    _user = null;
    _uid = '';
    notifyListeners();
  }
}
