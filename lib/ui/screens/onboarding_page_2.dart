import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  
  const OnboardingPage2({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 60), // Push the radar visual down slightly compared to Page 1
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle background rings
                        Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1))),
                        Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1))),
                        
                        // 4 Concept Cards
                        Positioned(
                          left: 20, top: 10,
                          child: _buildIntentSquare('STUDY', Icons.menu_book, const Color(0xFF2940FF), false),
                        ),
                        Positioned(
                          right: 20, top: 30,
                          child: _buildIntentSquare('BUILD', Icons.build, const Color(0xFF8A2BE2), false),
                        ),
                        Positioned(
                          left: 20, bottom: 20,
                          child: _buildIntentSquare('HANG OUT', Icons.local_cafe, const Color(0xFF008080), false),
                        ),
                        Positioned(
                          right: 20, bottom: 0,
                          child: _buildIntentSquare('ACTIVE', Icons.bolt, const Color(0xFF2940FF), true),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Connect based on\nintent', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.1, color: Color(0xFF1E1E1E), letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Match with others who want to study,\nbuild, or hang out right now. Stop\nscrolling, start doing.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Hashtag tags
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTag('#ProductDesign'),
                      _buildTag('#DeepWork'),
                      _buildTag('#FounderCoffee'),
                    ],
                  ),
                  
                  const Spacer(),
                  _buildPaginationDots(),
                  const Spacer(),
                  _buildNextButton(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onSkip,
                    child: const Text('SKIP ONBOARDING', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('WE ONLY SHARE YOUR INTENT WITH VERIFIED\nNETWORK MEMBERS.', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.5)),
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

  Widget _buildIntentSquare(String title, IconData icon, Color color, bool isFilled) {
    return Container(
      width: 100,
      height: 105,
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isFilled ? color : Colors.black).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isFilled ? Colors.white : color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isFilled ? Colors.white : const Color(0xFF1E1E1E),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    const primaryBlue = Color(0xFF2940FF);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active dot is index 1
        AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
        AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: 20, height: 6, decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(3))),
        AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
      ],
    );
  }

  Widget _buildNextButton() {
    const primaryBlue = Color(0xFF2940FF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
