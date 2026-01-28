import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'widgets/mushaf_page_widget.dart';

/// View untuk Mushaf Page - hanya menangani tampilan UI utama
class MushafPageView extends StatefulWidget {
  final int initialPage;

  const MushafPageView({
    super.key,
    this.initialPage = 1,
  });

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView>
    with SingleTickerProviderStateMixin {
  late MushafPageController _controller;

  // 🎨 ENHANCED COLOR SYSTEM
  static const appBarBrown = Color(0xFF3E2723);
  static const secondaryBrown = Color(0xFF6D4C41);
  static const goldAccent = Color(0xFFD4AF37);
  static const lightBg = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _controller = MushafPageController();
    _controller.initialize(
      initialPage: widget.initialPage,
      vsync: this,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appBarBrown,
      foregroundColor: goldAccent,
      elevation: 0,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  _controller.currentSurahTitle ?? 'Memuat...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: goldAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: goldAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Juz ${_controller.currentJuz}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: goldAccent,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (!_controller.isDataDownloaded)
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined, size: 20),
            onPressed: _showDownloadDialog,
            tooltip: 'Download untuk offline',
          ),
        if (_controller.isDataDownloaded)
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
          onPressed: _showJumpToPage,
          tooltip: 'Loncat ke halaman',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: goldAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'download') {
              _showDownloadDialog();
            } else if (value == 'clear') {
              _showClearDataDialog();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(
                    _controller.isDataDownloaded
                        ? Icons.sync_rounded
                        : Icons.download_rounded,
                    size: 18,
                    color: appBarBrown,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _controller.isDataDownloaded
                        ? 'Update Data'
                        : 'Download Data',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            if (_controller.isDataDownloaded)
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

  Widget _buildBody() {
    return Stack(
      children: [
        // Page viewer
        PageView.builder(
          controller: _controller.pageController,
          reverse: true,
          itemCount: 604,
          onPageChanged: _controller.onPageChanged,
          itemBuilder: (context, index) {
            return MushafPageWidget(
              pageNumber: index + 1,
              controller: _controller,
            );
          },
        ),

        // Page indicator overlay
        if (_controller.showOverlay)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _controller.fadeAnimation,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appBarBrown.withOpacity(0.95),
                        secondaryBrown.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: goldAccent.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: goldAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Halaman ${_controller.currentPage} dari 604',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.small(
      backgroundColor: secondaryBrown,
      foregroundColor: goldAccent,
      elevation: 4,
      onPressed: _controller.toggleOverlay,
      child: Icon(
        _controller.showOverlay
            ? Icons.visibility_off_rounded
            : Icons.visibility_rounded,
        size: 18,
      ),
    );
  }

  Future<void> _showDownloadDialog() async {
    final confirmed = await _controller.handleDownloadRequest(context);
    if (!confirmed || !mounted) return;

    _controller.startDownload(
      context,
      onComplete: () {
        if (mounted) {
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
        if (mounted) {
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

  Future<void> _showClearDataDialog() async {
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
      await _controller.clearData();
      if (mounted) {
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

  void _showJumpToPage() {
    final controller = TextEditingController();
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
                  color: Color(0xFF6D4C41)),
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
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1 – 604',
              prefixIcon: const Icon(Icons.numbers_rounded),
              prefixIconColor: const Color(0xFF6D4C41),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6D4C41),
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
                backgroundColor: const Color(0xFF6D4C41),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null) {
                  _controller.jumpToPage(page);
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
