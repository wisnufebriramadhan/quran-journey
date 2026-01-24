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

class _MushafPageViewState extends State<MushafPageView>
    with SingleTickerProviderStateMixin {
  final QuranPageService _pageService = QuranPageService();
  final QuranDownloadService _downloadService = QuranDownloadService();
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int currentPage = 1;
  String? currentSurahTitle;
  bool _isDataDownloaded = false;
  bool _showOverlay = true;

  // 🎨 ENHANCED MUSHAF COLOR SYSTEM
  static const bgPage = Color(0xFFFAF6ED);
  static const appBarBrown = Color(0xFF3E2723);
  static const goldAccent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _loadSurahTitle(widget.initialPage);
    _checkDownloadStatus();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Hide overlay after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await _pageService.isDataDownloaded();
    if (mounted) {
      setState(() => _isDataDownloaded = isDownloaded);
    }
  }

  Future<void> _loadSurahTitle(int page) async {
    _fadeController.forward(from: 0.0);
    final verses = await _pageService.fetchPage(page);
    if (!mounted || verses.isEmpty) return;

    final surahInfo = SurahData.byNumber(verses.first.surah);
    setState(() {
      currentSurahTitle = surahInfo.latin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: appBarBrown,
        foregroundColor: goldAccent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                currentSurahTitle ?? 'Al-Qur\'an',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
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
                'Juz ${((currentPage - 1) ~/ 20) + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (!_isDataDownloaded)
            IconButton(
              icon: const Icon(Icons.cloud_download_outlined, size: 22),
              onPressed: _showDownloadDialog,
              tooltip: 'Download untuk offline',
            ),
          if (_isDataDownloaded)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.offline_bolt,
                  color: Colors.greenAccent,
                  size: 18,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: _showJumpToPage,
            tooltip: 'Loncat ke halaman',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: goldAccent),
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
                      _isDataDownloaded ? Icons.sync : Icons.download,
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
      body: Stack(
        children: [
          // Page viewer
          PageView.builder(
            controller: _pageController,
            reverse: true,
            itemCount: 604,
            onPageChanged: (index) {
              final page = index + 1;
              setState(() {
                currentPage = page;
                _showOverlay = true;
              });
              _loadSurahTitle(page);

              // Auto hide overlay
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() => _showOverlay = false);
                }
              });
            },
            itemBuilder: (context, index) {
              return MushafPageWidget(
                pageNumber: index + 1,
                pageService: _pageService,
              );
            },
          ),

          // Page indicator overlay
          if (_showOverlay)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: appBarBrown.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: goldAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Halaman $currentPage dari 604',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: appBarBrown,
        foregroundColor: goldAccent,
        onPressed: () {
          setState(() => _showOverlay = !_showOverlay);
        },
        child: Icon(_showOverlay ? Icons.visibility_off : Icons.visibility),
      ),
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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Download selesai! Mushaf siap offline.'),
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
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Download gagal. Silakan coba lagi.'),
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
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Hapus Data Offline?'),
          ],
        ),
        content: const Text(
          'Data Mushaf yang sudah di-download akan dihapus dari perangkat Anda.',
          style: TextStyle(height: 1.5),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
          SnackBar(
            content: const Text('Data offline berhasil dihapus'),
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
          title: const Row(
            children: [
              Icon(Icons.vertical_align_center, color: goldAccent),
              SizedBox(width: 12),
              Text('Loncat ke Halaman'),
            ],
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1 – 604',
              prefixIcon: const Icon(Icons.numbers),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: goldAccent, width: 2),
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
                foregroundColor: goldAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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

/// ===================================
/// 📄 ENHANCED MUSHAF PAGE WIDGET
/// ===================================
class MushafPageWidget extends StatelessWidget {
  final int pageNumber;
  final QuranPageService pageService;

  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.pageService,
  });

  static const bgPage = Color(0xFFFAF6ED);
  static const textColor = Color(0xFF1A1A1A);
  static const ayahCircleColor = Color(0xFF2E7D7D);
  static const goldAccent = Color(0xFFD4AF37);

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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    color: ayahCircleColor,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Memuat halaman $pageNumber...',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 14,
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
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final verses = snapshot.data ?? [];
        if (verses.isEmpty) {
          return const Center(
            child: Text('Tidak ada data'),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: bgPage,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Decorative top border
                  _buildDecorativeBorder(),
                  const SizedBox(height: 16),

                  // Main content
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: _buildVerses(verses),
                  ),

                  const SizedBox(height: 32),

                  // Decorative bottom border
                  _buildDecorativeBorder(),
                  const SizedBox(height: 16),

                  // Page number with ornamental circle
                  _buildPageNumber(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeBorder() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            goldAccent.withOpacity(0.5),
            goldAccent,
            goldAccent.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildPageNumber() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ornamental circle background
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: goldAccent,
              width: 2,
            ),
            color: bgPage,
            boxShadow: [
              BoxShadow(
                color: goldAccent.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: goldAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        Text(
          pageNumber.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
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
          height: 2.2,
          color: textColor,
          letterSpacing: 0.3,
        ),
        children: verses.expand((v) {
          final spans = <InlineSpan>[];

          // Header surah jika ayat pertama
          if (v.ayah == 1) {
            spans.add(
              WidgetSpan(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildSurahHeader(v.surah),
                    const SizedBox(height: 20),
                    if (v.surah != 1 && v.surah != 9) _buildBismillah(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          }

          // Teks ayat
          spans.add(TextSpan(text: v.text));
          spans.add(const TextSpan(text: ' '));

          // Nomor ayat dengan circle
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _buildAyahNumber(v.ayah),
            ),
          );
          spans.add(const TextSpan(text: ' '));

          return spans;
        }).toList(),
      ),
    );
  }

  Widget _buildSurahHeader(int surahNumber) {
    final surah = SurahData.byNumber(surahNumber);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Enhanced ornamental pattern
            CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _EnhancedSurahHeaderPainter(),
            ),
            // Text overlay with shadow
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'سُورَةُ ${surah.arabic}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmaniHafs',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: [
                        Shadow(
                          color: goldAccent.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.latin,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBismillah() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: goldAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 26,
          height: 2.0,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAyahNumber(int ayahNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ayahCircleColor.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Outer circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ayahCircleColor,
                width: 1.8,
              ),
              color: bgPage,
            ),
          ),
          // Inner decorative circle
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ayahCircleColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // Nomor ayat
          Text(
            _toArabicNumber(ayahNumber),
            style: const TextStyle(
              fontFamily: 'UthmaniHafs',
              fontSize: 15,
              color: ayahCircleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((e) => digits[int.parse(e)]).join();
  }
}

/// ===================================
/// ENHANCED CUSTOM PAINTER
/// ===================================
class _EnhancedSurahHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Gradient background
    const gradient = LinearGradient(
      colors: [
        Color(0xFFF0E6D2),
        Color(0xFFE8DCC8),
        Color(0xFFF0E6D2),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Golden borders
    paint.shader = null;
    paint.color = const Color(0xFFD4AF37);
    paint.strokeWidth = 2.5;
    paint.style = PaintingStyle.stroke;

    // Top border with decorative pattern
    canvas.drawLine(Offset(0, 3), Offset(size.width, 3), paint);
    canvas.drawLine(
        Offset(0, 6), Offset(size.width, 6), paint..strokeWidth = 1);

    // Bottom border
    canvas.drawLine(
      Offset(0, size.height - 6),
      Offset(size.width, size.height - 6),
      paint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(0, size.height - 3),
      Offset(size.width, size.height - 3),
      paint..strokeWidth = 2.5,
    );

    // Decorative corner ornaments
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF2E7D7D).withOpacity(0.3);

    // Corner flowers
    const cornerSize = 12.0;
    final corners = [
      Offset(cornerSize, cornerSize),
      Offset(size.width - cornerSize, cornerSize),
      Offset(cornerSize, size.height - cornerSize),
      Offset(size.width - cornerSize, size.height - cornerSize),
    ];

    for (final corner in corners) {
      // Draw decorative flower pattern
      for (var i = 0; i < 6; i++) {
        final petalPath = Path()
          ..addOval(Rect.fromCenter(
            center: Offset(
              corner.dx + 6 * (i % 2 == 0 ? 1 : 0.7) * (i < 3 ? 1 : -1),
              corner.dy + 6 * (i % 2 == 0 ? 1 : 0.7) * (i < 3 ? 1 : -1),
            ),
            width: 4,
            height: 4,
          ));
        canvas.drawPath(petalPath, paint);
      }
    }

    // Central decorative elements
    paint.color = const Color(0xFFD4AF37).withOpacity(0.2);
    const spacing = 60.0;
    for (double x = spacing; x < size.width - spacing; x += spacing) {
      // Top diamonds
      final diamondPath = Path()
        ..moveTo(x, 12)
        ..lineTo(x + 5, 16)
        ..lineTo(x, 20)
        ..lineTo(x - 5, 16)
        ..close();
      canvas.drawPath(diamondPath, paint);

      // Bottom diamonds
      final diamondPath2 = Path()
        ..moveTo(x, size.height - 12)
        ..lineTo(x + 5, size.height - 16)
        ..lineTo(x, size.height - 20)
        ..lineTo(x - 5, size.height - 16)
        ..close();
      canvas.drawPath(diamondPath2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
