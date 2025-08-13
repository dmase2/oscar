import 'package:flutter/material.dart';

import '../tokens.dart';

/// Reusable card component following the design system
class OscarCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final OscarCardVariant variant;
  final VoidCallback? onTap;
  final bool isElevated;
  final Color? backgroundColor;

  const OscarCard({
    super.key,
    required this.child,
    this.padding,
    this.variant = OscarCardVariant.standard,
    this.onTap,
    this.isElevated = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Card(
      elevation: _getElevation(),
      color: backgroundColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        side: _getBorderSide(theme),
      ),
      child: Padding(padding: padding ?? _getDefaultPadding(), child: child),
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            child: card,
          )
        : card;
  }

  double _getElevation() {
    if (!isElevated) return 0;

    switch (variant) {
      case OscarCardVariant.standard:
        return OscarDesignTokens.elevationSm;
      case OscarCardVariant.elevated:
        return OscarDesignTokens.elevationMd;
      case OscarCardVariant.outlined:
        return 0;
    }
  }

  double _getBorderRadius() {
    switch (variant) {
      case OscarCardVariant.standard:
      case OscarCardVariant.elevated:
        return OscarDesignTokens.radiusXl;
      case OscarCardVariant.outlined:
        return OscarDesignTokens.radiusLg;
    }
  }

  BorderSide _getBorderSide(ThemeData theme) {
    switch (variant) {
      case OscarCardVariant.outlined:
        return BorderSide(color: theme.colorScheme.outline, width: 1);
      case OscarCardVariant.standard:
      case OscarCardVariant.elevated:
        return BorderSide.none;
    }
  }

  EdgeInsets _getDefaultPadding() {
    return const EdgeInsets.all(OscarDesignTokens.space4);
  }
}

enum OscarCardVariant { standard, elevated, outlined }

/// A specialized card for displaying Oscar-related content
class OscarContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final Widget? content;
  final VoidCallback? onTap;
  final bool showDivider;

  const OscarContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.actions,
    this.content,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OscarCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: OscarDesignTokens.space3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: OscarDesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: OscarDesignTokens.space1),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),

          // Divider
          if (showDivider && (content != null || actions != null)) ...[
            const SizedBox(height: OscarDesignTokens.space3),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              height: 1,
            ),
            const SizedBox(height: OscarDesignTokens.space3),
          ],

          // Content
          if (content != null) ...[
            if (!showDivider) const SizedBox(height: OscarDesignTokens.space3),
            content!,
          ],

          // Actions
          if (actions != null && actions!.isNotEmpty) ...[
            if (!showDivider && content == null)
              const SizedBox(height: OscarDesignTokens.space3),
            if (content != null)
              const SizedBox(height: OscarDesignTokens.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!
                  .expand(
                    (action) => [
                      action,
                      const SizedBox(width: OscarDesignTokens.space2),
                    ],
                  )
                  .take(actions!.length * 2 - 1)
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
