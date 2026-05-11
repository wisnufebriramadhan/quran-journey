import 'package:flutter/material.dart';
import 'package:quran_tracker/routes/app_routes.dart';
import 'package:quran_tracker/features/murattal/quran_audio_player_page.dart';
import 'package:quran_tracker/features/home/widgets/home_page_widgets.dart';

class MenuGrid extends StatelessWidget {
  final Function(int) onNavigate;

  const MenuGrid({
    required this.onNavigate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainGrid(context),
        _buildSectionDivider(),
        _buildSecondaryGrid(context),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      children: [
        ModernMenuGridLarge(
          icon: Icons.menu_book_rounded,
          label: 'Mushaf Digital',
          subtitle: 'Baca Quran',
          color: const Color(0xFF0F766E), // Teal
          onTap: () => onNavigate(1),
        ),
        ModernMenuGridLarge(
          icon: Icons.headphones_rounded,
          label: 'Murattal',
          subtitle: 'Dengar Quran',
          color: const Color(0xFF4338CA), // Indigo
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
          color: const Color(0xFF7C2D12), // Terracotta/Brown
          onTap: () => onNavigate(2),
        ),
        ModernMenuGridLarge(
          icon: Icons.mosque_rounded,
          label: 'Jadwal Sholat',
          subtitle: 'Waktu Sholat',
          color: const Color(0xFF1E293B), // Slate Blue
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
            color: const Color(0xFF0369A1), // Sky Blue
            onTap: () => onNavigate(4), 
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ModernMenuGridSmall(
            icon: Icons.settings_rounded,
            label: 'Setelan',
            color: const Color(0xFF475569), // Slate Gray
            onTap: () => onNavigate(5),
          ),
        ),
      ],
    );
  }
}
