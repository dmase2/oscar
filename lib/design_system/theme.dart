import 'package:flutter/material.dart';

import 'tokens.dart';

/// Oscar app theme configuration
/// Provides light and dark theme definitions using the design tokens
class OscarTheme {
  // Private constructor
  OscarTheme._();

  // ===== LIGHT THEME =====

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    cardTheme: _cardTheme,
    appBarTheme: _lightAppBarTheme,
    bottomNavigationBarTheme: _lightBottomNavTheme,
    chipTheme: _chipTheme,
    dialogTheme: _dialogTheme,
    snackBarTheme: _snackBarTheme,
    inputDecorationTheme: _inputDecorationTheme,
    listTileTheme: _listTileTheme,
    dividerTheme: _dividerTheme,
  );

  // ===== DARK THEME =====

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: _textTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    cardTheme: _darkCardTheme,
    appBarTheme: _darkAppBarTheme,
    bottomNavigationBarTheme: _darkBottomNavTheme,
    chipTheme: _darkChipTheme,
    dialogTheme: _darkDialogTheme,
    snackBarTheme: _snackBarTheme,
    inputDecorationTheme: _darkInputDecorationTheme,
    listTileTheme: _darkListTileTheme,
    dividerTheme: _darkDividerTheme,
  );

  // ===== COLOR SCHEMES =====

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: OscarDesignTokens.oscarGold,
    onPrimary: OscarDesignTokens.oscarBlack,
    primaryContainer: OscarDesignTokens.oscarGoldLight,
    onPrimaryContainer: OscarDesignTokens.oscarBlack,
    secondary: OscarDesignTokens.oscarSilver,
    onSecondary: OscarDesignTokens.oscarBlack,
    secondaryContainer: OscarDesignTokens.neutral100,
    onSecondaryContainer: OscarDesignTokens.neutral900,
    tertiary: OscarDesignTokens.oscarBronze,
    onTertiary: Colors.white,
    tertiaryContainer: OscarDesignTokens.neutral50,
    onTertiaryContainer: OscarDesignTokens.neutral900,
    error: OscarDesignTokens.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFEDEA),
    onErrorContainer: OscarDesignTokens.error,
    surface: Colors.white,
    onSurface: OscarDesignTokens.neutral900,
    surfaceContainerHighest: OscarDesignTokens.neutral100,
    onSurfaceVariant: OscarDesignTokens.neutral600,
    outline: OscarDesignTokens.neutral300,
    outlineVariant: OscarDesignTokens.neutral200,
    shadow: OscarDesignTokens.neutral900,
    scrim: OscarDesignTokens.neutral900,
    inverseSurface: OscarDesignTokens.neutral900,
    onInverseSurface: OscarDesignTokens.neutral50,
    inversePrimary: OscarDesignTokens.oscarGoldLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: OscarDesignTokens.oscarGold,
    onPrimary: OscarDesignTokens.oscarBlack,
    primaryContainer: OscarDesignTokens.oscarGoldDark,
    onPrimaryContainer: OscarDesignTokens.oscarGoldLight,
    secondary: OscarDesignTokens.oscarSilver,
    onSecondary: OscarDesignTokens.oscarBlack,
    secondaryContainer: OscarDesignTokens.neutral700,
    onSecondaryContainer: OscarDesignTokens.neutral200,
    tertiary: OscarDesignTokens.oscarBronze,
    onTertiary: Colors.white,
    tertiaryContainer: OscarDesignTokens.neutral800,
    onTertiaryContainer: OscarDesignTokens.neutral200,
    error: OscarDesignTokens.error,
    onError: Colors.white,
    errorContainer: Color(0xFF5F1A1A),
    onErrorContainer: Color(0xFFFFB3BA),
    surface: OscarDesignTokens.neutral900,
    onSurface: OscarDesignTokens.neutral100,
    surfaceContainerHighest: OscarDesignTokens.neutral800,
    onSurfaceVariant: OscarDesignTokens.neutral400,
    outline: OscarDesignTokens.neutral600,
    outlineVariant: OscarDesignTokens.neutral700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: OscarDesignTokens.neutral100,
    onInverseSurface: OscarDesignTokens.neutral900,
    inversePrimary: OscarDesignTokens.oscarGoldDark,
  );

  // ===== TEXT THEME =====

  static const TextTheme _textTheme = TextTheme(
    // Display styles (large, decorative text)
    displayLarge: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSize5Xl,
      fontWeight: OscarDesignTokens.fontWeightBold,
      height: OscarDesignTokens.lineHeightTight,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSize4Xl,
      fontWeight: OscarDesignTokens.fontWeightBold,
      height: OscarDesignTokens.lineHeightTight,
      letterSpacing: -0.25,
    ),
    displaySmall: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSize3Xl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
      height: OscarDesignTokens.lineHeightTight,
    ),

    // Headline styles (section headers)
    headlineLarge: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSize2Xl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
      height: OscarDesignTokens.lineHeightTight,
    ),
    headlineMedium: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeXl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
      height: OscarDesignTokens.lineHeightNormal,
    ),
    headlineSmall: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeLg,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
    ),

    // Title styles (card titles, dialog titles)
    titleLarge: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeXl,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
    ),
    titleMedium: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeLg,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
    ),
    titleSmall: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeBase,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
    ),

    // Body styles (main content)
    bodyLarge: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeBase,
      fontWeight: OscarDesignTokens.fontWeightRegular,
      height: OscarDesignTokens.lineHeightRelaxed,
    ),
    bodyMedium: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeSm,
      fontWeight: OscarDesignTokens.fontWeightRegular,
      height: OscarDesignTokens.lineHeightRelaxed,
    ),
    bodySmall: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeXs,
      fontWeight: OscarDesignTokens.fontWeightRegular,
      height: OscarDesignTokens.lineHeightNormal,
    ),

    // Label styles (buttons, form labels)
    labelLarge: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeBase,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeSm,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: OscarDesignTokens.primaryFont,
      fontSize: OscarDesignTokens.fontSizeXs,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      height: OscarDesignTokens.lineHeightNormal,
      letterSpacing: 0.5,
    ),
  );

  // ===== BUTTON THEMES =====

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: OscarDesignTokens.elevationSm,
          padding: const EdgeInsets.symmetric(
            horizontal: OscarDesignTokens.space6,
            vertical: OscarDesignTokens.space4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
          ),
          textStyle: const TextStyle(
            fontWeight: OscarDesignTokens.fontWeightMedium,
            fontSize: OscarDesignTokens.fontSizeBase,
          ),
        ),
      );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: OscarDesignTokens.space6,
            vertical: OscarDesignTokens.space4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
          ),
          side: const BorderSide(width: 1.5),
          textStyle: const TextStyle(
            fontWeight: OscarDesignTokens.fontWeightMedium,
            fontSize: OscarDesignTokens.fontSizeBase,
          ),
        ),
      );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: OscarDesignTokens.space4,
        vertical: OscarDesignTokens.space2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OscarDesignTokens.radiusMd),
      ),
      textStyle: const TextStyle(
        fontWeight: OscarDesignTokens.fontWeightMedium,
        fontSize: OscarDesignTokens.fontSizeBase,
      ),
    ),
  );

  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: OscarDesignTokens.space6,
        vertical: OscarDesignTokens.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
      ),
      textStyle: const TextStyle(
        fontWeight: OscarDesignTokens.fontWeightMedium,
        fontSize: OscarDesignTokens.fontSizeBase,
      ),
    ),
  );

  // ===== COMPONENT THEMES =====

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: OscarDesignTokens.elevationSm,
    margin: EdgeInsets.all(OscarDesignTokens.space2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusXl),
      ),
    ),
  );

  static const CardThemeData _darkCardTheme = CardThemeData(
    elevation: OscarDesignTokens.elevationMd,
    margin: EdgeInsets.all(OscarDesignTokens.space2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusXl),
      ),
    ),
  );

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    elevation: OscarDesignTokens.elevationSm,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSizeXl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
      color: OscarDesignTokens.oscarBlack,
    ),
    backgroundColor: Colors.white,
    foregroundColor: OscarDesignTokens.oscarBlack,
    shadowColor: OscarDesignTokens.neutral200,
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: OscarDesignTokens.elevationSm,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSizeXl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
      color: OscarDesignTokens.neutral100,
    ),
    backgroundColor: OscarDesignTokens.neutral900,
    foregroundColor: OscarDesignTokens.neutral100,
    shadowColor: Colors.black,
  );

  static const BottomNavigationBarThemeData _lightBottomNavTheme =
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: OscarDesignTokens.oscarGold,
        unselectedItemColor: OscarDesignTokens.neutral500,
        selectedLabelStyle: TextStyle(
          fontWeight: OscarDesignTokens.fontWeightMedium,
        ),
      );

  static const BottomNavigationBarThemeData _darkBottomNavTheme =
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: OscarDesignTokens.neutral900,
        selectedItemColor: OscarDesignTokens.oscarGold,
        unselectedItemColor: OscarDesignTokens.neutral400,
        selectedLabelStyle: TextStyle(
          fontWeight: OscarDesignTokens.fontWeightMedium,
        ),
      );

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: OscarDesignTokens.neutral100,
    side: BorderSide.none,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusFull),
      ),
    ),
    labelStyle: const TextStyle(
      fontSize: OscarDesignTokens.fontSizeSm,
      fontWeight: OscarDesignTokens.fontWeightMedium,
    ),
  );

  static final ChipThemeData _darkChipTheme = ChipThemeData(
    backgroundColor: OscarDesignTokens.neutral800,
    side: BorderSide.none,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusFull),
      ),
    ),
    labelStyle: const TextStyle(
      fontSize: OscarDesignTokens.fontSizeSm,
      fontWeight: OscarDesignTokens.fontWeightMedium,
      color: OscarDesignTokens.neutral200,
    ),
  );

  static const DialogThemeData _dialogTheme = DialogThemeData(
    elevation: OscarDesignTokens.elevationXl,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radius2Xl),
      ),
    ),
    titleTextStyle: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSizeXl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
    ),
  );

  static const DialogThemeData _darkDialogTheme = DialogThemeData(
    elevation: OscarDesignTokens.elevation2Xl,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radius2Xl),
      ),
    ),
    titleTextStyle: TextStyle(
      fontFamily: OscarDesignTokens.displayFont,
      fontSize: OscarDesignTokens.fontSizeXl,
      fontWeight: OscarDesignTokens.fontWeightSemiBold,
    ),
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusLg),
      ),
    ),
    contentTextStyle: TextStyle(
      fontSize: OscarDesignTokens.fontSizeBase,
      fontWeight: OscarDesignTokens.fontWeightMedium,
    ),
  );

  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.oscarGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: OscarDesignTokens.space4,
          vertical: OscarDesignTokens.space3,
        ),
      );

  static const InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.neutral600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.neutral600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.oscarGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(OscarDesignTokens.radiusLg),
          ),
          borderSide: BorderSide(color: OscarDesignTokens.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: OscarDesignTokens.space4,
          vertical: OscarDesignTokens.space3,
        ),
      );

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: OscarDesignTokens.space4,
      vertical: OscarDesignTokens.space2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusLg),
      ),
    ),
  );

  static const ListTileThemeData _darkListTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: OscarDesignTokens.space4,
      vertical: OscarDesignTokens.space2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(OscarDesignTokens.radiusLg),
      ),
    ),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: OscarDesignTokens.neutral200,
    thickness: 1,
    space: OscarDesignTokens.space4,
  );

  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: OscarDesignTokens.neutral700,
    thickness: 1,
    space: OscarDesignTokens.space4,
  );
}
