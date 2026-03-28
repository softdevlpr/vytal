// lib/services/api_service.dart
// All HTTP calls to your Flask backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // deployed backend URL in production
  static const String baseUrl = 'http://10.0.2.2:8000';

  static final _headers = {'Content-Type': 'application/json'};

  // ── SYMPTOM PREDICTION ─────────────────────────────────────────────────────

  /// Sends user's answers to the ML model and returns prediction
  static Future<Map<String, dynamic>> predict({
    required String symptom,
    required Map<String, int> answers,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: _headers,
      body: jsonEncode({'primary_symptom': symptom, 'answers': answers}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['error'] ?? 'Prediction failed');
  }

  // ── SYMPTOM LOGS ───────────────────────────────────────────────────────────

  static Future<void> saveSymptomLog(SymptomLog log) async {
    await http.post(
      Uri.parse('$baseUrl/logs'),
      headers: _headers,
      body: jsonEncode(log.toMap()),
    );
  }

  static Future<List<SymptomLog>> getUserLogs({
    required String uid,
    String? period, // 'week' | 'month' | 'year'
  }) async {
    final query = 'uid=$uid${period != null ? '&period=$period' : ''}';
    final res = await http.get(Uri.parse('$baseUrl/logs?$query'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data']['logs'] as List)
          .map((l) => SymptomLog.fromMap(l))
          .toList();
    }
    return [];
  }

  // ── LIFESTYLE TIPS ─────────────────────────────────────────────────────────

  static Future<List<LifestyleTip>> getTips({
    required String category,
    List<String>? relatedSymptoms,
    int limit = 5,
  }) async {
    String query = 'category=${Uri.encodeComponent(category)}&limit=$limit';
    if (relatedSymptoms != null && relatedSymptoms.isNotEmpty) {
      query += '&symptoms=${relatedSymptoms.map(Uri.encodeComponent).join(',')}';
    }
    final res = await http.get(Uri.parse('$baseUrl/tips?$query'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((t) => LifestyleTip.fromMap(t)).toList();
    }
    return [];
  }

  // Tips specifically for a symptom (shown on result page)
  static Future<List<LifestyleTip>> getTipsForSymptom(String symptom) async {
    final res = await http.get(
        Uri.parse('$baseUrl/tips/for-symptom?symptom=${Uri.encodeComponent(symptom)}&limit=3'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((t) => LifestyleTip.fromMap(t)).toList();
    }
    return [];
  }

  // ── CLINICS ────────────────────────────────────────────────────────────────

  static Future<List<Clinic>> getClinicsForTests(List<String> tests) async {
    final encoded = tests.map(Uri.encodeComponent).join(',');
    final res = await http.get(Uri.parse('$baseUrl/clinics?tests=$encoded'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((c) => Clinic.fromMap(c)).toList();
    }
    return [];
  }

  // ── REMINDERS ──────────────────────────────────────────────────────────────

  static Future<List<ReminderModel>> getReminders(String uid) async {
    final res = await http.get(Uri.parse('$baseUrl/reminders?uid=$uid'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List).map((r) => ReminderModel.fromMap(r)).toList();
    }
    return [];
  }

  static Future<ReminderModel?> addReminder(ReminderModel reminder) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reminders'),
      headers: _headers,
      body: jsonEncode(reminder.toMap()),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return ReminderModel.fromMap(data['data']);
    }
    return null;
  }

  static Future<void> deleteReminder(String id) async {
    await http.delete(Uri.parse('$baseUrl/reminders/$id'));
  }

  static Future<void> toggleReminder(String id, bool isActive) async {
    await http.patch(
      Uri.parse('$baseUrl/reminders/$id'),
      headers: _headers,
      body: jsonEncode({'is_active': isActive}),
    );
  }

  // ── USER ───────────────────────────────────────────────────────────────────

  static Future<UserModel?> getUser(String uid) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$uid'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return UserModel.fromMap(data['data']);
    }
    return null;
  }

  static Future<void> createUser(UserModel user) async {
    await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers,
      body: jsonEncode(user.toMap()),
    );
  }

  static Future<void> updateUser(UserModel user) async {
    await http.put(
      Uri.parse('$baseUrl/users/${user.uid}'),
      headers: _headers,
      body: jsonEncode(user.toMap()),
    );
  }

  static Future<void> deleteUser(String uid) async {
    await http.delete(Uri.parse('$baseUrl/users/$uid'));
  }

  // ── INSIGHTS ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getInsights({
    required String uid,
    required String period, // week / month / year
  }) async {
    final res = await http.get(Uri.parse('$baseUrl/insights?uid=$uid&period=$period'));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    return {};
  }
}
