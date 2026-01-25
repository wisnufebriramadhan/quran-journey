import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../../../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Enhanced Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 400,
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
                      CustomPaint(
                        painter: IslamicPatternPainter(),
                        size: const Size(double.infinity, 400),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: StarPatternPainter(),
                        size: const Size(double.infinity, 400),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFF8F9FA).withOpacity(0.3),
                                const Color(0xFFF8F9FA),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        const SizedBox(height: 24),

                        /// Header Logo & Greeting
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Buat Akun Baru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mulai perjalanan Quran Anda',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        /// Register Form Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFFFFBF5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF5D4037).withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Isi data diri Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 32),

                              /// Name Field
                              const Text(
                                'Nama Lengkap',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: nameController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF5D4037),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan nama lengkap',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: const Color(0xFF5D4037)
                                          .withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// Email Field
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF5D4037),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'nama@email.com',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: const Color(0xFF5D4037)
                                          .withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// Password Field
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF5D4037),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Minimal 6 karakter',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: const Color(0xFF5D4037)
                                          .withOpacity(0.7),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              /// Register Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6D4C41),
                                      Color(0xFF5D4037),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5D4037)
                                          .withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () async {
                                          try {
                                            await auth.register(
                                              nameController.text.trim(),
                                              emailController.text.trim(),
                                              passwordController.text.trim(),
                                            );

                                            if (!mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    const Color(0xFF5D4037),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                content: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'Registrasi berhasil! Silakan login',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );

                                            Navigator.pop(context);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    const Color(0xFF5D4037),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.error_outline,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        e.toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Daftar',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              /// Login Link
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sudah punya akun? ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// Footer
                        Center(
                          child: Text(
                            'Quran Journey © ${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
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

/// ================= ISLAMIC PATTERN PAINTER =================
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
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

/// ================= STAR PATTERN PAINTER =================
class StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final random = Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 2.0 + random.nextDouble() * 3;

      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final angle = (pi * 2) / points;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
