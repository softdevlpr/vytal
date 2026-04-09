# Vytal – Your Health Matters

## Description

Vytal is a smart symptom tracking application that helps users monitor their daily health, track symptoms, and gain insights. It simplifies personal healthcare by combining tracking, visualization, and intelligent recommendations in one platform.

---

## Features

* Authentication — Secure sign-up/login via Firebase Auth and JWT tokens
* Symptom Checker — ML-powered self-diagnosis tool
* Health Insights & Charts — Visual data representation using fl_chart
* Reminders & Notifications — Local push notifications for health check-ins
* Clinic Locator — Find clinics in Jaipur 
* Profile Management — Upload and manage profile 
* Secure Local Storage — Sensitive data encrypted with flutter_secure_storage

---

## Tech Stack

### Frontend

* Flutter/Dart
* Firebase Auth
* SharedPreferences

### Backend

* Node.js + Express.js
* MongoDB + Mongoose
* JSONWebToken
* bcryptjs
  
### ML Service

* FastAPI/Flask


---

## Installation

### Flutter App Setup

# Clone the repository
git clone https://github.com/softdevlpr/vytal.git
cd vytal

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run



### Run Backend

# Navigate to the project root
cd vytal

# Install Node dependencies
npm install

# Start in development mode
npm run dev

# Start in production mode
npm start



### ML Service Setup

# Navigate to ML Service folder
cd ml-service

# Install Python dependencies
pip install -r requirements.txt

# Start the ML service
python app.py


---

## Usage

* Log daily health symptoms
* View trends and insights on dashboard
* Set daily or weekly reminders
* Get daily lifestyle tips

---

## Future Improvements

* Caregiver or family access
* Advanced health analytics and predictions


---


## Inspiration

Vytal was created to simplify personal health management by combining AI, data tracking, and intuitive design into one seamless experience.
