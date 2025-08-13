import 'package:flutter/material.dart';

import '../tokens.dart';

/// Typography utilities and text styles
class OscarTypography {
  // Private constructor
  OscarTypography._();

  // ===== DISPLAY STYLES =====

  static const TextStyle displayLarge = TextStyle(
    fontFamily: OscarDesignTokens.displayFont,
    fontSize: OscarDesignTokens.fontSize5Xl,
    fontWeight: OscarDesignTokens.fontWeightBold,
    height: OscarDesignTokens.lineHeightTight,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: OscarDesignTokens.displayFont,
    fontSize: OscarDesignTokens.fontSize4Xl,
    fontWeight: OscarDesignTokens.fontWeightBold,
    height: OscarDesignTokens.lineHeightTight,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: OscarDesignTokens.displayFont,
    fontSize: OscarDesignTokens.fontSize3Xl,
    fontWeight: OscarDesignTokens.fontWeightSemiBold,
    height: OscarDesignTokens.lineHeightTight,
  );

  // ===== HEADLINE STYLES =====

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSize2Xl,
    fontWeight: OscarDesignTokens.fontWeightSemiBold,
    height: OscarDesignTokens.lineHeightTight,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeXl,
    fontWeight: OscarDesignTokens.fontWeightSemiBold,
    height: OscarDesignTokens.lineHeightNormal,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeLg,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
  );

  // ===== TITLE STYLES =====

  static const TextStyle titleLarge = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeXl,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeLg,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeBase,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
  );

  // ===== BODY STYLES =====

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeBase,
    fontWeight: OscarDesignTokens.fontWeightRegular,
    height: OscarDesignTokens.lineHeightRelaxed,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeSm,
    fontWeight: OscarDesignTokens.fontWeightRegular,
    height: OscarDesignTokens.lineHeightRelaxed,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeXs,
    fontWeight: OscarDesignTokens.fontWeightRegular,
    height: OscarDesignTokens.lineHeightNormal,
  );

  // ===== LABEL STYLES =====

  static const TextStyle labelLarge = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeBase,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeSm,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeXs,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
    letterSpacing: 0.5,
  );

  // ===== SPECIALIZED STYLES =====

  /// For Oscar year displays (e.g., "2024", "97th Academy Awards")
  static const TextStyle oscarYear = TextStyle(
    fontFamily: OscarDesignTokens.displayFont,
    fontSize: OscarDesignTokens.fontSize2Xl,
    fontWeight: OscarDesignTokens.fontWeightBold,
    color: OscarDesignTokens.oscarGold,
    letterSpacing: 1.0,
  );

  /// For movie titles
  static const TextStyle movieTitle = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeLg,
    fontWeight: OscarDesignTokens.fontWeightSemiBold,
    height: OscarDesignTokens.lineHeightTight,
  );

  /// For nominee names
  static const TextStyle nomineeName = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeBase,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    height: OscarDesignTokens.lineHeightNormal,
  );

  /// For category names
  static const TextStyle categoryName = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeSm,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    color: OscarDesignTokens.neutral600,
    letterSpacing: 0.5,
  );

  /// For winner emphasis
  static const TextStyle winner = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeBase,
    fontWeight: OscarDesignTokens.fontWeightBold,
    color: OscarDesignTokens.winner,
  );

  /// For special awards
  static const TextStyle specialAward = TextStyle(
    fontFamily: OscarDesignTokens.displayFont,
    fontSize: OscarDesignTokens.fontSizeLg,
    fontWeight: OscarDesignTokens.fontWeightSemiBold,
    color: OscarDesignTokens.special,
    fontStyle: FontStyle.italic,
  );

  /// For captions and metadata
  static const TextStyle caption = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeXs,
    fontWeight: OscarDesignTokens.fontWeightRegular,
    color: OscarDesignTokens.neutral500,
    height: OscarDesignTokens.lineHeightNormal,
  );

  /// For overline text (small, uppercase labels)
  static const TextStyle overline = TextStyle(
    fontFamily: OscarDesignTokens.primaryFont,
    fontSize: OscarDesignTokens.fontSizeXs,
    fontWeight: OscarDesignTokens.fontWeightMedium,
    color: OscarDesignTokens.neutral600,
    letterSpacing: 1.5,
    height: OscarDesignTokens.lineHeightNormal,
  );

  // ===== UTILITY METHODS =====

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply theme colors to text styles
  static TextStyle withThemeColor(
    TextStyle style,
    BuildContext context,
    ColorType colorType,
  ) {
    final theme = Theme.of(context);
    Color color;

    switch (colorType) {
      case ColorType.primary:
        color = theme.colorScheme.primary;
        break;
      case ColorType.onSurface:
        color = theme.colorScheme.onSurface;
        break;
      case ColorType.onSurfaceVariant:
        color = theme.colorScheme.onSurfaceVariant;
        break;
      case ColorType.error:
        color = theme.colorScheme.error;
        break;
      case ColorType.winner:
        color = OscarDesignTokens.winner;
        break;
      case ColorType.special:
        color = OscarDesignTokens.special;
        break;
    }

    return style.copyWith(color: color);
  }

  /// Make text style bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: OscarDesignTokens.fontWeightBold);
  }

  /// Make text style italic
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Make text style underlined
  static TextStyle underlined(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }

  /// Apply text overflow handling
  static TextStyle withEllipsis(TextStyle style) {
    return style; // TextStyle doesn't handle overflow, this is for consistency
  }

  /// Responsive font sizes based on screen size
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < OscarDesignTokens.breakpointSm) {
      return baseFontSize * 0.9; // Slightly smaller on mobile
    } else if (screenWidth > OscarDesignTokens.breakpointLg) {
      return baseFontSize * 1.1; // Slightly larger on desktop
    }

    return baseFontSize;
  }
}

enum ColorType { primary, onSurface, onSurfaceVariant, error, winner, special }
