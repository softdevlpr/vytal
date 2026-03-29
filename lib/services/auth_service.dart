// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import '../models/models.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static String get uid => _auth.currentUser?.uid ?? '';

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── SIGN UP ──────────────────────────────────────────────────────────────────
  static Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update Firebase display name
    await cred.user?.updateDisplayName(name);

    // Create MongoDB user record
    await ApiService.createUser(UserModel(
      uid:    cred.user!.uid,
      name:   name,
      email:  email,
      age:    age,
      gender: gender,
    ));

    return cred;
  }

  // ── SIGN IN ──────────────────────────────────────────────────────────────────
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── SIGN OUT ─────────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── RESET PASSWORD ────────────────────────────────────────────────────────────
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
