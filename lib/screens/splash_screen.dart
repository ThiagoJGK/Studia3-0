import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate Supabase auth check / loading
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7FB), // Light surface
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF8DB600), size: 64),
            SizedBox(height: 24),
            Text(
              'Studia 3.0',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF536D00),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text('El Santuario', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8DB600)),
            ),
          ],
        ),
      ),
    );
  }
}
