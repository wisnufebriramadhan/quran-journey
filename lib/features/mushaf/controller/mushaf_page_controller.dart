import 'package:flutter/material.dart';
import '../../../core/models/quran_verse.dart';
import '../../../core/models/surah_data.dart';
import '../data/quran_page_service.dart';
import '../data/quran_download_service.dart';
import '../data/download_quran_dialog.dart';

/// Controller untuk Mushaf Page View - mengelola logika bisnis dan state
class MushafPageController {
  final QuranPageService _pageService = QuranPageService();
  final QuranDownloadService _downloadService = QuranDownloadService();

  late PageController pageController;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  int currentPage = 1;
  String? currentSurahTitle;
  bool isDataDownloaded = false;
  bool showOverlay = true;
  bool isNightMode = false;
  bool isComfortReading = true;

  // Callback untuk update UI
  VoidCallback? onStateChanged;

  void initialize({
    required int initialPage,
    required TickerProvider vsync,
    VoidCallback? onStateChanged,
  }) {
    this.onStateChanged = onStateChanged;
    currentPage = initialPage;
    pageController = PageController(initialPage: initialPage - 1);

    fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    );

    loadSurahTitle(initialPage);
    checkDownloadStatus();

    // Auto-hide overlay setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      showOverlay = false;
      notifyListeners();
    });
  }

  void dispose() {
    pageController.dispose();
    fadeController.dispose();
  }

  Future<void> checkDownloadStatus() async {
    isDataDownloaded = await _pageService.isDataDownloaded();
    notifyListeners();
  }

  Future<void> loadSurahTitle(int page) async {
    fadeController.forward(from: 0.0);
    final verses = await _pageService.fetchPage(page);

    if (verses.isEmpty) return;

    final surahInfo = SurahData.byNumber(verses.first.surah);
    currentSurahTitle = surahInfo.latin;
    notifyListeners();
  }

  void onPageChanged(int index) {
    final page = index + 1;
    currentPage = page;
    showOverlay = true;
    notifyListeners();

    loadSurahTitle(page);

    Future.delayed(const Duration(seconds: 2), () {
      showOverlay = false;
      notifyListeners();
    });
  }

  void toggleOverlay() {
    showOverlay = !showOverlay;
    notifyListeners();
  }

  void toggleNightMode() {
    isNightMode = !isNightMode;
    notifyListeners();
  }

  void toggleComfortReading() {
    isComfortReading = !isComfortReading;
    notifyListeners();
  }

  int get currentJuz => ((currentPage - 1) ~/ 20) + 1;

  Future<bool> handleDownloadRequest(BuildContext context) async {
    final confirmed = await showDownloadQuranDialog(context);
    return confirmed;
  }

  Future<void> startDownload(
    BuildContext context, {
    required VoidCallback onComplete,
    required VoidCallback onError,
  }) async {
    startBackgroundDownload(
      context,
      onComplete: () {
        isDataDownloaded = true;
        notifyListeners();
        onComplete();
      },
      onError: onError,
    );
  }

  Future<void> clearData() async {
    await _downloadService.clearDownloadedData();
    isDataDownloaded = false;
    notifyListeners();
  }

  void jumpToPage(int page) {
    if (page >= 1 && page <= 604) {
      pageController.jumpToPage(page - 1);
    }
  }

  Future<List<QuranVerse>> fetchPageVerses(int pageNumber) {
    return _pageService.fetchPage(pageNumber);
  }

  void notifyListeners() {
    onStateChanged?.call();
  }

  
}
