import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const primary = Color(0xFF2A2A2A);
  static const secondary = Color(0xFFE0E0E0);
  static const accent = Color(0xFF00BFA6);
  static const text = Colors.black;
  static const background = Colors.white;
  static const danger = Colors.red;

  // Couleurs spécialisées
  static const searchBg = Colors.white; // fond blanc pour headers/cards
  static const grey = Color(0xFFB5B5B5); // gris pour input
  static const inputBg = Colors.white;
  static const textPrimary = Color(0xFF121212);
  static const textSecondary = Color(0xFF6B7280);
  static const price = Color(0xFF0F766E);
  static const border = Color(0xFFE5E7EB); // gris clair pour les bordures

  // Nouvelles couleurs pour le design moderne
  static const cardBg = Colors.white; // arrière-plan des cards
  static const success = Color(0xFF10B981); // vert pour les succès
  static const warning = Color(0xFFF59E0B); // orange pour les avertissements
  static const info = Color(0xFF3B82F6); // bleu pour les informations

  // Couleurs d'ombre et d'élévation
  static Color shadowLight = Colors.black.withOpacity(0.04);
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.12);

  // Couleurs de fond avec opacité pour les containers
  static Color accentLight = accent.withOpacity(0.1);
  static Color primaryLight = primary.withOpacity(0.05);
  static Color dangerLight = danger.withOpacity(0.1);
}

class AppTextStyles {
  // Styles de titre
  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  // Styles de texte principal
  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.text,
    height: 1.4,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Styles de bouton
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Styles d'input
  static const input = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const inputLabel = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  // Styles secondaires
  static const muted = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const mutedSmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // Styles de section
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const sectionSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Styles d'item
  static const itemTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const itemSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const secondary = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  // Styles de prix
  static const price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.price,
  );

  static const priceLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.price,
  );

  // Styles d'état
  static const success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  static const error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.danger,
  );

  static const warning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
  );
}

class AppPadding {
  static const horizontal = EdgeInsets.symmetric(horizontal: 16);
  static const vertical = EdgeInsets.symmetric(vertical: 16);
  static const all = EdgeInsets.all(16);

  // Padding numérique pour plus de flexibilité
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // EdgeInsets prédéfinis
  static const EdgeInsets h = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets v = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: 24);
}

class AppRadius {
  static const border = BorderRadius.all(Radius.circular(12));

  // Radius numérique
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  // BorderRadius prédéfinis
  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16));
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(20));

  // Radius spécialisés
  static const BorderRadius card = BorderRadius.all(Radius.circular(12));
  static const BorderRadius button = BorderRadius.all(Radius.circular(10));
  static const BorderRadius input = BorderRadius.all(Radius.circular(8));
}

class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppShadows {
  // Ombres prédéfinies pour les cards et éléments
  static List<BoxShadow> get light => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get dark => [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];
}

class AppBorders {
  AppBorders._();

  // Bordures standard
  static final OutlineInputBorder input = OutlineInputBorder(
    borderRadius: AppRadius.input,
    borderSide: const BorderSide(color: AppColors.border, width: 1),
  );

  static final OutlineInputBorder inputFocused = OutlineInputBorder(
    borderRadius: AppRadius.input,
    borderSide: const BorderSide(color: AppColors.accent, width: 2),
  );

  static final OutlineInputBorder inputError = OutlineInputBorder(
    borderRadius: AppRadius.input,
    borderSide: const BorderSide(color: AppColors.danger, width: 1),
  );

  // Bordures pour cards
  static Border get card => Border.all(
    color: AppColors.border,
    width: 1,
  );

  static Border get cardHover => Border.all(
    color: AppColors.accent.withOpacity(0.3),
    width: 1,
  );
}

class AppDecorations {
  // Décorations prédéfinies pour les containers
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: AppRadius.card,
    border: AppBorders.card,
    boxShadow: AppShadows.card,
  );

  static BoxDecoration get headerGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.95),
      ],
    ),
  );

  static BoxDecoration get actionButton => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get inputField => BoxDecoration(
    color: AppColors.inputBg,
    borderRadius: AppRadius.input,
    border: Border.all(color: AppColors.border),
  );

  static BoxDecoration get iconContainer => BoxDecoration(
    color: AppColors.accentLight,
    borderRadius: BorderRadius.circular(AppRadius.md),
  );
}

/// Styles dédiés à la page de sélection de commerce
class ChooseCommerceStyles {
  // Couleur d'arrière-plan des tuiles
  static const tileBg = Colors.white;

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

/// Thème pour les boutons
class AppButtonStyles {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.button,
    ),
    elevation: 2,
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle get secondary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.textPrimary,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.button,
    ),
    elevation: 1,
  );

  static ButtonStyle get danger => ElevatedButton.styleFrom(
    backgroundColor: AppColors.danger,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.button,
    ),
    elevation: 2,
  );

  static ButtonStyle get outline => OutlinedButton.styleFrom(
    foregroundColor: AppColors.accent,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.button,
    ),
    side: const BorderSide(color: AppColors.accent),
  );
}

/// Thème pour les SnackBars
class AppSnackBarTheme {
  static SnackBarThemeData get theme => SnackBarThemeData(
    backgroundColor: AppColors.accent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  static SnackBar success(String message) => SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
  );

  static SnackBar error(String message) => SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error, color: Colors.white, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: AppColors.danger,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
  );
}