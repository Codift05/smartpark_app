import 'package:flutter/material.dart';

class AppColors {
  // Modern Clean Color Palette (berdasarkan screenshot Statistik)
  static const Color primary = Color(0xFF00D4AA); // Cyan/Teal accent
  static const Color primaryDark = Color(0xFF00B894); // Darker teal
  static const Color primaryLight = Color(0xFF7FFFE0); // Light mint
  static const Color background = Color(0xFFFAFAFA); // Light gray background
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white
  static const Color cardBg = Color(0xFFF5F5F5); // Card background
  static const Color accent = Color(0xFF00D4AA); // Teal accent
  static const Color textDark = Color(0xFF1A1A1A); // Almost black
  static const Color textLight = Color(0xFF9E9E9E); // Gray text
  static const Color textMedium = Color(0xFF616161); // Medium gray
  static const Color iconGray = Color(0xFFBDBDBD); // Icon gray
}

class AppGradients {
  static const LinearGradient page = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
  );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
  );
}

class AppText {
  static TextStyle h1(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          );

  static TextStyle h2(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textDark,
          );

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColors.textLight,
          );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: padding, child: child),
    );
  }
}
