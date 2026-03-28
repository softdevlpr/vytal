// lib/data/app_constants.dart

import 'package:flutter/material.dart';

class AppColors {
  static const background   = Color(0xFF0F011E);
  static const card         = Color(0xFF1E1E2C);
  static const primary      = Color(0xFF9D4EDD);
  static const primaryDeep  = Color(0xFF5A0EFF);
  static const white        = Colors.white;
  static const white54      = Colors.white54;
  static const white70      = Colors.white70;

  static const urgentRed    = Color(0xFFFF4D4D);
  static const soonAmber    = Color(0xFFFFB347);
  static const routineGreen = Color(0xFF4CAF50);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [Color(0xFF9D4EDD), Color(0xFF5A0EFF)],
  );
}

// All 12 symptoms from the dataset
const List<String> kSymptoms = [
  'Chest Pain',
  'Shortness of Breath',
  'Dizziness',
  'High BP',
  'Sweating',
  'Nausea',
  'Fatigue',
  'Arm Pain',
  'Jaw Pain',
  'Irregular Heartbeat',
  'Swelling Legs',
  'Fainting',
];

const List<String> kLifestyleCategories = [
  'Healthy Lifestyle',
  'Weight Management',
  'Fitness & Strength',
  'Wellness Support',
  'Energy and Productivity',
];

// Icons per category
const Map<String, IconData> kCategoryIcons = {
  'Healthy Lifestyle':        Icons.favorite,
  'Weight Management':        Icons.monitor_weight,
  'Fitness & Strength':       Icons.fitness_center,
  'Wellness Support':         Icons.self_improvement,
  'Energy and Productivity':  Icons.bolt,
};

// Urgency colors
Color urgencyColor(String urgency) {
  switch (urgency) {
    case 'Urgent':  return AppColors.urgentRed;
    case 'Soon':    return AppColors.soonAmber;
    default:        return AppColors.routineGreen;
  }
}

// Urgency formal descriptions
const Map<String, String> kUrgencyDefinitions = {
  'Urgent':  'This symptom pattern indicates a potentially life-threatening cardiac event. Please seek emergency care or visit a hospital today without delay.',
  'Soon':    'This pattern suggests a significant condition. Please schedule an appointment with a physician within 24 to 72 hours.',
  'Routine': 'No acute emergency is indicated at this time. Please consult a general physician at your earliest convenience.',
};

// Questions per symptom (Q1-Q6 text and type)
const Map<String, List<Map<String, dynamic>>> kSymptomQuestions = {
  'Chest Pain': [
    {'id': 'Q1', 'text': 'Do you feel the pain spreading to your arm, jaw, or back?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is the chest pain?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel the pain even when you are resting?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Has the pain lasted for more than 20 minutes continuously?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do you feel sweating or nausea along with the chest pain?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Does the pain feel like pressure or squeezing rather than a sharp stab?', 'type': 'yn'},
  ],
  'Shortness of Breath': [
    {'id': 'Q1', 'text': 'Do you feel more breathless when you lie flat on your back?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is your breathlessness?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel short of breath even while sitting or resting?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Have you been feeling this way for more than 3 days?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do you feel any wheezing or coughing along with the breathlessness?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Do you notice any swelling in your legs or ankles?', 'type': 'yn'},
  ],
  'Dizziness': [
    {'id': 'Q1', 'text': 'Do you feel like the room is spinning around you?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is your dizziness?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel dizzy mainly when you stand up quickly?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Does each dizzy episode last more than 30 minutes?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do you feel a headache along with the dizziness?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Do you experience dizziness more than 3 times a week?', 'type': 'yn'},
  ],
  'High BP': [
    {'id': 'Q1', 'text': 'Do you feel a throbbing headache when your BP is high?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe does your high BP feel?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Has your blood pressure been elevated for more than a week?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Do you experience any blurring of vision with high BP?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do any of your close family members have heart disease?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Do you feel chest tightness or pain when your BP rises?', 'type': 'yn'},
  ],
  'Sweating': [
    {'id': 'Q1', 'text': 'Do you sweat excessively at night even without physical activity?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is the sweating?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel your heart racing or fluttering along with sweating?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Do you feel chest pain at the same time as sweating?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Have you been sweating like this for more than a week?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Does the sweating seem to happen when you feel anxious or stressed?', 'type': 'yn'},
  ],
  'Nausea': [
    {'id': 'Q1', 'text': 'Do you feel nausea along with any chest pain or discomfort?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is the nausea?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel nauseous after physical exertion or walking?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Have you been feeling nauseous for more than 2 days?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do you feel sweating or dizziness along with the nausea?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Do you feel more nauseous in the morning than at other times?', 'type': 'yn'},
  ],
  'Fatigue': [
    {'id': 'Q1', 'text': 'Do you still feel tired even after a full night of sleep?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is your fatigue?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel breathless or short of breath along with fatigue?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Have you been feeling fatigued like this for more than 2 weeks?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do you feel your heart pounding or skipping beats with fatigue?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Does your fatigue get noticeably worse when you are physically active?', 'type': 'yn'},
  ],
  'Arm Pain': [
    {'id': 'Q1', 'text': 'Do you feel the arm pain seems to start from your chest?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is the arm pain?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Is the pain specifically in your left arm?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Do you feel chest tightness along with the arm pain?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Does the arm pain appear or worsen during physical activity?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Has the arm pain lasted more than 15 minutes at a stretch?', 'type': 'yn'},
  ],
  'Jaw Pain': [
    {'id': 'Q1', 'text': 'Do you feel the jaw pain radiating from your chest or left arm?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is the jaw pain?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Does the jaw pain get worse when you physically exert yourself?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Do you feel sweating along with the jaw pain?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Did the jaw pain come on suddenly without any clear reason?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Has the jaw pain lasted for more than 10 minutes?', 'type': 'yn'},
  ],
  'Irregular Heartbeat': [
    {'id': 'Q1', 'text': 'Do you feel your heart skipping, fluttering, or beating unevenly?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe does the irregular heartbeat feel?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Do you feel dizzy or faint during an irregular heartbeat episode?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Do these episodes last more than 5 minutes?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Do you experience this more than 3 times a week?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Do you feel chest pain during an irregular heartbeat episode?', 'type': 'yn'},
  ],
  'Swelling Legs': [
    {'id': 'Q1', 'text': 'Do you notice swelling in both legs at the same time?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe is the swelling?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Does the swelling get worse towards the end of the day?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Do you feel breathless or short of breath along with the leg swelling?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Have your legs been swollen like this for more than a week?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Does the swollen area feel red, warm, or tender to touch?', 'type': 'yn'},
  ],
  'Fainting': [
    {'id': 'Q1', 'text': 'Did you completely lose consciousness when you fainted?', 'type': 'yn'},
    {'id': 'Q2', 'text': 'How severe was the fainting episode?', 'type': 'scale'},
    {'id': 'Q3', 'text': 'Did you feel chest pain or a racing heart just before fainting?', 'type': 'yn'},
    {'id': 'Q4', 'text': 'Have you fainted more than twice in the past month?', 'type': 'yn'},
    {'id': 'Q5', 'text': 'Did the fainting happen during or right after physical activity?', 'type': 'yn'},
    {'id': 'Q6', 'text': 'Did you recover and feel normal again within one minute?', 'type': 'yn'},
  ],
};
