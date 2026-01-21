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
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              currentSurahTitle ?? 'المصحف الشريف',
              style: const TextStyle(
                fontFamily: 'UthmaniHafs',
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'صفحة $currentPage',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              'جزء ${((currentPage - 1) ~/ 20) + 1}',
              style: TextStyle(
                color: Colors.grey.shade700,
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
          title: const Text('Loncat ke Halaman'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Masukkan nomor halaman (1–604)',
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
/// WIDGET HALAMAN MUSHAF
/// =======================
class MushafPageWidget extends StatelessWidget {
  final int pageNumber;
  final QuranPageService pageService;

  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.pageService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranVerse>>(
      future: pageService.fetchPage(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.brown),
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
          padding: const EdgeInsets.all(22),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                if (_isStartOfSurah(verses.first))
                  _buildSurahHeader(verses.first),
                if (_needsBismillah(verses.first)) _buildBismillah(),
                _buildVerses(verses),
                const SizedBox(height: 24),
                Text(
                  pageNumber.toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
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

  bool _needsBismillah(QuranVerse verse) {
    return verse.ayah == 1 && verse.surah != 1 && verse.surah != 9;
  }

  Widget _buildSurahHeader(QuranVerse verse) {
    final surah = SurahData.byNumber(verse.surah);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'سورة ${surah.arabic}',
            style: const TextStyle(
              fontFamily: 'UthmaniHafs',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            surah.latin,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 28,
          height: 2,
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
          fontSize: 26,
          height: 2.2,
          color: Colors.black87,
        ),
        children: verses.expand((v) {
          return [
            TextSpan(text: v.text),
            const TextSpan(text: ' '),
            TextSpan(
              text: '﴿${_toArabicNumber(v.ayah)}﴾ ',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown.shade700,
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  String _toArabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((e) => digits[int.parse(e)]).join();
  }
}
