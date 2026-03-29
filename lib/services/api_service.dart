import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiService {
  static const String mlBaseUrl = 'http://10.0.2.2:8000';
  static const String dbBaseUrl = 'http://10.0.2.2:3000/api';

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
    try {
      final res = await http.get(Uri.parse('$dbBaseUrl/users/$uid'));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return UserModel.fromMap(data['data']);
      }
    } catch (e) {
      print('[ERROR] getUser: $e');
    }
    return null;
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await http.put(
        Uri.parse('$dbBaseUrl/users/${user.uid}'),
        headers: _headers,
        body: jsonEncode(user.toMap()),
      );
    } catch (e) {
      print('[ERROR] updateUser: $e');
    }
  }

  static Future<void> deleteUser(String uid) async {
    try {
      await http.delete(Uri.parse('$dbBaseUrl/users/$uid'));
    } catch (e) {
      print('[ERROR] deleteUser: $e');
    }
  }

  // ─────────────────────────────
  // SYMPTOM LOGS
  // ─────────────────────────────
  static Future<void> saveSymptomLog(SymptomLog log) async {
    try {
      await http.post(
        Uri.parse('$dbBaseUrl/logs'),
        headers: _headers,
        body: jsonEncode(log.toMap()),
      );
    } catch (e) {
      print('[ERROR] saveSymptomLog: $e');
    }
  }

  static Future<List<SymptomLog>> getUserLogs({
    required String uid,
    String? period,
  }) async {
    try {
      final query = 'uid=$uid${period != null ? '&period=$period' : ''}';

      final res = await http.get(Uri.parse('$dbBaseUrl/logs?$query'));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data']['logs'] as List)
            .map((e) => SymptomLog.fromMap(e))
            .toList();
      }
    } catch (e) {
      print('[ERROR] getUserLogs: $e');
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
    try {
      final res = await http.get(
        Uri.parse('$dbBaseUrl/insights?uid=$uid&period=$period'),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }
    } catch (e) {
      print('[ERROR] getInsights: $e');
    }

    return {};
  }

  // ─────────────────────────────
  // TIPS (MULTI SUPPORT + LIMIT ✅)
  // ─────────────────────────────
  static Future<List<LifestyleTip>> getTips({
    String? category,
    List<String>? symptoms,
    int limit = 5, // ✅ added
  }) async {
    try {
      String query = '';

      if (category != null) {
        query = 'category=${Uri.encodeComponent(category)}';
      }

      if (symptoms != null && symptoms.isNotEmpty) {
        final symQuery = symptoms
            .map((s) => 'symptoms=${Uri.encodeComponent(s)}')
            .join('&');

        query = query.isEmpty ? symQuery : '$query&$symQuery';
      }

      final res = await http.get(
        Uri.parse('$dbBaseUrl/tips?$query&limit=$limit'), // ✅ added
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((e) => LifestyleTip.fromMap(e))
            .toList();
      }
    } catch (e) {
      print('[ERROR] getTips: $e');
    }

    return [];
  }

  // ─────────────────────────────
  // TIPS (SINGLE SYMPTOM ✅ FIXED)
  // ─────────────────────────────
  static Future<List<LifestyleTip>> getTipsForSymptom(
      String symptom) async {
    try {
      final res = await http.get(
        Uri.parse(
          '$dbBaseUrl/tips/for-symptom?symptom=${Uri.encodeComponent(symptom)}&limit=3',
        ),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((e) => LifestyleTip.fromMap(e))
            .toList();
      }
    } catch (e) {
      print('[ERROR] getTipsForSymptom: $e');
    }

    return [];
  }

  // ─────────────────────────────
  // CLINICS (MODEL FIX ✅)
  // ─────────────────────────────
  static Future<List<Clinic>> getClinicsForTests(
      List<String> tests) async {
    try {
      final query =
          tests.map((t) => 'tests=${Uri.encodeComponent(t)}').join('&');

      final res = await http.get(
        Uri.parse('$dbBaseUrl/clinics?$query'),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((e) => Clinic.fromMap(e)) // ✅ FIXED
            .toList();
      }
    } catch (e) {
      print('[ERROR] getClinicsForTests: $e');
    }

    return [];
  }
}
