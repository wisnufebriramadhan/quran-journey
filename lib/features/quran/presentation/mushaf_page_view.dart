import 'package:flutter/material.dart';
import '../../../core/models/quran_verse.dart';
import '../../../core/models/surah_data.dart';
import '../data/quran_page_service.dart';

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
  late PageController _pageController;

  int currentPage = 1;
  String? currentSurahTitle;

  // 🎨 COLOR SYSTEM (MUSHAF BROWN)
  static const bgPaper = Color(0xFFF4EFE6);
  static const appBarBrown = Color(0xFF4A3322);

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _loadSurahTitle(widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        title: Column(
          children: [
            Text(
              currentSurahTitle ?? 'المصحف الشريف',
              style: const TextStyle(
                fontFamily: 'UthmaniHafs',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showJumpToPage,
            tooltip: 'Loncat ke halaman',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur bookmark segera hadir')),
              );
            },
          ),
        ],
      ),

      /// 📖 PAGE VIEW
      body: PageView.builder(
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

      /// 🔢 BOTTOM INFO
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2),
          border: Border(
            top: BorderSide(color: Colors.brown.shade200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'صفحة $currentPage',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              'جزء ${((currentPage - 1) ~/ 20) + 1}',
              style: TextStyle(
                color: Colors.brown.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJumpToPage() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgPaper,
          title: const Text('Loncat ke Halaman'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '1 – 604',
              border: OutlineInputBorder(),
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
/// 📄 WIDGET HALAMAN MUSHAF
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
  static const goldBrown = Color(0xFFC8A45D);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranVerse>>(
      future: pageService.fetchPage(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: accentBrown),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat halaman'));
        }

        final verses = snapshot.data ?? [];
        if (verses.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // if (_isStartOfSurah(verses.first))
                //   _buildSurahHeader(verses.first),
                // if (_isStartOfSurah(verses.first))
                //   _buildBismillah(verses.first.surah),
                _buildVerses(verses),
                const SizedBox(height: 28),
                Text(
                  pageNumber.toString(),
                  style: TextStyle(
                    color: Colors.brown.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isStartOfSurah(QuranVerse verse) => verse.ayah == 1;

  bool _needsBismillah(QuranVerse verse) =>
      verse.ayah == 1 && verse.surah != 1 && verse.surah != 9;

  Widget _buildSurahHeader(QuranVerse verse) {
    final surah = SurahData.byNumber(verse.surah);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldBrown, width: 1.8),
      ),
      child: Column(
        children: [
          Text(
            'سورة ${surah.arabic}',
            style: const TextStyle(
              fontFamily: 'UthmaniHafs',
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            surah.latin,
            style: TextStyle(color: Colors.brown.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah(int surahNumber) {
    // Surah 1 (Al-Fatihah) dan 9 (At-Taubah) tidak butuh header Bismillah tambahan
    // Al-Fatihah karena Bismillah adalah ayat ke-1, At-Taubah memang tidak ada Bismillah.
    if (surahNumber == 1 || surahNumber == 9) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      child: const Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 28,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildVerses(List<QuranVerse> verses) {
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 26,
          height: 2.25,
          color: Colors.black87,
        ),
        children: verses.expand((v) {
          final spans = <InlineSpan>[];

          // ✅ JIKA AWAL SURAH (DI MANA PUN POSISINYA)
          if (v.ayah == 1) {
            final surah = SurahData.byNumber(v.surah);

            // 🕌 DIVIDER ALA MUSHAF MADINAH
            spans.add(
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFD8C3A5),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.local_florist,
                              size: 18,
                              color: Color(0xFFC8A45D),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFD8C3A5),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 📜 HEADER SURAH
                      Text(
                        'سورة ${surah.arabic}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'UthmaniHafs',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.latin,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFD8C3A5),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.local_florist,
                              size: 18,
                              color: Color(0xFFC8A45D),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFD8C3A5),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildBismillah(verses.first.surah),
                    ],
                  ),
                ),
              ),
            );
          }

          // 📖 AYAT
          spans.add(TextSpan(text: v.text));
          spans.add(const TextSpan(text: ' '));
          spans.add(
            TextSpan(
              text: '﴿${_toArabicNumber(v.ayah)}﴾ ',
              style: const TextStyle(
                fontSize: 20,
                color: accentBrown,
              ),
            ),
          );

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
