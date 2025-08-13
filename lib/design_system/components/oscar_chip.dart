import 'package:flutter/material.dart';

import '../tokens.dart';

/// Reusable chip component following the design system
class OscarChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Widget? avatar;
  final Color? backgroundColor;
  final Color? selectedColor;
  final bool isSelected;
  final OscarChipVariant variant;
  final OscarChipSize size;

  const OscarChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
    this.avatar,
    this.backgroundColor,
    this.selectedColor,
    this.isSelected = false,
    this.variant = OscarChipVariant.assist,
    this.size = OscarChipSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case OscarChipVariant.assist:
        return _buildAssistChip(theme);
      case OscarChipVariant.filter:
        return _buildFilterChip(theme);
      case OscarChipVariant.input:
        return _buildInputChip(theme);
      case OscarChipVariant.choice:
        return _buildChoiceChip(theme);
    }
  }

  Widget _buildAssistChip(ThemeData theme) {
    return Chip(
      label: _buildLabel(theme),
      avatar: avatar,
      backgroundColor: backgroundColor,
      shape: _getShape(),
      padding: _getPadding(),
      labelPadding: _getLabelPadding(),
    );
  }

  Widget _buildFilterChip(ThemeData theme) {
    return FilterChip(
      label: _buildLabel(theme),
      selected: isSelected,
      onSelected: onPressed != null ? (_) => onPressed!() : null,
      avatar: avatar,
      backgroundColor: backgroundColor,
      selectedColor:
          selectedColor ?? theme.colorScheme.primary.withValues(alpha: 0.12),
      shape: _getShape(),
      padding: _getPadding(),
      labelPadding: _getLabelPadding(),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildInputChip(ThemeData theme) {
    return InputChip(
      label: _buildLabel(theme),
      onPressed: onPressed,
      onDeleted: onDeleted,
      avatar: avatar,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      selected: isSelected,
      shape: _getShape(),
      padding: _getPadding(),
      labelPadding: _getLabelPadding(),
      deleteIconColor: theme.colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildChoiceChip(ThemeData theme) {
    return ChoiceChip(
      label: _buildLabel(theme),
      selected: isSelected,
      onSelected: onPressed != null ? (_) => onPressed!() : null,
      avatar: avatar,
      backgroundColor: backgroundColor,
      selectedColor:
          selectedColor ?? theme.colorScheme.primary.withValues(alpha: 0.12),
      shape: _getShape(),
      padding: _getPadding(),
      labelPadding: _getLabelPadding(),
    );
  }

  Widget _buildLabel(ThemeData theme) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        fontSize: _getFontSize(),
        fontWeight: OscarDesignTokens.fontWeightMedium,
        color: isSelected && variant != OscarChipVariant.assist
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  OutlinedBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(OscarDesignTokens.radiusFull),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case OscarChipSize.small:
        return const EdgeInsets.symmetric(horizontal: OscarDesignTokens.space2);
      case OscarChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: OscarDesignTokens.space3);
      case OscarChipSize.large:
        return const EdgeInsets.symmetric(horizontal: OscarDesignTokens.space4);
    }
  }

  EdgeInsets _getLabelPadding() {
    switch (size) {
      case OscarChipSize.small:
        return const EdgeInsets.symmetric(horizontal: OscarDesignTokens.space2);
      case OscarChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: OscarDesignTokens.space3);
      case OscarChipSize.large:
        return const EdgeInsets.symmetric(horizontal: OscarDesignTokens.space4);
    }
  }

  double _getFontSize() {
    switch (size) {
      case OscarChipSize.small:
        return OscarDesignTokens.fontSizeXs;
      case OscarChipSize.medium:
        return OscarDesignTokens.fontSizeSm;
      case OscarChipSize.large:
        return OscarDesignTokens.fontSizeBase;
    }
  }
}

enum OscarChipVariant { assist, filter, input, choice }

enum OscarChipSize { small, medium, large }

/// A specialized chip for Oscar categories or awards
class OscarCategoryChip extends StatelessWidget {
  final String category;
  final bool isWinner;
  final bool isSelected;
  final VoidCallback? onTap;

  const OscarCategoryChip({
    super.key,
    required this.category,
    this.isWinner = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color chipColor;

    if (isWinner) {
      chipColor = OscarDesignTokens.winner;
    } else if (isSelected) {
      chipColor = theme.colorScheme.primary.withValues(alpha: 0.12);
    } else {
      chipColor = theme.colorScheme.surfaceContainerHighest;
    }

    return OscarChip(
      label: category,
      onPressed: onTap,
      backgroundColor: chipColor,
      isSelected: isSelected,
      variant: OscarChipVariant.choice,
      avatar: isWinner
          ? CircleAvatar(
              backgroundColor: OscarDesignTokens.oscarBlack,
              radius: 8,
              child: const Icon(
                Icons.emoji_events,
                color: OscarDesignTokens.winner,
                size: 12,
              ),
            )
          : null,
    );
  }
}
