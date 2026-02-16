import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_app_bar.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_body.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_dialogs.dart';

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
      backgroundColor: MushafColors.lightBg,
      appBar: MushafAppBar(
        controller: _controller,
        onDownload: () => MushafDialogs.showDownload(context, _controller),
        onClearData: () => MushafDialogs.showClearData(context, _controller),
        onJumpToPage: () => MushafDialogs.showJumpToPage(context, _controller),
      ),
      body: MushafBody(controller: _controller),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: MushafColors.secondaryBrown,
        foregroundColor: MushafColors.goldAccent,
        elevation: 4,
        onPressed: _controller.toggleOverlay,
        child: Icon(
          _controller.showOverlay
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          size: 18,
        ),
      ),
    );
  }
}

/// Konstanta warna untuk Mushaf
class MushafColors {
  static const appBarBrown = Color(0xFF3E2723);
  static const secondaryBrown = Color(0xFF6D4C41);
  static const goldAccent = Color(0xFFD4AF37);
  static const lightBg = Color(0xFFFAFAFA);
}