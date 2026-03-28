"""
backend/seed_data.py
--------------------
Seeds static collections: clinics_jaipur + lifestyle_tips
Run once: python backend/seed_data.py
"""
from pymongo import MongoClient
from datetime import datetime

client = MongoClient("mongodb://localhost:27017")
db = client["cardiac_app_db"]

# ── CLINICS IN JAIPUR ─────────────────────────────────────────────────────────
clinics = [
    {
        "name": "Fortis Escorts Hospital",
        "address": "Jawahar Lal Nehru Marg, Malviya Nagar, Jaipur 302017",
        "phone": "+91-141-254-7000",
        "lat": 26.8467, "lng": 75.8094,
        "tests_available": ["ECG", "Echocardiogram", "Troponin Blood Test", "Stress Test (TMT)", "Coronary Angiography", "CT Coronary Angiography", "Cardiac MRI"],
        "open_hours": "24x7", "type": "Hospital",
        "maps_url": "https://maps.google.com/?q=Fortis+Escorts+Hospital+Jaipur"
    },
    {
        "name": "Sawai Man Singh (SMS) Hospital",
        "address": "Sawai Ram Singh Rd, Gangauri Bazaar, Jaipur 302004",
        "phone": "+91-141-256-0291",
        "lat": 26.9124, "lng": 75.8069,
        "tests_available": ["ECG", "Chest X-Ray", "Complete Blood Count (CBC)", "Lipid Panel", "Echocardiogram", "BNP Test"],
        "open_hours": "24x7", "type": "Hospital",
        "maps_url": "https://maps.google.com/?q=SMS+Hospital+Jaipur"
    },
    {
        "name": "Narayana Multispeciality Hospital",
        "address": "Sector 28, Pratap Nagar, Jaipur 302033",
        "phone": "+91-141-477-3500",
        "lat": 26.7934, "lng": 75.8325,
        "tests_available": ["ECG", "Holter Monitor", "Stress Test (TMT)", "Echocardiogram", "Troponin Blood Test", "Coronary Angiography"],
        "open_hours": "24x7", "type": "Hospital",
        "maps_url": "https://maps.google.com/?q=Narayana+Hospital+Jaipur"
    },
    {
        "name": "Santokba Durlabhji Memorial Hospital",
        "address": "Bhawani Singh Rd, Rambagh, Jaipur 302004",
        "phone": "+91-141-256-6251",
        "lat": 26.8900, "lng": 75.8020,
        "tests_available": ["ECG", "Echocardiogram", "Cardiac MRI", "Coronary Angiography", "EP Study", "Holter Monitor"],
        "open_hours": "24x7", "type": "Hospital",
        "maps_url": "https://maps.google.com/?q=Santokba+Durlabhji+Hospital+Jaipur"
    },
    {
        "name": "Mahatma Gandhi Hospital",
        "address": "Sitabari, Tonk Rd, Jaipur 302004",
        "phone": "+91-141-251-4045",
        "lat": 26.8558, "lng": 75.8281,
        "tests_available": ["ECG", "Chest X-Ray", "Complete Blood Count (CBC)", "Fasting Blood Glucose", "Kidney Function Tests", "Urine Analysis"],
        "open_hours": "8AM-8PM", "type": "Hospital",
        "maps_url": "https://maps.google.com/?q=Mahatma+Gandhi+Hospital+Jaipur"
    },
    {
        "name": "SCI International Diagnostic Centre",
        "address": "C-Scheme, Ashok Marg, Jaipur 302001",
        "phone": "+91-141-236-1234",
        "lat": 26.9124, "lng": 75.7873,
        "tests_available": ["ECG", "Lipid Panel", "Complete Blood Count (CBC)", "Thyroid Function Tests", "Fasting Blood Glucose", "Vitamin B12/D Test", "Iron Studies"],
        "open_hours": "7AM-9PM", "type": "Diagnostic Centre",
        "maps_url": "https://maps.google.com/?q=SCI+Diagnostic+Jaipur"
    },
    {
        "name": "Apex Hospitals",
        "address": "SP-4 & 6, Malviya Industrial Area, Jaipur 302017",
        "phone": "+91-141-666-5000",
        "lat": 26.8471, "lng": 75.8101,
        "tests_available": ["ECG", "Stress Test (TMT)", "Echocardiogram", "Troponin Blood Test", "D-Dimer Test", "BNP Test", "Serum Electrolytes"],
        "open_hours": "24x7", "type": "Hospital",
        "maps_url": "https://maps.google.com/?q=Apex+Hospitals+Jaipur"
    },
    {
        "name": "Pathology Lab — Dr. Lal PathLabs",
        "address": "Sindhi Camp, Station Rd, Jaipur 302006",
        "phone": "+91-141-510-5678",
        "lat": 26.9196, "lng": 75.7876,
        "tests_available": ["Complete Blood Count (CBC)", "Lipid Panel", "Fasting Blood Glucose", "Thyroid Function Tests", "Kidney Function Tests", "Liver Function Tests", "Iron Studies", "Vitamin B12/D Test", "Troponin Blood Test", "D-Dimer Test"],
        "open_hours": "6AM-10PM", "type": "Diagnostic Centre",
        "maps_url": "https://maps.google.com/?q=Dr+Lal+PathLabs+Jaipur"
    },
]

