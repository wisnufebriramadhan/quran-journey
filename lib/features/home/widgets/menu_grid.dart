import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/shimmer_loading_dialog.dart';
import 'package:quran_tracker/routes/app_routes.dart';
import 'package:quran_tracker/features/quran/presentation/quran_audio_player_page.dart';
import 'package:quran_tracker/features/home/home_page_widgets.dart';
import 'package:quran_tracker/features/auth/auth_provider.dart';

class MenuGrid extends StatelessWidget {
  final Function(int) onNavigate;

  const MenuGrid({
    required this.onNavigate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 5),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainGrid(context),
            _buildSectionDivider(),
            _buildSecondaryGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade300.withOpacity(0),
              Colors.grey.shade300,
              Colors.grey.shade300.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      children: [
        ModernMenuGridLarge(
          icon: Icons.menu_book_rounded,
          label: 'Mushaf Digital',
          subtitle: 'Baca Quran',
          color: const Color(0xFF6D4C41),
          onTap: () => onNavigate(1),
        ),
        ModernMenuGridLarge(
          icon: Icons.headphones_rounded,
          label: 'Murattal',
          subtitle: 'Dengar Quran',
          color: const Color(0xFFB39DDB),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QuranAudioPlayerPage(initialSurah: 1),
              ),
            );
          },
        ),
        ModernMenuGridLarge(
          icon: Icons.edit_note_rounded,
          label: 'Catatan',
          subtitle: 'Catat Progres',
          color: const Color(0xFF7B5E57),
          onTap: () =>
              _handleProtectedRoute(context, AppRoutes.quranLog, 'Catatan'),
        ),
        ModernMenuGridLarge(
          icon: Icons.mosque_rounded,
          label: 'Jadwal Sholat',
          subtitle: 'Waktu Sholat',
          color: const Color(0xFFa1887f),
          onTap: () => onNavigate(3),
        ),
      ],
    );
  }

  Widget _buildSecondaryGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ModernMenuGridSmall(
            icon: Icons.school_rounded,
            label: 'Belajar',
            color: const Color(0xFF8D6E63),
            onTap: () => _handleProtectedRoute(
                context, AppRoutes.learning, 'Pembelajaran'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ModernMenuGridSmall(
            icon: Icons.settings_rounded,
            label: 'Setelan',
            color: const Color(0xFFBCAAA4),
            onTap: () => onNavigate(4),
          ),
        ),
      ],
    );
  }

  Future<void> _handleProtectedRoute(
    BuildContext context,
    String routeName,
    String featureName, // ✅ Tambah parameter untuk nama fitur
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ✅ Step 1: Tunggu sampai initialized dengan shimmer loading
    if (!authProvider.isInitialized) {
      ShimmerLoadingDialog.show(
        context,
        message: 'Memeriksa status...',
      );

      // Tunggu sampai initialized
      await _waitForInitialization(authProvider);

      // Tutup loading dialog
      if (context.mounted) {
        ShimmerLoadingDialog.hide(context);
      }
    }

    if (!context.mounted) return;

    // ✅ Step 2: Cek apakah sudah login
    if (authProvider.isLoggedIn) {
      // Tampilkan shimmer loading saat navigasi
      ShimmerLoadingDialog.show(
        context,
        message: 'Membuka $featureName...', // ✅ Dynamic message
      );

      // Delay sebentar untuk smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        ShimmerLoadingDialog.hide(context);
        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted) {
          Navigator.pushNamed(context, routeName);
        }
      }
      return;
    }

    // ✅ Step 3: Belum login, tampilkan dialog konfirmasi
    final shouldLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Login Diperlukan'),
        content: Text(
          'Silakan login terlebih dahulu untuk mengakses $featureName',
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

    // ✅ Step 4: Jika user pilih login
    if (shouldLogin == true && context.mounted) {
      final loginResult = await Navigator.pushNamed(
        context,
        AppRoutes.login,
      );

      // ✅ Step 5: Jika login berhasil, navigate ke halaman yang diminta
      if (loginResult == true && context.mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.isLoggedIn) {
          // Tampilkan shimmer loading
          ShimmerLoadingDialog.show(
            context,
            message: 'Membuka $featureName...',
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (context.mounted) {
            ShimmerLoadingDialog.hide(context);
            await Future.delayed(const Duration(milliseconds: 100));

            if (context.mounted) {
              Navigator.pushNamed(context, routeName);
            }
          }
        }
      }
    }
  }

  Future<void> _waitForInitialization(AuthProvider provider) async {
    while (!provider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
