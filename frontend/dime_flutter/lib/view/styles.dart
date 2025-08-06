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
}

class AppPadding {
  static const horizontal = EdgeInsets.symmetric(horizontal: 16);
  static const vertical = EdgeInsets.symmetric(vertical: 16);
  static const all = EdgeInsets.all(16);
}

class AppRadius {
  static const border = BorderRadius.all(Radius.circular(12));
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
