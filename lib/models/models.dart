// lib/models/models.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final String? avatarUrl;
  final Map<String, int> symptomScores;
  final List<String> preferredCategories;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.avatarUrl,
    this.symptomScores = const {},
    this.preferredCategories = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        age: m['age'],
        gender: m['gender'],
        avatarUrl: m['avatar_url'],
        symptomScores: Map<String, int>.from(m['symptom_scores'] ?? {}),
        preferredCategories: List<String>.from(m['preferred_categories'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
        'avatar_url': avatarUrl,
        'symptom_scores': symptomScores,
        'preferred_categories': preferredCategories,
      };

  UserModel copyWith({String? name, int? age, String? gender, String? avatarUrl}) => UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        symptomScores: symptomScores,
        preferredCategories: preferredCategories,
      );
}

// ─────────────────────────────────────────────
class RecommendedTest {
  final int rank;
  final String name;
  final String description;

  RecommendedTest({required this.rank, required this.name, required this.description});

  factory RecommendedTest.fromMap(Map<String, dynamic> m) => RecommendedTest(
        rank: m['rank'] ?? 0,
        name: m['name'] ?? '',
        description: m['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {'rank': rank, 'name': name, 'description': description};
}

// ─────────────────────────────────────────────
class SymptomLog {
  final String? id;
  final String uid;
  final String primarySymptom;
  final Map<String, int> answers;
  final String urgency;
  final List<RecommendedTest> recommendedTests;
  final int severityScore;
  final DateTime loggedAt;

  SymptomLog({
    this.id,
    required this.uid,
    required this.primarySymptom,
    required this.answers,
    required this.urgency,
    required this.recommendedTests,
    required this.severityScore,
    required this.loggedAt,
  });

  factory SymptomLog.fromMap(Map<String, dynamic> m) => SymptomLog(
        id: m['_id']?.toString(),
        uid: m['uid'] ?? '',
        primarySymptom: m['primary_symptom'] ?? '',
        answers: Map<String, int>.from(m['answers'] ?? {}),
        urgency: m['urgency'] ?? 'Routine',
        recommendedTests: (m['recommended_tests'] as List? ?? [])
            .map((t) => RecommendedTest.fromMap(t))
            .toList(),
        severityScore: m['severity_score'] ?? 0,
        loggedAt: DateTime.tryParse(m['logged_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'primary_symptom': primarySymptom,
        'answers': answers,
        'urgency': urgency,
        'recommended_tests': recommendedTests.map((t) => t.toMap()).toList(),
        'severity_score': severityScore,
        'logged_at': loggedAt.toIso8601String(),
        'week_number': _isoWeekNumber(loggedAt),
        'month': loggedAt.month,
        'year': loggedAt.year,
      };

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateTime(date.year, date.month, date.day)
            .difference(DateTime(date.year, 1, 1))
            .inDays
            .toString()) + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}

// ─────────────────────────────────────────────
class LifestyleTip {
  final String id;
  final String category;
  final String title;
  final String body;
  final List<String> relatedSymptoms;
  final String icon;
  final List<String> tags;

  LifestyleTip({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.relatedSymptoms,
    required this.icon,
    required this.tags,
  });

  factory LifestyleTip.fromMap(Map<String, dynamic> m) => LifestyleTip(
        id: m['_id']?.toString() ?? '',
        category: m['category'] ?? '',
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        relatedSymptoms: List<String>.from(m['related_symptoms'] ?? []),
        icon: m['icon'] ?? 'lightbulb',
        tags: List<String>.from(m['tags'] ?? []),
      );
}

// ─────────────────────────────────────────────
class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final List<String> testsAvailable;
  final String openHours;
  final String type;
  final String mapsUrl;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.testsAvailable,
    required this.openHours,
    required this.type,
    required this.mapsUrl,
  });

  factory Clinic.fromMap(Map<String, dynamic> m) => Clinic(
        id: m['_id']?.toString() ?? '',
        name: m['name'] ?? '',
        address: m['address'] ?? '',
        phone: m['phone'] ?? '',
        lat: (m['lat'] ?? 0).toDouble(),
        lng: (m['lng'] ?? 0).toDouble(),
        testsAvailable: List<String>.from(m['tests_available'] ?? []),
        openHours: m['open_hours'] ?? '',
        type: m['type'] ?? '',
        mapsUrl: m['maps_url'] ?? '',
      );
}

// ─────────────────────────────────────────────
class ReminderModel {
  final String? id;
  final String uid;
  final String title;
  final String time;          // "HH:mm"
  final String repeat;        // daily / weekly / none
  final List<int> daysOfWeek; // 1=Mon..7=Sun, only for weekly
  final bool isActive;

  ReminderModel({
    this.id,
    required this.uid,
    required this.title,
    required this.time,
    required this.repeat,
    this.daysOfWeek = const [],
    this.isActive = true,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> m) => ReminderModel(
        id: m['_id']?.toString(),
        uid: m['uid'] ?? '',
        title: m['title'] ?? '',
        time: m['time'] ?? '08:00',
        repeat: m['repeat'] ?? 'daily',
        daysOfWeek: List<int>.from(m['days_of_week'] ?? []),
        isActive: m['is_active'] ?? true,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'time': time,
        'repeat': repeat,
        'days_of_week': daysOfWeek,
        'is_active': isActive,
        'created_at': DateTime.now().toIso8601String(),
      };
}
