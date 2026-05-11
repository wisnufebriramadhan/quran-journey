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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Fixed height for better control
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
    final isHadist = quote['type'] == 'Hadist';
    final isDoa = quote['type'] == 'Doa';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isHadist
              ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
              : isDoa
                  ? [const Color(0xFF004D40), const Color(0xFF00796B)]
                  : [const Color(0xFF4527A0), const Color(0xFF673AB7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isHadist
                    ? const Color(0xFF1A237E)
                    : isDoa
                        ? const Color(0xFF004D40)
                        : const Color(0xFF4527A0))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative background icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.format_quote_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(quote, index),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.format_quote_rounded,
                          color: Colors.amber.shade300.withOpacity(0.8),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quote['text']!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '— ${quote['source']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                quote['type'] == 'Hadist'
                    ? Icons.auto_awesome_rounded
                    : quote['type'] == 'Doa'
                        ? Icons.favorite_rounded
                        : Icons.menu_book_rounded,
                color: Colors.amber.shade300,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                quote['type']!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: List.generate(
            dailyQuotes.length,
            (dotIndex) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: dotIndex == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotIndex == index
                    ? Colors.amber.shade300
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
