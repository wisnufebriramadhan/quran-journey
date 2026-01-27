// lib/features/home/providers/home_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/auth/auth_provider.dart';
import 'package:quran_tracker/features/home/providers/banner_list.dart';
import 'package:quran_tracker/routes/app_routes.dart';

class HomeProvider {
  late DateTime _ramadhanDate;
  late Timer _timer;
  Duration _remaining = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _selectedDockIndex = 0;
  late PageController _hadistPageController;
  late Timer _hadistAutoScrollTimer;
  int _currentHadistIndex = 0;

  // Getters
  Duration get remaining => _remaining;
  AnimationController get animationController => _animationController;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get slideAnimation => _slideAnimation;
  int get selectedDockIndex => _selectedDockIndex;
  PageController get hadistPageController => _hadistPageController;

  void initialize(TickerProvider vsync) {
    _ramadhanDate = _getNextRamadhan();
    _updateCountdown();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
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

    _hadistPageController = PageController(viewportFraction: 0.92);
    _setupHadistAutoScroll();
  }

  void _setupHadistAutoScroll() {
    _hadistAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_hadistPageController.hasClients) {
        _currentHadistIndex = (_currentHadistIndex + 1) % dailyQuotes.length;
        _hadistPageController.animateToPage(
          _currentHadistIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  DateTime _getNextRamadhan() {
    final now = DateTime.now();
    DateTime ramadhan = DateTime(2026, 2, 18);
    if (now.isAfter(ramadhan)) {
      ramadhan = DateTime(2027, 2, 8);
    }
    return ramadhan;
  }

  void _updateCountdown() {
    _remaining = _ramadhanDate.difference(DateTime.now());
  }

  void setSelectedDockIndex(int index) {
    _selectedDockIndex = index;
  }

  /// Navigate berdasarkan index menu
  /// Index 2 = Catatan sudah dihandle di menu_grid.dart
  /// Ini untuk handle navigation lain yang mungkin dipanggil langsung
  Future<void> navigateTo(BuildContext context, int index) async {
    switch (index) {
      case 1:
        // Mushaf Digital - langsung navigasi
        await Navigator.pushNamed(context, AppRoutes.mushafDigital);
        break;
      case 2:
        // Catatan - perlu auth
        // Redundant karena sudah di menu_grid, tapi untuk safety
        await _navigateWithAuthCheck(context, AppRoutes.quranLog);
        break;
      case 3:
        // Prayer Time - langsung navigasi
        await Navigator.pushNamed(context, AppRoutes.prayerTime);
        break;
      case 4:
        // Settings - langsung navigasi
        await Navigator.pushNamed(context, AppRoutes.settings);
        break;
      default:
        break;
    }
  }

  /// Helper untuk navigasi yang memerlukan autentikasi
  Future<void> _navigateWithAuthCheck(
    BuildContext context,
    String route,
  ) async {
    if (!context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      // Tampilkan dialog untuk login
      final shouldLogin = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Login Diperlukan'),
          content: const Text(
            'Silakan login terlebih dahulu untuk mengakses fitur ini',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      // Jika user pilih login
      if (shouldLogin == true && context.mounted) {
        final loginResult = await Navigator.pushNamed(
          context,
          AppRoutes.login,
        );

        // Jika login berhasil (return true dari login page)
        if (loginResult == true && context.mounted) {
          final auth = Provider.of<AuthProvider>(context, listen: false);

          // Double check apakah sudah login
          if (auth.isLoggedIn) {
            await Navigator.pushNamed(context, route);
          }
        }
      }
    } else {
      // Sudah login, langsung navigasi
      await Navigator.pushNamed(context, route);
    }
  }

  void dispose() {
    _timer.cancel();
    _hadistAutoScrollTimer.cancel();
    _hadistPageController.dispose();
    _animationController.dispose();
  }
}
