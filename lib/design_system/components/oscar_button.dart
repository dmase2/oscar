import 'package:flutter/material.dart';

import '../tokens.dart';

/// Reusable button components following the design system
class OscarButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OscarButtonVariant variant;
  final OscarButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  const OscarButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = OscarButtonVariant.primary,
    this.size = OscarButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button;

    switch (variant) {
      case OscarButtonVariant.primary:
        button = _buildElevatedButton(theme);
        break;
      case OscarButtonVariant.secondary:
        button = _buildOutlinedButton(theme);
        break;
      case OscarButtonVariant.ghost:
        button = _buildTextButton(theme);
        break;
      case OscarButtonVariant.filled:
        button = _buildFilledButton(theme);
        break;
    }

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildElevatedButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildButtonContent().icon,
      label: _buildButtonContent().label,
      style: _getButtonStyle(theme).copyWith(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
        foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildButtonContent().icon,
      label: _buildButtonContent().label,
      style: _getButtonStyle(theme).copyWith(
        side: WidgetStateProperty.all(
          BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        foregroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildTextButton(ThemeData theme) {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildButtonContent().icon,
      label: _buildButtonContent().label,
      style: _getButtonStyle(theme).copyWith(
        foregroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildFilledButton(ThemeData theme) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildButtonContent().icon,
      label: _buildButtonContent().label,
      style: _getButtonStyle(theme),
    );
  }

  ButtonContent _buildButtonContent() {
    Widget? buttonIcon;

    if (isLoading) {
      buttonIcon = SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      buttonIcon = icon;
    }

    return ButtonContent(
      icon: buttonIcon,
      label: Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: OscarDesignTokens.fontWeightMedium,
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(_getPadding()),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
        ),
      ),
      elevation: variant == OscarButtonVariant.primary
          ? WidgetStateProperty.all(OscarDesignTokens.elevationSm)
          : WidgetStateProperty.all(0),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case OscarButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: OscarDesignTokens.space4,
          vertical: OscarDesignTokens.space2,
        );
      case OscarButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: OscarDesignTokens.space6,
          vertical: OscarDesignTokens.space3,
        );
      case OscarButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: OscarDesignTokens.space8,
          vertical: OscarDesignTokens.space4,
        );
    }
  }

  double _getFontSize() {
    switch (size) {
      case OscarButtonSize.small:
        return OscarDesignTokens.fontSizeSm;
      case OscarButtonSize.medium:
        return OscarDesignTokens.fontSizeBase;
      case OscarButtonSize.large:
        return OscarDesignTokens.fontSizeLg;
    }
  }

  double _getIconSize() {
    switch (size) {
      case OscarButtonSize.small:
        return 16;
      case OscarButtonSize.medium:
        return 20;
      case OscarButtonSize.large:
        return 24;
    }
  }
}

enum OscarButtonVariant { primary, secondary, ghost, filled }

enum OscarButtonSize { small, medium, large }

class ButtonContent {
  final Widget? icon;
  final Widget label;

  const ButtonContent({this.icon, required this.label});
}
