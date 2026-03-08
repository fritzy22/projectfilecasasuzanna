import 'package:flutter/material.dart';

class AppColors {
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const blue = Color(0xFF2A6AE3);
  static const gold = Color(0xFFB8A14C);
  static const grayDark = Color(0xFF111111);
  static const teal = Color(0xFF5FD3C5);
  static const purple = Color(0xFF7A6CFF);
}

class AppText {
  static const logo = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: AppColors.white,
  );

  static const sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const price = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.teal,
  );
}

class AppDecorations {
  static BoxDecoration packageCard({bool featured = false}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: featured
            ? [AppColors.teal, AppColors.purple]
            : [Colors.grey.shade800, AppColors.grayDark],
      ),
    );
  }
}

