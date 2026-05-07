import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

/// Animated splash screen shown on app launch
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to dashboard after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF3D35CC),
              Color(0xFF1A1255),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 54,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 28),
                // App name
                const Text(
                  'Smart Study',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                const Text(
                  'Planner',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB8B3FF),
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Exam Preparation Tracker',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 60),
                // Loading indicator
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                      minHeight: 3,
                    ),
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  'Loading your study plan...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.55),
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
