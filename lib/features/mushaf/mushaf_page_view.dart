import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_app_bar.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_body.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_colors.dart';
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
    final backgroundGradient = controllerGradient(_controller.isNightMode);
    return Scaffold(
      backgroundColor: _controller.isNightMode
          ? MushafColors.nightBackground
          : MushafColors.lightBg,
      appBar: MushafAppBar(
        controller: _controller,
        onDownload: () => MushafDialogs.showDownload(context, _controller),
        onClearData: () => MushafDialogs.showClearData(context, _controller),
        onJumpToPage: () => MushafDialogs.showJumpToPage(context, _controller),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: MushafBody(controller: _controller),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MushafColors.secondaryBrown,
        foregroundColor: MushafColors.goldAccent,
        elevation: 6,
        onPressed: _controller.toggleOverlay,
        icon: Icon(
          _controller.showOverlay
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          size: 18,
        ),
        label: Text(_controller.showOverlay ? 'Sembunyikan' : 'Tampilkan'),
      ),
    );
  }

  LinearGradient controllerGradient(bool isNightMode) {
    if (isNightMode) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A202A),
          Color(0xFF10151D),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFBF7EF),
        Color(0xFFF7F1E5),
      ],
    );
  }
}