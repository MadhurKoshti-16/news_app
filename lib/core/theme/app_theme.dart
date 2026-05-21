import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme_extension.dart';

class AppColors {
  AppColors._();

  // Light palette
  static const Color primaryLight = Color(0xFF1A73E8); // Google-style blue
  static const Color accentLight = Color(0xFFE8710A); // warm orange accent
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color offlineLight = Color(0xFFFFF3CD); // amber warning

  // Dark palette
  static const Color primaryDark = Colors.deepPurple;
  static const Color accentDark = Color.fromARGB(255, 254, 160, 20);
  static const Color bgDark = Colors.black;
  static const Color cardDark = Colors.white24;
  static const Color offlineDark = Color.fromARGB(255, 53, 32, 106);

  // Shimmer
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
}

/// Static theme factory.
class AppTheme {
  AppTheme._();

  static const AppThemeExtension _lightExtension = AppThemeExtension(
    brandPrimary: AppColors.primaryLight,
    brandAccent: AppColors.accentLight,
    cardBackground: AppColors.cardLight,
    offlineBannerColor: AppColors.offlineLight,
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
    cardRadius: 12.0,
    cardElevation: 2.0,
    categoryChipSelected: AppColors.primaryLight,
    categoryChipUnselected: Color(0xFFE0E0E0),
  );

  static const AppThemeExtension _darkExtension = AppThemeExtension(
    brandPrimary: AppColors.primaryDark,
    brandAccent: AppColors.accentDark,
    cardBackground: AppColors.cardDark,
    offlineBannerColor: AppColors.offlineDark,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark, 
    cardRadius: 12.0,
    cardElevation: 4.0,
    categoryChipSelected: AppColors.primaryDark,
    categoryChipUnselected: Color(0xFF2C2C2C),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.primaryLight,
      backgroundColor: const Color(0xFFE0E0E0),
      labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    // Attach the custom extension
    extensions: const <ThemeExtension<dynamic>>[_lightExtension],
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.primaryDark,
      backgroundColor: const Color(0xFF2C2C2C),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    extensions: const <ThemeExtension<dynamic>>[_darkExtension],
  );
}
