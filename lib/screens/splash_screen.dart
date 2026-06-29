// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Nạp token từ bộ nhớ vào ApiService
    await AuthService.instance.loadFromStorage();
    // Chờ nhỏ để logo hiện ra mượt
    await Future.delayed(const Duration(milliseconds: 1200));
    //final loggedIn = await AuthStorage.isLoggedIn();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AuthService.instance.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apps_rounded,
              size: 80,
              color: Color(0xFF2563EB),
            ),
            SizedBox(height: 20),
            Text(
              'Thái Tuấn',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hệ thống quản lý nội bộ',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
