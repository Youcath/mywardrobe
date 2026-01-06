import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_styles.dart';

enum AppThemeType { princess, queen, minimalist }

class AppThemes {
  static ThemeData get princessTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.princessPrimaryStart,
        primary: AppColors.princessPrimaryEnd,
        secondary: AppColors.princessLavender,
        surface: AppColors.princessSurface,
      ),
      scaffoldBackgroundColor: AppColors.princessSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.princessPrimaryStart,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      extensions: [
        ThemeGradients(
          primaryGradient: const LinearGradient(
            colors: [AppColors.princessPrimaryStart, AppColors.princessPrimaryEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.princessTitle,
        bodyMedium: AppTextStyles.princessBody,
      ),
    );
  }

  static ThemeData get queenTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.queenPrimaryStart,
        primary: AppColors.queenPrimaryEnd,
        secondary: AppColors.queenRoseGold,
        surface: AppColors.queenSurface,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.queenSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.queenRoseGold,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: const Color(0xFF2A2A2A),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: [
        ThemeGradients(
          primaryGradient: const LinearGradient(
            colors: [AppColors.queenPrimaryStart, AppColors.queenPrimaryEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.queenTitle,
        bodyMedium: AppTextStyles.queenBody,
      ),
    );
  }

  static ThemeData get minimalistTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.minimalPrimaryEnd,
        primary: AppColors.minimalDarkGrey,
        secondary: AppColors.minimalMintGreen,
        surface: AppColors.minimalSurface,
      ),
      scaffoldBackgroundColor: AppColors.minimalSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.minimalPrimaryStart,
        foregroundColor: AppColors.minimalDarkGrey,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
        color: AppColors.minimalPrimaryStart,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      extensions: [
        ThemeGradients(
          primaryGradient: const LinearGradient(
            colors: [AppColors.minimalPrimaryStart, AppColors.minimalPrimaryEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.minimalTitle,
        bodyMedium: AppTextStyles.minimalBody,
      ),
    );
  }
}




