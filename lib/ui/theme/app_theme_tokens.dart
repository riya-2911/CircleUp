import 'package:flutter/material.dart';

class AppThemeTokens {
  static const Color blueStart = Color(0xFF38BDF8);
  static const Color blueEnd = Color(0xFF2563EB);
  static const Color pageBackgroundWhite = Colors.white;

  static const LinearGradient primaryBlueGradient = LinearGradient(
    colors: [blueStart, blueEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppThemeTokens.primaryBlueGradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  const GradientIcon(this.icon, {super.key, this.size = 24});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppThemeTokens.primaryBlueGradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}
