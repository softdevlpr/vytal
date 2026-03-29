import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // ─────────────────────────────────────────
  // BASE URLS
  // ─────────────────────────────────────────
  static const String mlBaseUrl = 'http://10.0.2.2:8000';
  static const String dbBaseUrl = 'http://10.0.2.2:3000';

  static const _headers = {'Content-Type': 'application/json'};

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  static void _log(String tag, dynamic message) {
    print('[$tag] $message');
  }

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      _log('JSON_ERROR', body);
      throw Exception('Invalid JSON response');
    }
  }

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

    _log('ML_REQUEST', payload);

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );

    _log('ML_STATUS', res.statusCode);
    _log('ML_RESPONSE', res.body);

    final data = _safeDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(data['error'] ?? 'Prediction failed');
  }

  // ─────────────────────────────────────────
  // USER APIs
  // ─────────────────────────────────────────
  static Future<UserModel?> getUser(String uid) async {
    try {
      final res = await http.get(Uri.parse('$dbBaseUrl/users/$uid'));

      _log('GET_USER', res.body);

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return UserModel.fromMap(data['data']);
      }
    } catch (e) {
      _log('ERROR_GET_USER', e);
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

      _log('UPDATE_USER', res.body);

      if (res.statusCode != 200) {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      _log('ERROR_UPDATE_USER', e);
    }
  }

  static Future<void> deleteUser(String uid) async {
    try {
      final res = await http.delete(
        Uri.parse('$dbBaseUrl/users/$uid'),
      );

      _log('DELETE_USER', res.body);

      if (res.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      _log('ERROR_DELETE_USER', e);
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

      _log('SAVE_LOG', res.body);

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to save log');
      }
    } catch (e) {
      _log('ERROR_SAVE_LOG', e);
    }
  }

  static Future<List<SymptomLog>> getUserLogs({
    required String uid,
    String? period,
  }) async {
    try {
      final query =
          'uid=$uid${period != null ? '&period=$period' : ''}';

      final res = await http.get(
        Uri.parse('$dbBaseUrl/logs?$query'),
      );

      _log('GET_LOGS', res.body);

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data']['logs'] as List)
            .map((l) => SymptomLog.fromMap(l))
            .toList();
      }
    } catch (e) {
      _log('ERROR_GET_LOGS', e);
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

      _log('GET_INSIGHTS', res.body);

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }
    } catch (e) {
      _log('ERROR_INSIGHTS', e);
    }

    return {};
  }

  // ─────────────────────────────────────────
  // TIPS (SINGLE SYMPTOM)
  // ─────────────────────────────────────────
  static Future<List<LifestyleTip>> getTipsForSymptom(
      String symptom) async {
    try {
      final url =
          '$dbBaseUrl/tips/for-symptom?symptom=${Uri.encodeComponent(symptom)}&limit=3';

      final res = await http.get(Uri.parse(url));

      _log('TIPS_SYMPTOM', res.body);

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((t) => LifestyleTip.fromMap(t))
            .toList();
      }
    } catch (e) {
      _log('ERROR_TIPS_SYMPTOM', e);
    }

    return [];
  }

  // ─────────────────────────────────────────
  // TIPS (MULTIPLE SYMPTOMS)
  // ─────────────────────────────────────────
  static Future<List<LifestyleTip>> getTips({
    required List<String> symptoms,
  }) async {
    try {
      final query = symptoms
          .map((s) => 'symptoms=${Uri.encodeComponent(s)}')
          .join('&');

      final res = await http.get(
        Uri.parse('$dbBaseUrl/tips?$query'),
      );

      _log('TIPS_MULTI', res.body);

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((t) => LifestyleTip.fromMap(t))
            .toList();
      }
    } catch (e) {
      _log('ERROR_TIPS_MULTI', e);
    }

    return [];
  }

  // ─────────────────────────────────────────
  // CLINICS
  // ─────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getClinicsForTests(
      List<String> tests) async {
    try {
      final query = tests
          .map((t) => 'tests=${Uri.encodeComponent(t)}')
          .join('&');

      final res = await http.get(
        Uri.parse('$dbBaseUrl/clinics?$query'),
      );

      _log('CLINICS', res.body);

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      _log('ERROR_CLINICS', e);
    }

    return [];
  }
}
