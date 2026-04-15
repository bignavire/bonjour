import 'package:flutter/material.dart';
import 'package:gotime/lib/auth_gate.dart';
import 'package:gotime/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gotime/firebase_options.dart';
import 'package:gotime/pages/notification_service.dart';
import 'package:gotime/lib/pages/onboarding_page.dart';
import 'package:gotime/pages/pageaccueil.dart';
import 'package:gotime/pages/descriptionPages/first_page.dart';
import 'package:gotime/pages/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gotime/forgot_password_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INIT HIVE (IMPORTANT)
  await Hive.initFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final bool isDark = prefs.getBool('dark_mode') ?? false;

  runApp(MyApp(onboardingDone: onboardingDone, isDark: isDark));
}
class MyApp extends StatefulWidget {
  final bool onboardingDone;
  final bool isDark;
  const MyApp({super.key, required this.onboardingDone, required this.isDark});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDark = !_isDark);
    await prefs.setBool('dark_mode', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTime',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: FirstPage(onboardingDone: widget.onboardingDone),
      routes: {
        '/home': (context) => const Pageaccueil(),
        '/onboarding': (context) => const OnboardingPage(),
        '/landing': (context) => const LandingPage(),
        '/auth': (context) => const AuthGate(),
         '/forgot-password': (context) => const ForgotPasswordPage(),
      
      },
    );
  }
}