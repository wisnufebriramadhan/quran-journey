import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_tracker/features/murattal/controller/audio_locator.dart';
import 'package:quran_tracker/features/murattal/widgets/background_decoration.dart.dart';
import 'package:quran_tracker/features/murattal/controller/quran_audio_handler.dart';
import 'package:quran_tracker/features/murattal/widgets/audio_player_controls.dart';
import 'package:quran_tracker/features/murattal/widgets/audio_player_icon.dart';
import 'package:quran_tracker/features/murattal/widgets/audio_player_info.dart';
import 'package:quran_tracker/features/murattal/widgets/audio_player_progress.dart';
// Import background yang baru

class QuranAudioPlayerPage extends StatefulWidget {
  final int initialSurah;

  const QuranAudioPlayerPage({
    super.key,
    required this.initialSurah,
  });

  @override
  State<QuranAudioPlayerPage> createState() => _QuranAudioPlayerPageState();
}

class _QuranAudioPlayerPageState extends State<QuranAudioPlayerPage>
    with TickerProviderStateMixin {
  late final QuranAudioHandler handler;
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    handler = audioHandler as QuranAudioHandler;

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Shimmer controller untuk background
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSurah();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSurah() async {
    final currentItem = handler.mediaItem.value;
    final processingState = handler.playbackState.value.processingState;

    if (currentItem != null && processingState != AudioProcessingState.idle) {
      return;
    }

    await handler.loadSurah(
      surah: widget.initialSurah,
      autoPlay: true,
    );
  }

  void _onSpeedChanged(double speed) {
    setState(() => _playbackSpeed = speed);
    handler.changeSpeed(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // ✅ Disable default back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 8), // ✅ Spacing dari edge
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
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
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // ✅ Spacing dari edge
            child: Center(
              child: GestureDetector(
                onTap: () => _showSpeedMenu(context),
                child: Container(
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
                    Icons.speed,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background dengan animasi
          BackgroundDecoration(shimmerAnimation: _shimmerAnimation),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  AudioPlayerIcon(
                    rotationController: _rotationController,
                    handler: handler,
                  ),
                  const SizedBox(height: 40),
                  AudioPlayerInfo(handler: handler),
                  const Spacer(),
                  AudioPlayerProgress(handler: handler),
                  const SizedBox(height: 20),
                  AudioPlayerControls(handler: handler),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeedMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kecepatan Putar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              return ListTile(
                leading: Icon(
                  _playbackSpeed == speed
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color:
                      _playbackSpeed == speed ? const Color(0xFFC9A24D) : null,
                ),
                title: Text('${speed}x'),
                onTap: () {
                  _onSpeedChanged(speed);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
