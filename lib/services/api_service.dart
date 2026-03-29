import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // ── BACKENDS ─────────────────────────────
  static const String mlBaseUrl = 'http://10.0.2.2:8000';

  // Change this when Node backend is ready
  static const String dbBaseUrl = 'http://10.0.2.2:5000';

  static final _headers = {'Content-Type': 'application/json'};

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

    print('[API] POST $url');
    print('[API] Payload: $payload');

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );

    print('[API] Status: ${res.statusCode}');
    print('[API] Response: ${res.body}');

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(data['error'] ?? 'Prediction failed');
  }

  // ─────────────────────────────────────────
  // SYMPTOM LOGS (NODE BACKEND EXPECTED)
  // ─────────────────────────────────────────

  static Future<void> saveSymptomLog(SymptomLog log) async {
    final url = Uri.parse('$dbBaseUrl/logs');

    final body = log.toMap();

    print('[API] SAVE LOG -> $url');
    print('[API] LOG DATA: $body');

    try {
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      print('[API] LOG STATUS: ${res.statusCode}');
      print('[API] LOG RESPONSE: ${res.body}');
    } catch (e) {
      print('[API ERROR] saveSymptomLog failed: $e');
    }
  }

  // ─────────────────────────────────────────
  // OPTIONAL: READ LOGS
  // ─────────────────────────────────────────

  static Future<List<SymptomLog>> getUserLogs({
    required String uid,
    String? period,
  }) async {
    final query = 'uid=$uid${period != null ? '&period=$period' : ''}';
    final url = Uri.parse('$dbBaseUrl/logs?$query');

    print('[API] GET $url');

    try {
      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data']['logs'] as List)
            .map((l) => SymptomLog.fromMap(l))
            .toList();
      }
    } catch (e) {
      print('[API ERROR] getUserLogs failed: $e');
    }

    return [];
  }

  // ─────────────────────────────────────────
  // STUB: EVERYTHING BELOW DEPENDS ON NODE
  // KEEP FOR FUTURE BUT SAFE
  // ─────────────────────────────────────────

  static Future<List<LifestyleTip>> getTips({
    required String category,
    List<String>? relatedSymptoms,
    int limit = 5,
  }) async {
    final url = Uri.parse('$dbBaseUrl/tips');

    print('[API] GET $url');

    return [];
  }

  static Future<List<Clinic>> getClinicsForTests(List<String> tests) async {
    final url = Uri.parse('$dbBaseUrl/clinics');
    print('[API] GET $url');
    return [];
  }

  static Future<List<ReminderModel>> getReminders(String uid) async {
    final url = Uri.parse('$dbBaseUrl/reminders');
    print('[API] GET $url');
    return [];
  }

  static Future<UserModel?> getUser(String uid) async {
    final url = Uri.parse('$dbBaseUrl/users/$uid');
    print('[API] GET $url');
    return null;
  }
}
