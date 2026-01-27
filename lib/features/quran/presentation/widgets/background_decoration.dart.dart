import 'dart:math';
import 'package:flutter/material.dart';

/// Background component untuk Quran Audio Player
/// Menampilkan gradient, islamic pattern, dan animated stars
class BackgroundDecoration extends StatelessWidget {
  final Animation<double> shimmerAnimation;

  const BackgroundDecoration({
    super.key,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3E2723),
              Color(0xFF4A3428),
              Color(0xFF5D4037),
              Color(0xFF6D4C41),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background Islamic Pattern
            CustomPaint(
              painter: IslamicPatternPainter(),
              size: Size.infinite,
            ),

            // Animated Stars
            CustomPaint(
              painter: AnimatedStarsPainter(shimmerAnimation.value),
              size: Size.infinite,
            ),
          ],
        ),
      ),
    );
  }
}

/// Islamic Pattern Painter
/// Membuat pattern geometris bergaya Islamic
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 80.0;
    const radius1 = 25.0;
    const radius2 = 12.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        // Outer circle
        canvas.drawCircle(Offset(x, y), radius1, paint);
        
        // Inner circle
        canvas.drawCircle(Offset(x, y), radius2, paint);

        // Cross lines
        final paint2 = Paint()
          ..color = Colors.white.withOpacity(0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawLine(
          Offset(x - radius1, y),
          Offset(x + radius1, y),
          paint2,
        );
        canvas.drawLine(
          Offset(x, y - radius1),
          Offset(x, y + radius1),
          paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated Stars Painter
/// Membuat efek bintang yang berkedip
class AnimatedStarsPainter extends CustomPainter {
  final double animationValue;

  AnimatedStarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed untuk konsistensi posisi

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Create pulsing effect
      final pulse = sin((animationValue * 2 * pi) + (i * 0.5));
      final opacity = (0.2 + (pulse * 0.3)).clamp(0.0, 0.5);
      final starSize = 1.5 + (pulse * 1.5);

      final paint = Paint()
        ..color = Colors.amber.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  /// Menggambar bentuk bintang
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    const angle = (pi * 2) / points;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? size : size / 2;
      final currentAngle = angle * i - pi / 2;
      final x = center.dx + cos(currentAngle) * r;
      final y = center.dy + sin(currentAngle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedStarsPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}