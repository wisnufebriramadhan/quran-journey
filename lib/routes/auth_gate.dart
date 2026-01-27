import 'package:flutter/material.dart';
import 'package:quran_tracker/features/auth/presentation/splash_page.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Langsung tampilkan SplashPage tanpa cek auth
    return const SplashPage();
  }
}