# ── LIFESTYLE TIPS ────────────────────────────────────────────────────────────
lifestyle_tips = [
    # ── Healthy Lifestyle ──
    {"category": "Healthy Lifestyle", "title": "Stay Hydrated", "body": "Drink at least 8 glasses of water daily. Dehydration can worsen dizziness, fatigue, and high blood pressure.", "related_symptoms": ["Dizziness", "Fatigue", "High BP"], "icon": "water_drop", "tags": ["hydration", "basics"]},
    {"category": "Healthy Lifestyle", "title": "Eat Heart-Healthy Foods", "body": "Include leafy greens, berries, whole grains, and omega-3 rich fish in your diet to support cardiovascular health.", "related_symptoms": ["Chest Pain", "High BP", "Irregular Heartbeat"], "icon": "eco", "tags": ["diet", "heart"]},
    {"category": "Healthy Lifestyle", "title": "Reduce Sodium Intake", "body": "High salt intake raises blood pressure. Aim for less than 2300mg of sodium per day. Avoid processed and packaged food.", "related_symptoms": ["High BP", "Swelling Legs"], "icon": "no_food", "tags": ["diet", "blood pressure"]},
    {"category": "Healthy Lifestyle", "title": "Quit Smoking", "body": "Smoking damages blood vessels and significantly increases the risk of heart attack. Seek support to quit today.", "related_symptoms": ["Chest Pain", "Shortness of Breath"], "icon": "smoke_free", "tags": ["smoking", "heart"]},
    {"category": "Healthy Lifestyle", "title": "Limit Alcohol Consumption", "body": "Excess alcohol can trigger irregular heartbeat and raise blood pressure. Limit to 1 drink/day for women, 2 for men.", "related_symptoms": ["Irregular Heartbeat", "High BP"], "icon": "no_drinks", "tags": ["alcohol", "heart"]},
    {"category": "Healthy Lifestyle", "title": "Eat Smaller, Frequent Meals", "body": "Large meals can trigger nausea and increase strain on your heart. Try 5-6 small meals spread throughout the day.", "related_symptoms": ["Nausea", "Chest Pain"], "icon": "restaurant", "tags": ["diet", "nausea"]},
    {"category": "Healthy Lifestyle", "title": "Monitor Your Blood Pressure", "body": "Check your BP at home every morning. Keep a log to share with your doctor. Normal is below 120/80 mmHg.", "related_symptoms": ["High BP", "Dizziness", "Fainting"], "icon": "monitor_heart", "tags": ["blood pressure", "monitoring"]},

    # ── Weight Management ──
    {"category": "Weight Management", "title": "Walk 30 Minutes Daily", "body": "A brisk 30-minute walk burns calories and strengthens your heart. Start slow and build up gradually.", "related_symptoms": ["Shortness of Breath", "Fatigue", "Swelling Legs"], "icon": "directions_walk", "tags": ["exercise", "weight"]},
    {"category": "Weight Management", "title": "Track Your Meals", "body": "Use a food diary or app to log what you eat. Awareness is the first step to making healthier choices.", "related_symptoms": ["Fatigue", "High BP"], "icon": "assignment", "tags": ["diet", "tracking"]},
    {"category": "Weight Management", "title": "Avoid Late-Night Eating", "body": "Eating within 2 hours of sleep disrupts metabolism and can worsen acid reflux and nausea.", "related_symptoms": ["Nausea", "Sweating"], "icon": "bedtime", "tags": ["diet", "sleep"]},
    {"category": "Weight Management", "title": "Choose Whole Foods Over Processed", "body": "Replace chips, biscuits, and packaged snacks with fruits, nuts, and seeds for sustained energy.", "related_symptoms": ["Fatigue", "High BP", "Chest Pain"], "icon": "apple", "tags": ["diet", "nutrition"]},
    {"category": "Weight Management", "title": "Stay Consistent, Not Perfect", "body": "Small, consistent changes in diet and activity are far more effective than extreme diets that don't last.", "related_symptoms": ["Fatigue"], "icon": "trending_up", "tags": ["mindset", "consistency"]},

    # ── Fitness & Strength ──
    {"category": "Fitness & Strength", "title": "Start with Light Stretching", "body": "Morning stretches improve circulation and reduce muscle stiffness. Do 10 minutes of gentle stretches daily.", "related_symptoms": ["Fatigue", "Arm Pain", "Swelling Legs"], "icon": "self_improvement", "tags": ["stretching", "flexibility"]},
    {"category": "Fitness & Strength", "title": "Try Chair Exercises", "body": "If strenuous activity feels difficult, seated leg raises, arm circles, and seated marching are excellent low-impact options.", "related_symptoms": ["Shortness of Breath", "Fainting", "Swelling Legs"], "icon": "chair", "tags": ["low-impact", "exercise"]},
    {"category": "Fitness & Strength", "title": "Breathing Exercises", "body": "Practice diaphragmatic breathing: inhale deeply through the nose for 4 seconds, exhale slowly for 6 seconds.", "related_symptoms": ["Shortness of Breath", "Chest Pain", "Fainting"], "icon": "air", "tags": ["breathing", "relaxation"]},
    {"category": "Fitness & Strength", "title": "Build Core Strength", "body": "A strong core supports posture and reduces strain on the heart. Begin with wall sits and modified planks.", "related_symptoms": ["Fatigue", "Arm Pain"], "icon": "fitness_center", "tags": ["strength", "core"]},
    {"category": "Fitness & Strength", "title": "Try Yoga for Heart Health", "body": "Yoga reduces blood pressure and stress. Poses like Savasana, Sukhasana, and Viparita Karani are especially helpful.", "related_symptoms": ["High BP", "Irregular Heartbeat", "Dizziness"], "icon": "spa", "tags": ["yoga", "relaxation"]},

    # ── Wellness Support ──
    {"category": "Wellness Support", "title": "Practice Box Breathing", "body": "Inhale 4 seconds → Hold 4 → Exhale 4 → Hold 4. Repeat 5 times. This activates the parasympathetic nervous system.", "related_symptoms": ["Fainting", "Dizziness", "Irregular Heartbeat", "Sweating"], "icon": "self_improvement", "tags": ["breathing", "stress", "anxiety"]},
    {"category": "Wellness Support", "title": "Prioritise Sleep", "body": "Poor sleep raises cortisol and blood pressure. Aim for 7-9 hours. Keep your room cool and screen-free 30 minutes before bed.", "related_symptoms": ["Fatigue", "Sweating", "High BP"], "icon": "bedtime", "tags": ["sleep", "recovery"]},
    {"category": "Wellness Support", "title": "Manage Stress Actively", "body": "Chronic stress worsens cardiac symptoms. Try journaling, talking to someone, or spending 15 minutes in nature daily.", "related_symptoms": ["Chest Pain", "Irregular Heartbeat", "Sweating", "Nausea"], "icon": "psychology", "tags": ["stress", "mental health"]},
    {"category": "Wellness Support", "title": "Connect with Loved Ones", "body": "Social connection reduces anxiety and depression — both of which worsen physical symptoms. Call a friend today.", "related_symptoms": ["Fatigue", "Nausea"], "icon": "people", "tags": ["mental health", "connection"]},
    {"category": "Wellness Support", "title": "Sun Exposure for Vitamin D", "body": "15-20 minutes of morning sun boosts Vitamin D, which supports heart and immune health.", "related_symptoms": ["Fatigue", "Dizziness"], "icon": "wb_sunny", "tags": ["vitamin d", "energy"]},

    # ── Energy & Productivity ──
    {"category": "Energy and Productivity", "title": "Plan Rest Breaks", "body": "Work in focused 25-minute blocks (Pomodoro technique) with 5-minute rest breaks to avoid energy crashes.", "related_symptoms": ["Fatigue", "Dizziness"], "icon": "timer", "tags": ["productivity", "energy"]},
    {"category": "Energy and Productivity", "title": "Eat Iron-Rich Foods", "body": "Low iron causes fatigue and breathlessness. Include lentils, spinach, and fortified cereals in your meals.", "related_symptoms": ["Fatigue", "Shortness of Breath"], "icon": "restaurant_menu", "tags": ["iron", "energy", "diet"]},
    {"category": "Energy and Productivity", "title": "Avoid Caffeine After 2PM", "body": "Caffeine stays in your system for 8 hours. Afternoon coffee disrupts sleep and increases heart rate.", "related_symptoms": ["Irregular Heartbeat", "Sweating", "Fatigue"], "icon": "free_breakfast", "tags": ["caffeine", "sleep", "heart rate"]},
    {"category": "Energy and Productivity", "title": "Set a Consistent Wake Time", "body": "Waking at the same time every day — even on weekends — regulates your circadian rhythm and boosts energy levels.", "related_symptoms": ["Fatigue", "Sweating"], "icon": "alarm", "tags": ["sleep", "routine"]},
    {"category": "Energy and Productivity", "title": "Take Short Walks After Meals", "body": "A gentle 10-minute walk after eating improves blood sugar control and reduces post-meal sluggishness.", "related_symptoms": ["Fatigue", "Swelling Legs", "Nausea"], "icon": "directions_walk", "tags": ["energy", "blood sugar", "activity"]},
]

db["clinics_jaipur"].drop()
db["clinics_jaipur"].insert_many(clinics)
print(f"✅ Inserted {len(clinics)} clinics")

db["lifestyle_tips"].drop()
db["lifestyle_tips"].insert_many(lifestyle_tips)
print(f"✅ Inserted {len(lifestyle_tips)} lifestyle tips")

db["lifestyle_tips"].create_index("category")
db["lifestyle_tips"].create_index("related_symptoms")
db["clinics_jaipur"].create_index("tests_available")
print("📇 Indexes created")
