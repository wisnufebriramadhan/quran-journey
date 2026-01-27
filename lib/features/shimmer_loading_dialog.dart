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
      barrierColor: Colors.black45,
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
  late AnimationController _dotController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dotAnimation;

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
      duration: const Duration(milliseconds: 3500),
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
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Dot animation
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _dotAnimation = CurvedAnimation(
      parent: _dotController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 40,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFFFFBF5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF6D4C41).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5D4037).withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: const Color(0xFF6D4C41).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ANIMATED LOADER
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _rotateAnimation,
                      _shimmerAnimation,
                    ]),
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          /// Outer rotating ring
                          Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    const Color(0xFF6D4C41),
                                    const Color(0xFF7B5E57),
                                    const Color(0xFF6D4C41).withOpacity(0.2),
                                    const Color(0xFF6D4C41),
                                  ],
                                  stops: const [0.0, 0.35, 0.7, 1.0],
                                  transform: GradientRotation(
                                    _shimmerAnimation.value * 2 * pi,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// Middle ring with opacity
                          Transform.rotate(
                            angle: -_rotateAnimation.value * 0.7,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      const Color(0xFF6D4C41).withOpacity(0.15),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          /// Inner white circle with icon
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF6D4C41).withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: const Color(0xFF6D4C41),
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  /// MESSAGE WITH SHIMMER
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              const Color(0xFF5D4037).withOpacity(0.5),
                              const Color(0xFF5D4037),
                              const Color(0xFF5D4037).withOpacity(0.5),
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
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// ANIMATED DOTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _dotAnimation,
                        builder: (context, child) {
                          // Delay each dot
                          final delay = index * 0.25;
                          final value =
                              (_dotAnimation.value - delay).clamp(0.0, 1.0);
                          final scale = (sin(value * pi) * 0.5 + 0.5);

                          return ScaleTransition(
                            scale: AlwaysStoppedAnimation(scale),
                            child: Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6D4C41).withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
