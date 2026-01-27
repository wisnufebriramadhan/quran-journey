import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_tracker/features/quran/quran_audio_handler.dart';

class AudioPlayerIcon extends StatefulWidget {
  final AnimationController rotationController;
  final QuranAudioHandler handler;

  const AudioPlayerIcon({
    super.key,
    required this.rotationController,
    required this.handler,
  });

  @override
  State<AudioPlayerIcon> createState() => _AudioPlayerIconState();
}

class _AudioPlayerIconState extends State<AudioPlayerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _tonearmController;
  late Animation<double> _tonearmAnimation;

  @override
  void initState() {
    super.initState();
    _tonearmController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tonearmAnimation = Tween<double>(
      begin: 1.0, // Position saat pause (terangkat/keluar)
      end: 0.0, // Position saat play (di atas piringan)
    ).animate(CurvedAnimation(
      parent: _tonearmController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tonearmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: widget.handler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final isPlaying = playbackState?.playing ?? false;

        // Kontrol rotasi vinyl
        if (isPlaying) {
          if (!widget.rotationController.isAnimating) {
            widget.rotationController.repeat();
          }
          _tonearmController.forward(); // Tonearm turun ke piringan
        } else {
          widget.rotationController.stop();
          _tonearmController.reverse(); // Tonearm naik dari piringan
        }

        return StreamBuilder<MediaItem?>(
          stream: widget.handler.mediaItem,
          builder: (context, mediaSnapshot) {
            final mediaItem = mediaSnapshot.data;

            return SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vinyl Record
                  RotationTransition(
                    turns: widget.rotationController,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Vinyl Record (Piring Hitam)
                          Container(
                            width: 380,
                            height: 380,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFF1a1a1a),
                                  Color(0xFF0d0d0d),
                                  Colors.black,
                                ],
                                stops: [0.0, 0.7, 1.0],
                              ),
                            ),
                          ),

                          // Grooves (Alur piringan hitam)
                          ...List.generate(15, (index) {
                            final size = 260.0 - (index * 12.0);
                            return Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1.5,
                                ),
                              ),
                            );
                          }),

                          // Center Label (Label tengah)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFC9A24D),
                                  Color(0xFFB8922E),
                                  Color(0xFFA88425),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Decorative circles on label
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                ),

                                // Surah info
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (mediaItem != null) ...[
                                        Text(
                                          mediaItem.displayTitle ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          mediaItem.displaySubtitle ?? '',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 9,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ] else ...[
                                        const Icon(
                                          Icons.music_note,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center hole (Lubang tengah)
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                color: Colors.grey.shade800,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          // Reflection effect
                          Positioned(
                            top: 30,
                            left: 30,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tonearm (Lengan Pemutar)
                  Positioned(
                    top: 250,
                    right: 5,
                    child: AnimatedBuilder(
                      animation: _tonearmAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -0.4 * _tonearmAnimation.value,
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            width: 180,
                            height: 60,
                            child: Stack(
                              children: [
                                // Main Tonearm Body
                                Positioned(
                                  top: 20,
                                  left: 0,
                                  child: Container(
                                    width: 140,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade400,
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(2, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Pivot Base (Titik putar utama)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade400,
                                          Colors.grey.shade500,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(2, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey.shade600,
                                              Colors.grey.shade700,
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Counterweight (Pemberat)
                                Positioned(
                                  right: 30,
                                  top: 15,
                                  child: Container(
                                    width: 30,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade600,
                                          Colors.grey.shade700,
                                          Colors.grey.shade800,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 4,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Headshell (Cartridge holder)
                                Positioned(
                                  left: 0,
                                  top: 16,
                                  child: Container(
                                    width: 35,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 2,
                                          height: 8,
                                          color: Colors.grey.shade600,
                                        ),
                                        Container(
                                          width: 2,
                                          height: 8,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Stylus/Needle (Jarum)
                                Positioned(
                                  left: 0,
                                  top: 20,
                                  child: Container(
                                    width: 12,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        bottomLeft: Radius.circular(3),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: 4,
                                        height: 1.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
