import 'package:flutter/material.dart';
import 'onboarding_page_1.dart';
import 'onboarding_page_2.dart';
import 'onboarding_page_3.dart';
import 'package:circleup/services/prefs_helper.dart';
import 'login_screen.dart';

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    const double spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.0, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage < 2) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _finishOnboarding() async {
    await PrefsHelper.setOnboardingCompleted();
    
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );
          final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomPaint(
        painter: DotGridPainter(),
        child: SafeArea(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              OnboardingPage1(onNext: _nextPage),
              OnboardingPage2(onNext: _nextPage, onSkip: _finishOnboarding),
              OnboardingPage3(onGetStarted: _finishOnboarding),
            ],
          ),
        ),
      ),
    );
  }
}
