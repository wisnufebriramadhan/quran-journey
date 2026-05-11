import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/auth/auth_provider.dart';
import 'package:quran_tracker/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Setelan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          
          // ==========================================
          // SECTION: ACCOUNT
          // ==========================================
          if (auth.isLoggedIn)
            _buildProfileCard(context, auth)
          else
            _buildLoginPrompt(context),

          const SizedBox(height: 12),
          _buildSectionHeader('Umum'),
          _buildSettingTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Waktu Sholat',
            subtitle: 'Metode perhitungan & penyesuaian waktu',
            onTap: () => Navigator.pushNamed(context, AppRoutes.prayerSettings),
          ),
          _buildSettingTile(
            context,
            icon: Icons.calendar_month_rounded,
            title: 'Kalender Hijriah',
            subtitle: 'Penyesuaian tanggal & metode',
            onTap: () => Navigator.pushNamed(context, AppRoutes.prayerSettings),
          ),
          _buildSettingTile(
            context,
            icon: Icons.school_rounded,
            title: 'Belajar',
            subtitle: 'Materi pembelajaran Islam',
            onTap: () => Navigator.pushNamed(context, AppRoutes.learning),
          ),
          
          const SizedBox(height: 12),
          _buildSectionHeader('Aplikasi'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Tentang Aplikasi',
            subtitle: 'Quran Journey v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.star_outline_rounded,
            title: 'Beri Rating',
            subtitle: 'Dukung kami di Play Store',
            onTap: () {},
          ),
          
          if (auth.isLoggedIn) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    AppRoutes.gate, 
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar Akun'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Made with ❤️ for Ummah',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person_rounded,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  auth.isLoggedIn ? 'Akun Terhubung' : 'Belum Login',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade700, Colors.brown.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Simpan Progres Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Login untuk mencatat riwayat bacaan Quran Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.brown,
              elevation: 0,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Login / Register Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.brown.shade400, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Quran Journey',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: 60,
          height: 60,
        ),
      ),
      children: [
        const Text(
          'Aplikasi Quran Journey membantu umat Muslim dalam melacak progres bacaan Quran, '
          'mengetahui waktu sholat, dan mempelajari Islam lebih dalam.',
        ),
        const SizedBox(height: 12),
        const Text('Developer: Wisnu Febri'),
      ],
    );
  }
}
