import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'data/app_constants.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';

// Screens
import 'screens/onboarding_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone (for notifications)
  tz.initializeTimeZones();

  // Initialize local notifications
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
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),

        initialRoute: '/onboarding',

        routes: {
          '/onboarding': (_) => const OnboardingPage(),
          '/login': (_) => const LoginPage(),
          '/signup': (_) => const RegisterPage(),

          // MAIN APP ENTRY (after login)
          '/home': (_) => const MainScreen(),
        },
      ),
    );
  }
}
