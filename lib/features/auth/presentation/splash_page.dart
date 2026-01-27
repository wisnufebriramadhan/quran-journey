import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotateAnimation = CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _rotateController.forward();

    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    // Langsung ke home tanpa cek auth
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
              // Background Pattern
              CustomPaint(
                painter: IslamicPatternPainter(),
                size: Size.infinite,
              ),

              // Animated stars
              CustomPaint(
                painter: AnimatedStarsPainter(_shimmerAnimation.value),
                size: Size.infinite,
              ),

              // Main Content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Icon with glow effect
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _rotateAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateAnimation.value * 0.1,
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.amber.shade300.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.shade300,
                                        Colors.amber.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.shade400
                                            .withOpacity(0.5),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 48),

                      // App Title with shimmer effect
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white,
                                  Colors.white.withOpacity(0.6),
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Quran Journey',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Catat ibadah harianmu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _rotateController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateController.value * 2 * pi,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.amber.shade300
                                            .withOpacity(0.3),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Center(
                              child: AnimatedBuilder(
                                animation: _rotateController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: -_rotateController.value * 3 * pi,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.amber.shade400,
                                          width: 3,
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber.shade300,
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom decoration
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          height: 2,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.amber.shade300,
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Islamic Pattern Painter
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
        canvas.drawCircle(Offset(x, y), radius1, paint);
        canvas.drawCircle(Offset(x, y), radius2, paint);

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
class AnimatedStarsPainter extends CustomPainter {
  final double animationValue;

  AnimatedStarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

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
