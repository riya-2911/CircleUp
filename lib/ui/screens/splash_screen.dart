import 'dart:async';
import 'package:flutter/material.dart';
import 'package:circleup/services/prefs_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for the 4-second splash
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    
    // Quick fade and scale in for the logo elements during the first 1.5 seconds
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack)),
    );
    
    // Progress bar fills over the full 4 seconds
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate depending on completion status
    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;

      final bool hasCompleted = await PrefsHelper.hasCompletedOnboarding();
      final String? userId = await PrefsHelper.getUserId();
      final String? userName = await PrefsHelper.getUserName();
      final bool hasCompletedProfile = await PrefsHelper.hasCompletedProfileSetup();

      if (mounted) {
        if (!hasCompleted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
          return;
        }

        final isLoggedIn =
            userId != null && userId.isNotEmpty && userName != null && userName.isNotEmpty;

        if (!isLoggedIn) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        if (!hasCompletedProfile) {
          Navigator.pushReplacementNamed(context, '/profile-setup');
          return;
        }

        Navigator.pushReplacementNamed(context, '/main-nav');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2940FF);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // App Logo Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3C56FF), // Slightly lighter blue box
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF40F0D0), // Cyan center
                            border: Border.all(color: const Color(0xFF3C56FF), width: 8), // Inner hole illusion
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Typography
                    const Text(
                      'CircleUp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Right people. Right moment.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Secure Networking Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security, color: Color(0xFF40F0D0), size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'SECURE NETWORKING',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Animated Progress Bar
                    Container(
                      width: size.width * 0.5,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: (size.width * 0.5) * _progressAnimation.value,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF40F0D0),
                              borderRadius: BorderRadius.circular(1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF40F0D0).withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
