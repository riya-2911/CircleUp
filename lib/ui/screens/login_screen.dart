import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'intent_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (result != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (context, animation, secondaryAnimation) => const IntentSelectionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2940FF);
    const bgColor = Color(0xFFF4F6FC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // App Logo
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A78FF), Color(0xFF2940FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.hub, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CircleUp',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Welcome Text
                        const Text(
                          'Welcome to\nCircleUp',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sign in to start connecting.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Continue with Phone (Primary)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.phone_iphone, size: 20),
                            label: const Text(
                              'Continue with phone number',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // OR divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.withOpacity(0.25), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.withOpacity(0.25), thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Continue with Google
                        _SocialButton(
                          icon: _GoogleIcon(),
                          label: 'Continue with Google',
                          isLoading: _isGoogleLoading,
                          onTap: _handleGoogleSignIn,
                        ),

                        const SizedBox(height: 12),

                        // Continue with College Email
                        _SocialButton(
                          icon: const Icon(Icons.school, color: Color(0xFF2940FF), size: 22),
                          label: 'Continue with college email',
                          isLoading: false,
                          onTap: () {},
                        ),

                        const SizedBox(height: 32),

                        // Social Proof Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Stacked Avatar Icons
                                  SizedBox(
                                    width: 70,
                                    height: 28,
                                    child: Stack(
                                      children: [
                                        _buildAvatarCircle(0, const Color(0xFFFF7F50)),
                                        _buildAvatarCircle(22, const Color(0xFF4CAF50)),
                                        _buildAvatarCircle(44, const Color(0xFF2196F3)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(color: Color(0xFF00C48C), shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '12.4k active users',
                                        style: TextStyle(
                                          color: Color(0xFF1E1E1E),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '"The fastest way to connect with peers in my department. Highly secure and focused."',
                                style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),

                        // Footer legal text
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text.rich(
                            TextSpan(
                              text: 'By tapping Continue, you agree to our ',
                              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), height: 1.5),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFF2940FF),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF2940FF),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: '. We use your email only to verify your student status.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(double left, Color color) {
    return Positioned(
      left: left,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 14),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2940FF)),
              )
            else
              icon,
            const SizedBox(width: 12),
            Text(
              isLoading ? 'Signing in...' : label,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
