import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String mlBaseUrl = 'http://10.0.2.2:8000';
  static const String dbBaseUrl = 'http://10.0.2.2:5000';

  static const _headers = {'Content-Type': 'application/json'};

  // ─────────────────────────────────────────
  // ML PREDICTION (WORKING)
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

    print('[ML] POST $url');
    print('[ML] Payload: $payload');

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );

    print('[ML] Status: ${res.statusCode}');
    print('[ML] Body: ${res.body}');

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(data['error'] ?? 'Prediction failed');
  }

  // ─────────────────────────────────────────
  // SYMPTOM LOGS (NODE BACKEND)
  // ─────────────────────────────────────────

  static Future<void> saveSymptomLog(SymptomLog log) async {
    try {
      final url = Uri.parse('$dbBaseUrl/logs');

      print('[DB] saveSymptomLog -> $url');
      print('[DB] data -> ${log.toMap()}');

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(log.toMap()),
      );

      print('[DB] status: ${res.statusCode}');
      print('[DB] body: ${res.body}');
    } catch (e) {
      print('[DB ERROR] saveSymptomLog: $e');
    }
  }

  // ─────────────────────────────────────────
  // USER API (RESTORED FOR UI COMPILATION)
  // ─────────────────────────────────────────

  static Future<UserModel?> getUser(String uid) async {
    try {
      final res = await http.get(Uri.parse('$dbBaseUrl/users/$uid'));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return UserModel.fromMap(data['data']);
      }
    } catch (e) {
      print('[DB ERROR] getUser: $e');
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

      print('[DB] updateUser status: ${res.statusCode}');
      print('[DB] updateUser body: ${res.body}');
    } catch (e) {
      print('[DB ERROR] updateUser: $e');
    }
  }

  static Future<void> deleteUser(String uid) async {
    try {
      final res = await http.delete(
        Uri.parse('$dbBaseUrl/users/$uid'),
      );

      print('[DB] deleteUser status: ${res.statusCode}');
    } catch (e) {
      print('[DB ERROR] deleteUser: $e');
    }
  }

  // ─────────────────────────────────────────
  // INSIGHTS (RESTORED)
  // ─────────────────────────────────────────

  static Future<Map<String, dynamic>> getInsights({
    required String uid,
    required String period,
  }) async {
    try {
      final url = Uri.parse('$dbBaseUrl/insights?uid=$uid&period=$period');

      print('[DB] getInsights -> $url');

      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }
    } catch (e) {
      print('[DB ERROR] getInsights: $e');
    }

    return {};
  }

  // ─────────────────────────────────────────
  // TIPS (RESTORED)
  // ─────────────────────────────────────────

  static Future<List<LifestyleTip>> getTipsForSymptom(String symptom) async {
    try {
      final url = Uri.parse(
          '$dbBaseUrl/tips/for-symptom?symptom=${Uri.encodeComponent(symptom)}&limit=3');

      print('[DB] getTipsForSymptom -> $url');

      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((t) => LifestyleTip.fromMap(t))
            .toList();
      }
    } catch (e) {
      print('[DB ERROR] getTipsForSymptom: $e');
    }

    return [];
  }

  // ─────────────────────────────────────────
  // OPTIONAL FALLBACK METHODS
  // ─────────────────────────────────────────

  static Future<List<SymptomLog>> getUserLogs({
    required String uid,
    String? period,
  }) async {
    try {
      final query = 'uid=$uid${period != null ? '&period=$period' : ''}';
      final url = Uri.parse('$dbBaseUrl/logs?$query');

      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data']['logs'] as List)
            .map((l) => SymptomLog.fromMap(l))
            .toList();
      }
    } catch (e) {
      print('[DB ERROR] getUserLogs: $e');
    }

    return [];
  }
}
