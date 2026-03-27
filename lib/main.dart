import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/goal_trajectory_screen.dart';
import 'screens/add_goal_screen.dart';
import 'screens/mastery_tower_screen.dart';
import 'screens/session_player_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://epxrzsbiwuwmyqknwlxy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVweHJ6c2Jpd3V3bXlxa253bHh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1ODkwMDMsImV4cCI6MjA5MDE2NTAwM30.zSDr-gm_nqpAc3UyXNHwRiS-_TzfzlNav8BRnqxc5PA',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verdant Academic Theme
    return MaterialApp(
      title: 'Studia 3.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8DB600), // Apple Green
          brightness: Brightness.light,
          surface: const Color(0xFFFFF7FB),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/trajectory': (context) => const GoalTrajectoryScreen(),
        '/add_goal': (context) => const AddGoalScreen(),
        '/mastery': (context) => const MasteryTowerScreen(),
        '/session': (context) => const SessionPlayerScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/404': (context) => const NotFoundScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const NotFoundScreen());
      },
    );
  }
}


