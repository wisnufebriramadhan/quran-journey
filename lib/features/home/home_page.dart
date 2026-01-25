import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'package:quran_tracker/features/extentions.dart';
import 'package:quran_tracker/features/home/banner_list.dart';
import 'package:quran_tracker/features/quran/presentation/quran_audio_player_page.dart';
import 'package:quran_tracker/features/quran/audio_locator.dart';
import 'package:quran_tracker/features/quran/quran_audio_handler.dart';
import 'package:quran_tracker/features/prayer_time/prayer_time_provider.dart';
import '../../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late DateTime _ramadhanDate;
  late Timer _timer;
  Duration _remaining = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _selectedDockIndex = 0;

  late PageController _hadistPageController;
  late Timer _hadistAutoScrollTimer;
  int _currentHadistIndex = 0;

  @override
  void initState() {
    super.initState();
    _ramadhanDate = _getNextRamadhan();
    _updateCountdown();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();

    _hadistPageController = PageController(viewportFraction: 0.92);

    _hadistAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_hadistPageController.hasClients) {
        _currentHadistIndex = (_currentHadistIndex + 1) % dailyQuotes.length;
        _hadistPageController.animateToPage(
          _currentHadistIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      setState(() {
        _selectedDockIndex = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _hadistAutoScrollTimer.cancel();
    _hadistPageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  DateTime _getNextRamadhan() {
    final now = DateTime.now();
    DateTime ramadhan = DateTime(2026, 2, 18);
    if (now.isAfter(ramadhan)) {
      ramadhan = DateTime(2027, 2, 8);
    }
    return ramadhan;
  }

  void _updateCountdown() {
    setState(() {
      _remaining = _ramadhanDate.difference(DateTime.now());
    });
  }

  String two(int n) => n.toString().padLeft(2, '0');

  String formatDuration(Duration d) {
    if (d.isNegative) return 'Sekarang';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '$h jam $m menit' : '$m menit';
  }

  String formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  void _onDockTap(int index) {
    if (index == 0) {
      setState(() {
        _selectedDockIndex = 0;
      });
      return;
    }

    setState(() {
      _selectedDockIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.mushafDigital).then((_) {
          if (mounted) {
            setState(() {
              _selectedDockIndex = 0;
            });
          }
        });
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.quranLog).then((_) {
          if (mounted) {
            setState(() {
              _selectedDockIndex = 0;
            });
          }
        });
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.prayerTime).then((_) {
          if (mounted) {
            setState(() {
              _selectedDockIndex = 0;
            });
          }
        });
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.settings).then((_) {
          if (mounted) {
            setState(() {
              _selectedDockIndex = 0;
            });
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    _remaining.inHours.remainder(24);
    _remaining.inMinutes.remainder(60);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Enhanced Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 650,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3E2723),
                        Color(0xFF4A3428),
                        Color(0xFF5D4037),
                        Color(0xFF6D4C41),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Geometric Pattern Layer 1
                      CustomPaint(
                        painter: IslamicPatternPainter(),
                        size: const Size(double.infinity, 650),
                      ),
                      // Gradient Overlay for depth
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Star Pattern
                      CustomPaint(
                        painter: StarPatternPainter(),
                        size: const Size(double.infinity, 650),
                      ),
                      // Bottom gradient fade
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFF8F9FA).withOpacity(0.3),
                                const Color(0xFFF8F9FA),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      /// ================= HEADER =================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.wb_twilight_rounded,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Assalamualaikum',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Quran Journey',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            /// ===== CARD HIJRI + NEXT SHOLAT + RAMADHAN =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Hijri Date Section
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.2),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hari ini (Hijriah)',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              getHijriToday(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: Colors.amber.shade300,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '$days hari menuju Ramadhan',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.85),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Next Prayer Section
                                  Consumer<PrayerTimeProvider>(
                                    builder: (context, prayer, _) {
                                      if (prayer.nextPrayerName == null ||
                                          prayer.nextPrayerTime == null) {
                                        return const SizedBox.shrink();
                                      }

                                      return Column(
                                        children: [
                                          const SizedBox(height: 20),
                                          Container(
                                            height: 1.5,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.0),
                                                  Colors.white.withOpacity(0.4),
                                                  Colors.white.withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.amber.shade300
                                                          .withOpacity(0.4),
                                                      Colors.amber.shade400
                                                          .withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .notifications_active_rounded,
                                                  color: Colors.amber.shade100,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Sholat Berikutnya',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${prayer.nextPrayerName} • ${formatTime(prayer.nextPrayerTime!)}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      formatDuration(prayer
                                                          .remainingToNextPrayer),
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.75),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ===== MURATTAL PLAYER CONTROL =====
                            const _MurattalPlayerWidget(),
                          ],
                        ),
                      ),

                      /// ================= MODERN BANNER HADIST/DOA =================
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: PageView.builder(
                          controller: _hadistPageController,
                          itemCount: dailyQuotes.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentHadistIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final quote = dailyQuotes[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 16, bottom: 8),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1A237E),
                                      Color(0xFF283593),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// HEADER
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              quote['type'] == 'Hadist'
                                                  ? Icons.menu_book
                                                  : quote['type'] == 'Doa'
                                                      ? Icons.favorite
                                                      : Icons.auto_stories,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              quote['type']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: List.generate(
                                            dailyQuotes.length,
                                            (dotIndex) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              width: dotIndex == index ? 18 : 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: dotIndex == index
                                                    ? Colors.amber
                                                    : Colors.white
                                                        .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(2.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    /// TEXT
                                    Expanded(
                                      child: Center(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '"${quote['text']}"',
                                                textAlign: TextAlign.center,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  height: 1.5,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '- ${quote['source']} -',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      /// ================= MODERN MENU GRID (2x3) =================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                        child: GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                          children: [
                            _ModernMenuGrid(
                              icon: Icons.menu_book_rounded,
                              label: 'Mushaf',
                              color: const Color(0xFF6D4C41),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.mushafDigital),
                            ),
                            _ModernMenuGrid(
                              icon: Icons.edit_note_rounded,
                              label: 'Catatan',
                              color: const Color(0xFF7B5E57),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.quranLog),
                            ),
                            _ModernMenuGrid(
                              icon: Icons.school_rounded,
                              label: 'Belajar',
                              color: const Color(0xFF8D6E63),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.learning),
                            ),
                            _ModernMenuGrid(
                              icon: Icons.mosque_rounded,
                              label: 'Sholat',
                              color: const Color(0xFFa1887f),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.prayerTime),
                            ),
                            _ModernMenuGrid(
                              icon: Icons.headphones_rounded,
                              label: 'Audio',
                              color: const Color(0xFFB39DDB),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const QuranAudioPlayerPage(
                                      initialSurah: 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _ModernMenuGrid(
                              icon: Icons.settings_rounded,
                              label: 'Setelan',
                              color: const Color(0xFFBCAAA4),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.settings),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              /// ================= DOCK MENU =================
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4A3428),
                        Color(0xFF5D4037),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5D4037).withOpacity(0.5),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DockItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isSelected: _selectedDockIndex == 0,
                        onTap: () => _onDockTap(0),
                      ),
                      _DockItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Mushaf',
                        isSelected: _selectedDockIndex == 1,
                        onTap: () => _onDockTap(1),
                      ),
                      _DockItem(
                        icon: Icons.edit_note_rounded,
                        label: 'Catatan',
                        isSelected: _selectedDockIndex == 2,
                        onTap: () => _onDockTap(2),
                      ),
                      _DockItem(
                        icon: Icons.mosque_rounded,
                        label: 'Sholat',
                        isSelected: _selectedDockIndex == 3,
                        onTap: () => _onDockTap(3),
                      ),
                      _DockItem(
                        icon: Icons.settings_rounded,
                        label: 'Setting',
                        isSelected: _selectedDockIndex == 4,
                        onTap: () => _onDockTap(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= MURATTAL PLAYER WIDGET =================
class _MurattalPlayerWidget extends StatefulWidget {
  const _MurattalPlayerWidget();

  @override
  State<_MurattalPlayerWidget> createState() => _MurattalPlayerWidgetState();
}

class _MurattalPlayerWidgetState extends State<_MurattalPlayerWidget> {
  late final QuranAudioHandler handler;

  @override
  void initState() {
    super.initState();
    handler = audioHandler as QuranAudioHandler;
  }

  void _openFullPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranAudioPlayerPage(
          initialSurah: handler.currentSurah,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullPlayer,
      child: StreamBuilder<MediaItem?>(
        stream: handler.mediaItem,
        builder: (context, mediaSnapshot) {
          return StreamBuilder<PlaybackState>(
              stream: handler.playbackState,
              builder: (context, playbackSnapshot) {
                final mediaItem = mediaSnapshot.data;
                final playbackState = playbackSnapshot.data;
                final isPlaying = playbackState?.playing ?? false;
                final processingState =
                    playbackState?.processingState ?? AudioProcessingState.idle;

                return StreamBuilder<Duration>(
                  stream: handler.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration = mediaItem?.duration ?? Duration.zero;
                    final progress = duration.inSeconds > 0
                        ? position.inSeconds / duration.inSeconds
                        : 0.0;

                    final surahName = mediaItem?.title ?? 'Al-Fatihah';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6D4C41),
                            Color(0xFF5D4037),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D4037).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (processingState ==
                                  AudioProcessingState.idle) {
                                handler.loadSurah(surah: 1, autoPlay: true);
                              } else if (isPlaying) {
                                handler.pause();
                              } else {
                                handler.play();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.95),
                                    Colors.white.withOpacity(0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                processingState ==
                                            AudioProcessingState.loading ||
                                        processingState ==
                                            AudioProcessingState.buffering
                                    ? Icons.hourglass_empty_rounded
                                    : isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                color: const Color(0xFF5D4037),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        surahName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.open_in_full_rounded,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 14,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 4,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.amber.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Row(
                            children: [
                              _MiniPlayerButton(
                                icon: Icons.skip_previous_rounded,
                                onTap: () {
                                  handler.skipToPrevious();
                                },
                              ),
                              const SizedBox(width: 8),
                              _MiniPlayerButton(
                                icon: Icons.skip_next_rounded,
                                onTap: () {
                                  handler.skipToNext();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
        },
      ),
    );
  }
}

/// ================= MINI PLAYER BUTTON =================
class _MiniPlayerButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniPlayerButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_MiniPlayerButton> createState() => _MiniPlayerButtonState();
}

class _MiniPlayerButtonState extends State<_MiniPlayerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

/// ================= ISLAMIC PATTERN PAINTER =================
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 80.0;
    const radius1 = 25.0;
    const radius2 = 12.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius1, paint);
        canvas.drawCircle(Offset(x, y), radius2, paint);

        final paint2 = Paint()
          ..color = Colors.white.withOpacity(0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawLine(
          Offset(x - radius1, y),
          Offset(x + radius1, y),
          paint2,
        );
        canvas.drawLine(
          Offset(x, y - radius1),
          Offset(x, y + radius1),
          paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ================= STAR PATTERN PAINTER =================
class StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final random = Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 2.0 + random.nextDouble() * 3;

      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final angle = (pi * 2) / points;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? size : size / 2;
      final currentAngle = angle * i - pi / 2;
      final x = center.dx + cos(currentAngle) * r;
      final y = center.dy + sin(currentAngle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ================= DOCK ITEM =================
class _DockItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white.withOpacity(0.25)
              : _isPressed
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          widget.icon,
          color:
              widget.isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          size: widget.isSelected ? 28 : 26,
        ),
      ),
    );
  }
}

/// ================= MODERN MENU GRID =================
class _ModernMenuGrid extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernMenuGrid({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModernMenuGrid> createState() => _ModernMenuGridState();
}

class _ModernMenuGridState extends State<_ModernMenuGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
