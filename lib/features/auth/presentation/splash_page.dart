import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeInAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    _shimmerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
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
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1528),
                    Color(0xFF172847),
                    Color(0xFF27335A),
                    Color(0xFF3F3959),
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: -120,
                    top: -80 + (8 * sin(_controller.value * 2 * pi)),
                    child: const _GlowOrb(
                      size: 280,
                      color: Color(0x6658E8E1),
                    ),
                  ),
                  Positioned(
                    right: -100,
                    bottom: -90 + (12 * cos(_controller.value * 2 * pi)),
                    child: const _GlowOrb(
                      size: 260,
                      color: Color(0x66FFC36B),
                    ),
                  ),
                  CustomPaint(
                    painter: _SubtleGridPainter(progress: _controller.value),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(),
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Transform.translate(
                              offset: Offset(0, -_floatAnimation.value),
                              child: ScaleTransition(
                                scale: _logoScaleAnimation,
                                child: const _BrandBadge(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                final start = (_shimmerAnimation.value - 0.2)
                                    .clamp(0.0, 1.0);
                                final end = (_shimmerAnimation.value + 0.2)
                                    .clamp(0.0, 1.0);
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: const [
                                    Color(0xFFD6E6FF),
                                    Colors.white,
                                    Color(0xFFD6E6FF),
                                  ],
                                  stops: [start, _shimmerAnimation.value, end],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Quran Journey',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Text(
                              'Temani ibadah harian dengan catatan,\nmurattal, dan pengingat sholat.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 14.5,
                                height: 1.45,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: const _ModernLoader(),
                          ),
                          const SizedBox(height: 22),
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Text(
                              'Preparing your daily journey...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.68),
                                fontSize: 12.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x55FFFFFF),
            Color(0x12FFFFFF),
          ],
        ),
        border: Border.all(color: const Color(0x66FFFFFF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4421426A),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 95,
            height: 95,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6C66A),
                  Color(0xFFE99B42),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }
}

class _ModernLoader extends StatelessWidget {
  const _ModernLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.8),
            ),
            backgroundColor: Colors.white.withOpacity(0.15),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFC874),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  final double progress;

  const _SubtleGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 48.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final drift = 6 * sin(progress * 2 * pi);
    for (double y = -spacing; y <= size.height + spacing; y += spacing) {
      final path = Path()
        ..moveTo(0, y + drift)
        ..lineTo(size.width, y - drift);
      canvas.drawPath(path, paint);
    }

    for (double x = -spacing; x <= size.width + spacing; x += spacing) {
      final path = Path()
        ..moveTo(x + drift, 0)
        ..lineTo(x - drift, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SubtleGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
