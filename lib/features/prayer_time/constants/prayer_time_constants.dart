import 'package:flutter/material.dart';

/// 🎨 Prayer Time Page Constants
class PrayerTimeConstants {
  PrayerTimeConstants._();

  // ==================== COLORS ====================

  /// Background Gradient Colors
  static const List<Color> backgroundGradient = [
    Color(0xFF3E2723),
    Color(0xFF4A3428),
    Color(0xFF5D4037),
    Color(0xFF6D4C41),
  ];

  /// Primary Brown Color
  static const Color primaryBrown = Color(0xFF6D4C41);
  static const Color darkBrown = Color(0xFF5D4037);
  static const Color textDark = Color(0xFF3E2723);

  /// Background Color
  static const Color background = Color(0xFFF8F9FA);

  // ==================== SIZES ====================

  /// Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusHuge = 32.0;

  /// Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingHuge = 32.0;

  /// Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;

  /// Pattern
  static const double patternSpacing = 80.0;
  static const double patternRadius1 = 25.0;
  static const double patternRadius2 = 12.0;

  // ==================== TEXT STYLES ====================

  static const TextStyle headerTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle timeDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1,
  );

  static const TextStyle prayerName = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle prayerItemTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle prayerItemTime = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // ==================== GRADIENTS ====================

  static LinearGradient cardGradient({double opacity = 0.25}) {
    return LinearGradient(
      colors: [
        Colors.white.withOpacity(opacity),
        Colors.white.withOpacity(opacity - 0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBrown, darkBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient iconGradient({bool isActive = false}) {
    if (isActive) {
      return LinearGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.2),
        ],
      );
    }
    return LinearGradient(
      colors: [
        primaryBrown.withOpacity(0.15),
        darkBrown.withOpacity(0.1),
      ],
    );
  }

  // ==================== SHADOWS ====================

  static List<BoxShadow> cardShadow({bool isActive = false}) {
    return [
      BoxShadow(
        color: isActive
            ? primaryBrown.withOpacity(0.15)
            : Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== DECORATIONS ====================

  static BoxDecoration cardDecoration({
    bool isActive = false,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radiusXLarge),
      color: isActive ? null : Colors.white,
      gradient: isActive ? primaryGradient : null,
      border: hasBorder
          ? Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            )
          : null,
      boxShadow: cardShadow(isActive: isActive),
    );
  }

  static BoxDecoration iconContainerDecoration({bool isActive = false}) {
    return BoxDecoration(
      gradient: iconGradient(isActive: isActive),
      borderRadius: BorderRadius.circular(radiusMedium),
    );
  }
}
