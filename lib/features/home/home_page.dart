// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran_tracker/features/home/widgets/home_header.dart';
import 'package:quran_tracker/features/home/widgets/hadist_banner.dart';
import 'package:quran_tracker/features/home/widgets/menu_grid.dart';
import 'package:quran_tracker/features/home/widgets/background_decoration.dart';
import 'package:quran_tracker/features/home/providers/home_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    _homeProvider = HomeProvider();
    _homeProvider.initialize(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      setState(() {
        _homeProvider.setSelectedDockIndex(0);
      });
    }
  }

  @override
  void dispose() {
    _homeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Background
              const BackgroundDecoration(),

              // Main Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: AnimatedBuilder(
                  animation: _homeProvider.animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _homeProvider.fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _homeProvider.slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      HomeHeader(provider: _homeProvider),
                      const SizedBox(height: 16),
                      HadistBanner(
                          pageController: _homeProvider.hadistPageController),
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: MenuGrid(onNavigate: _onNavigate),
                      ),
                      const SizedBox(height: 24),
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

  void _onNavigate(int index) {
    if (index == 0) return;
    _homeProvider.navigateTo(context, index);
  }
}
