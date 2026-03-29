import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiService {
  static const String mlBaseUrl = 'http://10.0.2.2:8000';
  static const String dbBaseUrl = 'http://10.0.2.2:3000';

  static const _headers = {'Content-Type': 'application/json'};

  // ─────────────────────────────
  // ML PREDICTION
  // ─────────────────────────────
  static Future<Map<String, dynamic>> predict({
    required String symptom,
    required Map<String, int> answers,
  }) async {
    final res = await http.post(
      Uri.parse('$mlBaseUrl/ml-predict'),
      headers: _headers,
      body: jsonEncode({
        'primary_symptom': symptom,
        'answers': answers,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(data['error'] ?? 'Prediction failed');
  }

  // ─────────────────────────────
  // USER
  // ─────────────────────────────
  static Future<UserModel?> getUser(String uid) async {
    final res = await http.get(Uri.parse('$dbBaseUrl/users/$uid'));
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return UserModel.fromMap(data['data']);
    }
    return null;
  }

  static Future<void> updateUser(UserModel user) async {
    await http.put(
      Uri.parse('$dbBaseUrl/users/${user.uid}'),
      headers: _headers,
      body: jsonEncode(user.toMap()),
    );
  }

  static Future<void> deleteUser(String uid) async {
    await http.delete(Uri.parse('$dbBaseUrl/users/$uid'));
  }

  // ─────────────────────────────
  // SYMPTOM LOGS
  // ─────────────────────────────
  static Future<void> saveSymptomLog(SymptomLog log) async {
    await http.post(
      Uri.parse('$dbBaseUrl/logs'),
      headers: _headers,
      body: jsonEncode(log.toMap()),
    );
  }

  static Future<List<SymptomLog>> getUserLogs({
    required String uid,
    String? period,
  }) async {
    final query = 'uid=$uid${period != null ? '&period=$period' : ''}';

    final res = await http.get(Uri.parse('$dbBaseUrl/logs?$query'));
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data']['logs'] as List)
          .map((e) => SymptomLog.fromMap(e))
          .toList();
    }

    return [];
  }

  // ─────────────────────────────
  // INSIGHTS
  // ─────────────────────────────
  static Future<Map<String, dynamic>> getInsights({
    required String uid,
    required String period,
  }) async {
    final res = await http.get(
      Uri.parse('$dbBaseUrl/insights?uid=$uid&period=$period'),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    return {};
  }

  // ─────────────────────────────
  // TIPS (FIXED — supports category OR symptoms)
  // ─────────────────────────────
  static Future<List<LifestyleTip>> getTips({
    String? category,
    List<String>? symptoms,
  }) async {
    String query = '';

    if (category != null) {
      query = 'category=${Uri.encodeComponent(category)}';
    }

    if (symptoms != null && symptoms.isNotEmpty) {
      final symQuery =
          symptoms.map((s) => 'symptoms=${Uri.encodeComponent(s)}').join('&');

      query = query.isEmpty ? symQuery : '$query&$symQuery';
    }

    final res = await http.get(
      Uri.parse('$dbBaseUrl/tips?$query'),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List)
          .map((e) => LifestyleTip.fromMap(e))
          .toList();
    }

    return [];
  }

  // ─────────────────────────────
  // CLINICS (FIXED MODEL MAPPING)
  // ─────────────────────────────
  static Future<List<Clinic>> getClinicsForTests(
      List<String> tests) async {
    final query =
        tests.map((t) => 'tests=${Uri.encodeComponent(t)}').join('&');

    final res = await http.get(
      Uri.parse('$dbBaseUrl/clinics?$query'),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List)
          .map((e) => Clinic.fromMap(e))
          .toList();
    }

    return [];
  }
}
