// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;

  UserModel? get user    => _user;
  bool       get loading => _loading;
  String     get name    => _user?.name ?? '';
  String     get uid     => AuthService.uid;

  /// Call this once after login/signup to hydrate the provider
  Future<void> loadUser() async {
    final uid = AuthService.uid;
    if (uid.isEmpty) return;
    _loading = true;
    notifyListeners();

    _user = await ApiService.getUser(uid);
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
      uid:                  _user!.uid,
      name:                 _user!.name,
      email:                _user!.email,
      age:                  _user!.age,
      gender:               _user!.gender,
      avatarUrl:            _user!.avatarUrl,
      symptomScores:        scores,
      preferredCategories:  _user!.preferredCategories,
    );
    notifyListeners();
    // Backend also updates via /logs POST — no extra call needed
  }

  /// Returns user's top N symptoms by log count
  List<String> topSymptoms({int n = 3}) {
    if (_user == null) return [];
    final sorted = _user!.symptomScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).map((e) => e.key).toList();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
