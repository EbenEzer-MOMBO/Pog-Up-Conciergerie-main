// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_completion_screen.dart';
import '../screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final state = await AuthService.getAuthState();
    if (!mounted) return;

    switch (state) {
      case AppAuthState.unauthenticated:
        _go(const LoginScreen());
        break;

      case AppAuthState.profileIncomplete:
        final profile = await AuthService.getCurrentUserProfile();
        if (!mounted || profile == null) {
          _go(const LoginScreen());
        } else {
          _go(ProfileCompletionScreen(
            email: profile.email,
            googleDisplayName: profile.displayName,
          ));
        }
        break;

      case AppAuthState.authenticated:
        _go(const HomeScreen());
        break;
    }
  }

  void _go(Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
