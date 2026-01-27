// lib/core/widgets/shimmer_loading_dialog.dart
import 'dart:math';
import 'package:flutter/material.dart';

class ShimmerLoadingDialog extends StatefulWidget {
  final String message;

  const ShimmerLoadingDialog({
    super.key,
    this.message = 'Memuat...',
  });

  @override
  State<ShimmerLoadingDialog> createState() => _ShimmerLoadingDialogState();

  static void show(BuildContext context, {String message = 'Memuat...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ShimmerLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

class _ShimmerLoadingDialogState extends State<ShimmerLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    );

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.linear,
      ),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 48),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFFFBF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D4037).withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rotating loader with shimmer
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotateAnimation,
                    _shimmerAnimation,
                  ]),
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFF6D4C41),
                                  const Color(0xFF6D4C41).withOpacity(0.1),
                                  const Color(0xFF6D4C41),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                transform: GradientRotation(
                                  _shimmerAnimation.value * 2 * pi,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6D4C41).withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF6D4C41),
                            size: 32,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Shimmer text
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            const Color(0xFF5D4037).withOpacity(0.6),
                            const Color(0xFF5D4037),
                            const Color(0xFF5D4037).withOpacity(0.6),
                          ],
                          stops: [
                            _shimmerAnimation.value - 0.3,
                            _shimmerAnimation.value,
                            _shimmerAnimation.value + 0.3,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
