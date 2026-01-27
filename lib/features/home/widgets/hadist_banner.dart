import 'package:flutter/material.dart';
import 'package:quran_tracker/features/home/providers/banner_list.dart';

class HadistBanner extends StatefulWidget {
  final PageController pageController;

  const HadistBanner({
    required this.pageController,
    super.key,
  });

  @override
  State<HadistBanner> createState() => _HadistBannerState();
}

class _HadistBannerState extends State<HadistBanner> {
  // ignore: unused_field
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: PageView.builder(
        controller: widget.pageController,
        itemCount: dailyQuotes.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final quote = dailyQuotes[index];
          return _buildQuoteCard(quote, index);
        },
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, String> quote, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        margin: const EdgeInsets.only(top: 16, bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(quote, index),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
  }

  Widget _buildHeader(Map<String, String> quote, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: dotIndex == index ? 18 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotIndex == index
                    ? Colors.amber
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
