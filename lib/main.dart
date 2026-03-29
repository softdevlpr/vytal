// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'data/app_constants.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'screens/onboarding_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(const CardiacApp());
}

class CardiacApp extends StatelessWidget {
  const CardiacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Vytal App - Your Health Matters',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            background: AppColors.background,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/onboarding',
        routes: {
          '/splash':  (_) => const OnboardingPage(),
          '/login':   (_) => const LoginPage(),
          '/signup':  (_) => const SignupPage(),
          '/home':    (_) => const HomePage(),
        },
      ),
    );
  }
}
