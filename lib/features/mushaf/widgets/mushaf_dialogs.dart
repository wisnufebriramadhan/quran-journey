import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_colors.dart';
import 'package:quran_tracker/features/shimmer_loading_dialog.dart';

/// Class untuk menangani semua dialog di Mushaf Page
class MushafDialogs {
  /// Dialog untuk download data
  static Future<void> showDownload(
    BuildContext context,
    MushafPageController controller,
  ) async {
    final confirmed = await controller.handleDownloadRequest(context);
    if (!confirmed || !context.mounted) return;

    // Tampilkan snackbar bahwa download dimulai di background
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Mengunduh data Mushaf di background...')),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    controller.startDownload(
      context,
      onComplete: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text('Download selesai! Mushaf siap offline.')),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      onError: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Download gagal. Silakan coba lagi.')),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );
  }

  /// Dialog untuk clear data offline
  static Future<void> showClearData(
    BuildContext context,
    MushafPageController controller,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text(
              'Hapus Data Offline?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        content: const Text(
          'Data Mushaf yang sudah di-download akan dihapus dari perangkat Anda.',
          style: TextStyle(height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Tampilkan loading dialog
      ShimmerLoadingDialog.show(
        context,
        message: 'Menghapus data...',
      );

      await controller.clearData();

      // Sembunyikan loading dialog
      if (context.mounted) {
        ShimmerLoadingDialog.hide(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.delete_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Data offline berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.grey.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Dialog untuk jump to page
  static void showJumpToPage(
    BuildContext context,
    MushafPageController controller,
  ) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.vertical_align_center_rounded,
                  color: MushafColors.secondaryBrown),
              SizedBox(width: 12),
              Text(
                'Loncat ke Halaman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1 – 604',
              prefixIcon: const Icon(Icons.numbers_rounded),
              prefixIconColor: MushafColors.secondaryBrown,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: MushafColors.secondaryBrown,
                  width: 2,
                ),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MushafColors.secondaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final page = int.tryParse(textController.text);
                if (page != null) {
                  controller.jumpToPage(page);
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}