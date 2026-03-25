import 'package:flutter/material.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingPage3({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2940FF);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 60), 
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle background rings
                        Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1))),
                        Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1))),
                        
                        // Floating Pill (Top Right)
                        Positioned(
                          right: 30, top: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.visibility_off, color: Color(0xFF008080), size: 16),
                                SizedBox(width: 8),
                                Text('Ghost Mode', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),

                        // Floating Pill (Bottom Left)
                        Positioned(
                          left: 40, bottom: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, color: Color(0xFF8A2BE2), size: 16),
                                SizedBox(width: 8),
                                Text('Ver...', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        
                        // Center Main Shield Card
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50, height: 60,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.lock, color: Colors.white, size: 28),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF40F0D0), shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  const Text('ENCRYPTED', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Privacy-first\nnetworking', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1, color: Color(0xFF1E1E1E), letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('No feeds, no followers. Just real-\nworld connections with total control.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.4)),
                  ),
                  const Spacer(),
                  _buildPaginationDots(),
                  const Spacer(),
                  _buildGetStartedButton(),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), height: 1.5),
                        children: [
                          TextSpan(
                            text: 'Privacy Framework\n',
                            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                          TextSpan(text: 'and community standards.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationDots() {
    const primaryBlue = Color(0xFF2940FF);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
        AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
        AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: 20, height: 6, decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(3))),
      ],
    );
  }

  Widget _buildGetStartedButton() {
    const primaryBlue = Color(0xFF2940FF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        onPressed: onGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
