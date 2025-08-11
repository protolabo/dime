import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2A2A2A);
  static const secondary = Color(0xFFE0E0E0);
  static const accent = Color(0xFF00BFA6);
  static const text = Colors.black;
  static const background = Colors.white;
  static const danger = Colors.red;
  static const searchBg = Color(0xFFFDF1DC); // fond beige claire
  static const grey = Color(0xFFB5B5B5); // gris pour input
  static const Color inputBg = Colors.white;
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color price = Color(0xFF0F766E);
  static const Color border = Color(0xFFE5E7EB); // gris clair pour les bordures

}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const body = TextStyle(fontSize: 14, color: AppColors.text);

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle input = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle muted = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle itemTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.price,
  );
}

class AppPadding {
  static const horizontal = EdgeInsets.symmetric(horizontal: 16);
  static const vertical = EdgeInsets.symmetric(vertical: 16);
  static const all = EdgeInsets.all(16);
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const EdgeInsets h = EdgeInsets.symmetric(horizontal: 16);
}

class AppRadius {
  static const border = BorderRadius.all(Radius.circular(12));
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}

/// Styles dédiés à la page de sélection de commerce
class ChooseCommerceStyles {
  // Couleur d’arrière-plan des tuiles
  static const tileBg = Color(0xFFFFF4D9);

  // Bordure noire de 2 px
  static const tileBorder = BorderSide(width: 2, color: Colors.black);

  // Icône de magasin
  static const iconSize = 32.0;

  // Texte centrée dans la tuile
  static const tileText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
}

class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppBorders {
  AppBorders._();

  // Bordure standard pour TextField / TextFormField
  static final OutlineInputBorder input = OutlineInputBorder(
    borderRadius: AppRadius.border,                 // suppose que tu as AppRadius.border
    borderSide: const BorderSide(color: AppColors.border, width: 1),
  );
}
