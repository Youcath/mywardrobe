import 'package:flutter/material.dart';

class AppColors {
  // Princess Theme Colors
  static const princessPrimaryStart = Color(0xFFFFB6C1);
  static const princessPrimaryEnd = Color(0xFFFF69B4);
  static const princessChampagneGold = Color(0xFFFFFACD);
  static const princessLavender = Color(0xFFE6E6FA);
  static const princessSurface = Color(0xFFFFF5F7);

  // Queen Theme Colors
  static const queenPrimaryStart = Color(0xFF4B0082);
  static const queenPrimaryEnd = Color(0xFF8A2BE2);
  static const queenWineRed = Color(0xFF800000);
  static const queenRoseGold = Color(0xFFB76E79);
  static const queenSurface = Color(0xFF1A1A1A);

  // Minimalist Theme Colors
  static const minimalPrimaryStart = Color(0xFFF5F5F5);
  static const minimalPrimaryEnd = Color(0xFFE0E0E0);
  static const minimalDarkGrey = Color(0xFF424242);
  static const minimalMintGreen = Color(0xFF98FF98);
  static const minimalSurface = Color(0xFFFFFFFF);
}

// Custom extension for gradients since ThemeData doesn't have a direct field for it
class ThemeGradients extends ThemeExtension<ThemeGradients> {
  final LinearGradient primaryGradient;

  ThemeGradients({required this.primaryGradient});

  @override
  ThemeGradients copyWith({LinearGradient? primaryGradient}) {
    return ThemeGradients(
      primaryGradient: primaryGradient ?? this.primaryGradient,
    );
  }

  @override
  ThemeGradients lerp(ThemeExtension<ThemeGradients>? other, double t) {
    if (other is! ThemeGradients) return this;
    return ThemeGradients(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
    );
  }
}

