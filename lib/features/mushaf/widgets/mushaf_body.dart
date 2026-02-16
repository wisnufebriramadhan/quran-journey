import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/mushaf_page_view.dart';
import 'mushaf_page_widget.dart';

/// Widget Body untuk Mushaf Page dengan PageView dan Overlay
class MushafBody extends StatelessWidget {
  final MushafPageController controller;

  const MushafBody({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page viewer
        PageView.builder(
          controller: controller.pageController,
          reverse: true,
          itemCount: 604,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            return MushafPageWidget(
              pageNumber: index + 1,
              controller: controller,
            );
          },
        ),

        // Page indicator overlay
        if (controller.showOverlay)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: controller.fadeAnimation,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MushafColors.appBarBrown.withOpacity(0.95),
                        MushafColors.secondaryBrown.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MushafColors.goldAccent.withOpacity(0.2),
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
                        color: MushafColors.goldAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Halaman ${controller.currentPage} dari 604',
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
}