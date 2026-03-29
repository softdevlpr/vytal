import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String mlBaseUrl = 'http://10.0.2.2:8000';
  static const String dbBaseUrl = 'http://10.0.2.2:3000';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ─────────────────────────────────────────
  // ML PREDICTION
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> predict({
    required String symptom,
    required Map<String, int> answers,
  }) async {
    final url = Uri.parse('$mlBaseUrl/ml-predict');

    final payload = {
      'primary_symptom': symptom,
      'answers': answers,
    };

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(data['error'] ?? 'Prediction failed');
  }

  // ─────────────────────────────────────────
  // USER API
  // ─────────────────────────────────────────
  static Future<UserModel?> getUser(String uid) async {
    try {
      final res = await http.get(
        Uri.parse('$dbBaseUrl/users/$uid'),
      );

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
      final res = await http.put(
        Uri.parse('$dbBaseUrl/users/${user.uid}'),
        headers: _headers,
        body: jsonEncode(user.toMap()),
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print('[ERROR] updateUser: $e');
    }
  }

  static Future<void> deleteUser(String uid) async {
    try {
      final res = await http.delete(
        Uri.parse('$dbBaseUrl/users/$uid'),
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      print('[ERROR] deleteUser: $e');
    }
  }

  // ─────────────────────────────────────────
  // SYMPTOM LOGS
  // ─────────────────────────────────────────
  static Future<void> saveSymptomLog(SymptomLog log) async {
    try {
      final res = await http.post(
        Uri.parse('$dbBaseUrl/logs'),
        headers: _headers,
        body: jsonEncode(log.toMap()),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to save log');
      }
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
      final res = await http.get(
        Uri.parse('$dbBaseUrl/logs?$query'),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data']['logs'] as List)
            .map((l) => SymptomLog.fromMap(l))
            .toList();
      }
    } catch (e) {
      print('[ERROR] getUserLogs: $e');
    }

    return [];
  }

  // ─────────────────────────────────────────
  // INSIGHTS
  // ─────────────────────────────────────────
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

  // ─────────────────────────────────────────
  // TIPS 
  // ─────────────────────────────────────────
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
            .map((t) => LifestyleTip.fromMap(t))
            .toList();
      }
    } catch (e) {
      print('[ERROR] getTipsForSymptom: $e');
    }

    return [];
  }
}
