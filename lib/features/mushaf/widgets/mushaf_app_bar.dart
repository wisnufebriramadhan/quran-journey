import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_colors.dart';

/// Widget AppBar untuk Mushaf Page
class MushafAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MushafPageController controller;
  final VoidCallback onDownload;
  final VoidCallback onClearData;
  final VoidCallback onJumpToPage;

  const MushafAppBar({
    super.key,
    required this.controller,
    required this.onDownload,
    required this.onClearData,
    required this.onJumpToPage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MushafColors.appBarBrown,
      foregroundColor: MushafColors.goldAccent,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.2),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Al-Qur\'an',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  controller.currentSurahTitle ?? 'Memuat...',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: MushafColors.goldAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: MushafColors.goldAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Juz ${controller.currentJuz}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: MushafColors.goldAccent,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            controller.isNightMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            size: 20,
          ),
          onPressed: controller.toggleNightMode,
          tooltip: controller.isNightMode ? 'Mode terang' : 'Mode malam',
        ),
        IconButton(
          icon: Icon(
            controller.isComfortReading
                ? Icons.text_fields_rounded
                : Icons.format_size_rounded,
            size: 20,
          ),
          onPressed: controller.toggleComfortReading,
          tooltip: controller.isComfortReading
              ? 'Nonaktifkan baca nyaman'
              : 'Aktifkan baca nyaman',
        ),
        if (!controller.isDataDownloaded)
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined, size: 20),
            onPressed: onDownload,
            tooltip: 'Download untuk offline',
          ),
        if (controller.isDataDownloaded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.offline_bolt_rounded,
                color: Colors.greenAccent,
                size: 18,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.search, size: 20),
          onPressed: onJumpToPage,
          tooltip: 'Loncat ke halaman',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: MushafColors.goldAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          onSelected: (value) {
            if (value == 'download') {
              onDownload();
            } else if (value == 'clear') {
              onClearData();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(
                    controller.isDataDownloaded
                        ? Icons.sync_rounded
                        : Icons.download_rounded,
                    size: 18,
                    color: MushafColors.appBarBrown,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.isDataDownloaded
                        ? 'Update Data'
                        : 'Download Data',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            if (controller.isDataDownloaded)
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Hapus Data Offline'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}