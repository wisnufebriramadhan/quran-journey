import 'package:flutter/material.dart';
import '../../../core/models/quran_verse.dart';
import '../../../core/models/surah_data.dart';
import '../data/quran_page_service.dart';
import '../data/quran_download_service.dart';
import '../data/download_quran_dialog.dart';

class MushafPageView extends StatefulWidget {
  final int initialPage;

  const MushafPageView({
    super.key,
    this.initialPage = 1,
  });

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView> {
  final QuranPageService _pageService = QuranPageService();
  final QuranDownloadService _downloadService = QuranDownloadService();
  late PageController _pageController;

  int currentPage = 1;
  String? currentSurahTitle;
  bool _isDataDownloaded = false;

  // 🎨 ENHANCED COLOR SYSTEM
  static const bgPaper = Color(0xFFFAF8F3);
  static const appBarBrown = Color(0xFF2C1810);
  static const accentGold = Color(0xFFD4AF37);
  static const textPrimary = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _loadSurahTitle(widget.initialPage);
    _checkDownloadStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await _pageService.isDataDownloaded();
    if (mounted) {
      setState(() {
        _isDataDownloaded = isDownloaded;
      });
    }
  }

  Future<void> _loadSurahTitle(int page) async {
    final verses = await _pageService.fetchPage(page);
    if (!mounted || verses.isEmpty) return;

    final surahInfo = SurahData.byNumber(verses.first.surah);
    setState(() {
      currentSurahTitle = 'سورة ${surahInfo.arabic}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPaper,
      appBar: AppBar(
        backgroundColor: appBarBrown,
        foregroundColor: accentGold,
        centerTitle: true,
        elevation: 0,
        title: Column(
          children: [
            Text(
              currentSurahTitle ?? 'المصحف الشريف',
              style: const TextStyle(
                fontFamily: 'UthmaniHafs',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: accentGold,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isDataDownloaded)
            IconButton(
              icon: const Icon(Icons.cloud_download, color: accentGold),
              onPressed: _showDownloadDialog,
              tooltip: 'Download untuk offline',
            ),
          if (_isDataDownloaded)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentGold.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.offline_bolt, size: 14, color: accentGold),
                      SizedBox(width: 4),
                      Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 11,
                          color: accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search, color: accentGold),
            onPressed: _showJumpToPage,
            tooltip: 'Loncat ke halaman',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: accentGold),
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
                      _isDataDownloaded ? Icons.refresh : Icons.cloud_download,
                      size: 20,
                      color: appBarBrown,
                    ),
                    const SizedBox(width: 12),
                    Text(_isDataDownloaded ? 'Update Data' : 'Download Data'),
                  ],
                ),
              ),
              if (_isDataDownloaded)
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Hapus Data Offline'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),

      /// 📖 PAGE VIEW WITH GRADIENT BACKGROUND
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgPaper,
              const Color(0xFFF5F0E8),
            ],
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          reverse: true,
          itemCount: 604,
          onPageChanged: (index) {
            final page = index + 1;
            setState(() => currentPage = page);
            _loadSurahTitle(page);
          },
          itemBuilder: (context, index) {
            return MushafPageWidget(
              pageNumber: index + 1,
              pageService: _pageService,
            );
          },
        ),
      ),

      /// 🔢 ENHANCED BOTTOM INFO
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appBarBrown,
              appBarBrown.withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomInfo(
                  icon: Icons.menu_book,
                  label: 'صفحة',
                  value: currentPage.toString(),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: accentGold.withOpacity(0.3),
                ),
                _buildBottomInfo(
                  icon: Icons.bookmark,
                  label: 'جزء',
                  value: '${((currentPage - 1) ~/ 20) + 1}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accentGold),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: accentGold.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDownloadDialog() async {
    final confirmed = await showDownloadQuranDialog(context);
    if (!confirmed || !mounted) return;

    startBackgroundDownload(
      context,
      onComplete: () {
        if (mounted) {
          setState(() => _isDataDownloaded = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'Download selesai! Mushaf siap digunakan offline.'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      onError: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Download gagal. Silakan coba lagi.')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                  child: Text(
                      'Download dimulai... Anda bisa tetap menggunakan app.')),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showClearDataDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Offline?'),
        content: const Text(
          'Data Mushaf yang sudah di-download akan dihapus. '
          'Anda perlu download ulang untuk menggunakan fitur offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _downloadService.clearDownloadedData();
      if (mounted) {
        setState(() => _isDataDownloaded = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data offline berhasil dihapus')),
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
          backgroundColor: bgPaper,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.arrow_forward, color: accentGold, size: 20),
              const SizedBox(width: 8),
              const Text('Loncat ke Halaman'),
            ],
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1 – 604',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentGold.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: accentGold, width: 2),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarBrown,
                foregroundColor: accentGold,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page >= 1 && page <= 604) {
                  _pageController.jumpToPage(page - 1);
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

/// =======================
/// 📄 ENHANCED MUSHAF PAGE
/// =======================
class MushafPageWidget extends StatelessWidget {
  final int pageNumber;
  final QuranPageService pageService;

  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.pageService,
  });

  static const accentBrown = Color(0xFF8B5E3C);
  static const goldBrown = Color(0xFFD4AF37);
  static const textPrimary = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranVerse>>(
      future: pageService.fetchPage(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: goldBrown, strokeWidth: 3),
                const SizedBox(height: 16),
                Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    fontFamily: 'UthmaniHafs',
                    fontSize: 18,
                    color: accentBrown.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                const Text('Gagal memuat halaman'),
              ],
            ),
          );
        }

        final verses = snapshot.data ?? [];
        if (verses.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    _buildVerses(verses),
                    const SizedBox(height: 32),
                    _buildPageNumber(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageNumber() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: goldBrown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldBrown.withOpacity(0.3)),
      ),
      child: Text(
        pageNumber.toString(),
        style: const TextStyle(
          color: accentBrown,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildBismillah(int surahNumber) {
    if (surahNumber == 1 || surahNumber == 9) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 30,
          height: 1.8,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _buildVerses(List<QuranVerse> verses) {
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 28,
          height: 2.4,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
        children: verses.expand((v) {
          final spans = <InlineSpan>[];

          if (v.ayah == 1) {
            final surah = SurahData.byNumber(v.surah);

            spans.add(
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Column(
                    children: [
                      // Ornamental divider top
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    goldBrown.withOpacity(0.5),
                                    goldBrown,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: goldBrown,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    goldBrown,
                                    goldBrown.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Surah name container
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              goldBrown.withOpacity(0.15),
                              goldBrown.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: goldBrown.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'سورة ${surah.arabic}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'UthmaniHafs',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: accentBrown,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              surah.latin,
                              style: TextStyle(
                                fontSize: 14,
                                color: accentBrown.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ornamental divider bottom
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    goldBrown.withOpacity(0.5),
                                    goldBrown,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: goldBrown,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    goldBrown,
                                    goldBrown.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildBismillah(verses.first.surah),
                    ],
                  ),
                ),
              ),
            );
          }

          spans.add(TextSpan(text: v.text));
          spans.add(const TextSpan(text: ' '));
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      goldBrown.withOpacity(0.15),
                      goldBrown.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goldBrown.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '﴿${_toArabicNumber(v.ayah)}﴾',
                  style: const TextStyle(
                    fontFamily: 'UthmaniHafs',
                    fontSize: 20,
                    color: accentBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
          spans.add(const TextSpan(text: ' '));

          return spans;
        }).toList(),
      ),
    );
  }

  String _toArabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((e) => digits[int.parse(e)]).join();
  }
}
