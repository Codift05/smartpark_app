import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF0F2A4A);
  static const Color navyDark = Color(0xFF0B1F36);
  static const Color sky = Color(0xFFEFF4FA);
  static const Color blue = Color(0xFF153E75);
  static const Color accent = Color(0xFF2E6ADB);
}

class AppGradients {
  static const LinearGradient page = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF4FA), Color(0xFFDDE7F6)],
  );
}

class AppText {
  static TextStyle h1(BuildContext context) => Theme.of(context).textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      );

  static TextStyle h2(BuildContext context) => Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      );

  static TextStyle body(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.navy,
      );

  static TextStyle caption(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(
        color: AppColors.navy.withValues(alpha: 0.7),
      );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color});

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