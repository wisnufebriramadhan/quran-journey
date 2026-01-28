import 'package:flutter/material.dart';

/// Custom painter untuk menggambar header surah yang dekoratif
class EnhancedSurahHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background gradient
    const gradient = LinearGradient(
      colors: [
        Color(0xFFF0E6D2),
        Color(0xFFE8DCC8),
        Color(0xFFF0E6D2),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw top border lines
    _drawBorderLines(canvas, size, paint);

    // Draw corner decorations
    _drawCornerDecorations(canvas, size, paint);

    // Draw diamond patterns
    _drawDiamondPatterns(canvas, size, paint);
  }

  void _drawBorderLines(Canvas canvas, Size size, Paint paint) {
    paint.shader = null;
    paint.color = const Color(0xFFD4AF37);
    paint.style = PaintingStyle.stroke;

    // Top thick line
    paint.strokeWidth = 2.5;
    canvas.drawLine(const Offset(0, 3), Offset(size.width, 3), paint);

    // Top thin line
    paint.strokeWidth = 1;
    canvas.drawLine(const Offset(0, 6), Offset(size.width, 6), paint);

    // Bottom thin line
    canvas.drawLine(
      Offset(0, size.height - 6),
      Offset(size.width, size.height - 6),
      paint,
    );

    // Bottom thick line
    paint.strokeWidth = 2.5;
    canvas.drawLine(
      Offset(0, size.height - 3),
      Offset(size.width, size.height - 3),
      paint,
    );
  }

  void _drawCornerDecorations(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF2E7D7D).withOpacity(0.25);

    const cornerSize = 12.0;
    final corners = [
      const Offset(cornerSize, cornerSize),
      Offset(size.width - cornerSize, cornerSize),
      Offset(cornerSize, size.height - cornerSize),
      Offset(size.width - cornerSize, size.height - cornerSize),
    ];

    for (final corner in corners) {
      for (var i = 0; i < 6; i++) {
        final petalPath = Path()
          ..addOval(Rect.fromCenter(
            center: Offset(
              corner.dx + 6 * (i % 2 == 0 ? 1 : 0.7) * (i < 3 ? 1 : -1),
              corner.dy + 6 * (i % 2 == 0 ? 1 : 0.7) * (i < 3 ? 1 : -1),
            ),
            width: 4,
            height: 4,
          ));
        canvas.drawPath(petalPath, paint);
      }
    }
  }

  void _drawDiamondPatterns(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFFD4AF37).withOpacity(0.2);
    const spacing = 60.0;

    for (double x = spacing; x < size.width - spacing; x += spacing) {
      // Top diamond
      final diamondPath = Path()
        ..moveTo(x, 12)
        ..lineTo(x + 5, 16)
        ..lineTo(x, 20)
        ..lineTo(x - 5, 16)
        ..close();
      canvas.drawPath(diamondPath, paint);

      // Bottom diamond
      final diamondPath2 = Path()
        ..moveTo(x, size.height - 12)
        ..lineTo(x + 5, size.height - 16)
        ..lineTo(x, size.height - 20)
        ..lineTo(x - 5, size.height - 16)
        ..close();
      canvas.drawPath(diamondPath2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}