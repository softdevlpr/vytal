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
        uid: m['_id']?.toString() ?? m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        age: m['age'],
        gender: m['gender'],
        avatarUrl: m['avatar_url'],
        symptomScores: Map<String, int>.from(m['symptom_scores'] ?? {}),
        preferredCategories:
            List<String>.from(m['preferred_categories'] ?? []),
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

  UserModel copyWith({
    String? name,
    int? age,
    String? gender,
    String? avatarUrl,
  }) =>
      UserModel(
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

  factory LifestyleTip.fromMap(Map<String, dynamic> m) {
    return LifestyleTip(
      id: m['_id']?.toString() ?? '',
      category: m['category'] ?? '',

      title: m['title'] ?? 'Health Tip',
      body: m['text'] ?? '',

      
      relatedSymptoms: List<String>.from(m['symptoms'] ?? []),

     
      icon: m['icon'] ?? 'lightbulb',
      tags: List<String>.from(m['tags'] ?? []),
    );
  }
}

// ─────────────────────────────────────────────

class RecommendedTest {
  final int rank;
  final String name;
  final String description;

  RecommendedTest({
    required this.rank,
    required this.name,
    required this.description,
  });

  factory RecommendedTest.fromMap(Map<String, dynamic> m) =>
      RecommendedTest(
        rank: m['rank'] ?? 0,
        name: m['name'] ?? '',
        description: m['description'] ?? '',
      );

  Map<String, dynamic> toMap() =>
      {'rank': rank, 'name': name, 'description': description};
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
        loggedAt:
            DateTime.tryParse(m['logged_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'primary_symptom': primarySymptom,
        'answers': answers,
        'urgency': urgency,
        'recommended_tests':
            recommendedTests.map((t) => t.toMap()).toList(),
        'severity_score': severityScore,
        'logged_at': loggedAt.toIso8601String(),
      };
}

// ─────────────────────────────────────────────

class Clinic {
  final String name;
  final String address;
  final String phone;
  final List<String> testsAvailable;

  Clinic({
    required this.name,
    required this.address,
    required this.phone,
    required this.testsAvailable,
  });

  factory Clinic.fromMap(Map<String, dynamic> m) => Clinic(
        name: m['name'] ?? '',
        address: m['address'] ?? '',
        phone: m['phone_number'] ?? '',
        testsAvailable: List<String>.from(m['tests_available'] ?? []),
      );
}
