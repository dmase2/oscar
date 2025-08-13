import 'package:flutter/material.dart';

import '../design_system.dart';

/// Example screen demonstrating the Oscar Design System
class DesignSystemExample extends StatefulWidget {
  const DesignSystemExample({super.key});

  @override
  State<DesignSystemExample> createState() => _DesignSystemExampleState();
}

class _DesignSystemExampleState extends State<DesignSystemExample> {
  bool _isLoading = false;
  final Set<String> _selectedFilters = {'Drama'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System Example')),
      body: SingleChildScrollView(
        padding: OscarSpacing.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypographySection(),
            OscarSpacing.space8,
            _buildButtonSection(),
            OscarSpacing.space8,
            _buildChipSection(),
            OscarSpacing.space8,
            _buildCardSection(),
            OscarSpacing.space8,
            _buildColorSection(),
            OscarSpacing.space8,
            _buildSpacingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Typography', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,

        // Display styles
        Text('Display Large', style: OscarTypography.displayLarge),
        OscarSpacing.space2,
        Text('Display Medium', style: OscarTypography.displayMedium),
        OscarSpacing.space2,
        Text('Display Small', style: OscarTypography.displaySmall),

        OscarSpacing.space4,

        // Specialized Oscar styles
        Text('2024', style: OscarTypography.oscarYear),
        OscarSpacing.space2,
        Text('The Shape of Water', style: OscarTypography.movieTitle),
        OscarSpacing.space1,
        Text('Guillermo del Toro', style: OscarTypography.nomineeName),
        OscarSpacing.space1,
        Text('BEST DIRECTOR', style: OscarTypography.categoryName),

        OscarSpacing.space4,

        // Winner and special styles
        Text('WINNER', style: OscarTypography.winner),
        OscarSpacing.space1,
        Text('Special Achievement Award', style: OscarTypography.specialAward),

        OscarSpacing.space4,

        // Body text
        Text(
          'This is body large text demonstrating the readable paragraph style with proper line height and spacing for longer content.',
          style: OscarTypography.bodyLarge,
        ),
        OscarSpacing.space2,
        Text(
          'This is body medium text for secondary content.',
          style: OscarTypography.bodyMedium,
        ),
        OscarSpacing.space2,
        Text(
          'Caption text for metadata and additional information',
          style: OscarTypography.caption,
        ),
      ],
    );
  }

  Widget _buildButtonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buttons', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,

        // Button variants
        Wrap(
          spacing: OscarDesignTokens.space3,
          runSpacing: OscarDesignTokens.space3,
          children: [
            OscarButton(
              text: 'Primary',
              onPressed: () => _showSnackBar('Primary button pressed'),
              variant: OscarButtonVariant.primary,
            ),
            OscarButton(
              text: 'Secondary',
              onPressed: () => _showSnackBar('Secondary button pressed'),
              variant: OscarButtonVariant.secondary,
            ),
            OscarButton(
              text: 'Ghost',
              onPressed: () => _showSnackBar('Ghost button pressed'),
              variant: OscarButtonVariant.ghost,
            ),
            OscarButton(
              text: 'Filled',
              onPressed: () => _showSnackBar('Filled button pressed'),
              variant: OscarButtonVariant.filled,
            ),
          ],
        ),

        OscarSpacing.space4,

        // Button sizes
        Text('Button Sizes', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OscarButton(
              text: 'Small Button',
              onPressed: () => _showSnackBar('Small button pressed'),
              size: OscarButtonSize.small,
            ),
            OscarSpacing.space2,
            OscarButton(
              text: 'Medium Button',
              onPressed: () => _showSnackBar('Medium button pressed'),
              size: OscarButtonSize.medium,
            ),
            OscarSpacing.space2,
            OscarButton(
              text: 'Large Button',
              onPressed: () => _showSnackBar('Large button pressed'),
              size: OscarButtonSize.large,
            ),
          ],
        ),

        OscarSpacing.space4,

        // Button with icon and loading states
        Text('Button States', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Wrap(
          spacing: OscarDesignTokens.space3,
          runSpacing: OscarDesignTokens.space3,
          children: [
            OscarButton(
              text: 'With Icon',
              icon: const Icon(Icons.emoji_events, size: 20),
              onPressed: () => _showSnackBar('Icon button pressed'),
            ),
            OscarButton(
              text: 'Loading',
              isLoading: _isLoading,
              onPressed: () => _toggleLoading(),
            ),
            OscarButton(
              text: 'Disabled',
              onPressed: null, // Disabled
            ),
          ],
        ),

        OscarSpacing.space4,

        // Full width button
        OscarButton(
          text: 'Full Width Button',
          onPressed: () => _showSnackBar('Full width button pressed'),
          isFullWidth: true,
          variant: OscarButtonVariant.primary,
        ),
      ],
    );
  }

  Widget _buildChipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chips', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,

        // Basic chips
        Text('Basic Chips', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Wrap(
          spacing: OscarDesignTokens.space2,
          runSpacing: OscarDesignTokens.space2,
          children: [
            OscarChip(
              label: 'Drama',
              onPressed: () => _showSnackBar('Drama chip pressed'),
              variant: OscarChipVariant.assist,
            ),
            OscarChip(
              label: 'Comedy',
              onPressed: () => _showSnackBar('Comedy chip pressed'),
              variant: OscarChipVariant.assist,
            ),
            OscarChip(
              label: 'Action',
              onPressed: () => _showSnackBar('Action chip pressed'),
              variant: OscarChipVariant.assist,
            ),
          ],
        ),

        OscarSpacing.space4,

        // Filter chips
        Text('Filter Chips', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Wrap(
          spacing: OscarDesignTokens.space2,
          runSpacing: OscarDesignTokens.space2,
          children: ['All', 'Winners', 'Nominees', 'Drama', 'Comedy', 'Action']
              .map(
                (filter) => OscarChip(
                  label: filter,
                  isSelected: _selectedFilters.contains(filter),
                  onPressed: () => _toggleFilter(filter),
                  variant: OscarChipVariant.filter,
                ),
              )
              .toList(),
        ),

        OscarSpacing.space4,

        // Oscar category chips
        Text('Oscar Category Chips', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Wrap(
          spacing: OscarDesignTokens.space2,
          runSpacing: OscarDesignTokens.space2,
          children: [
            OscarCategoryChip(
              category: 'Best Picture',
              isWinner: true,
              onTap: () => _showSnackBar('Best Picture selected'),
            ),
            OscarCategoryChip(
              category: 'Best Director',
              isWinner: false,
              onTap: () => _showSnackBar('Best Director selected'),
            ),
            OscarCategoryChip(
              category: 'Best Actor',
              isWinner: false,
              isSelected: true,
              onTap: () => _showSnackBar('Best Actor selected'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cards', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,

        // Basic card
        OscarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Card', style: OscarTypography.titleMedium),
              OscarSpacing.space2,
              Text(
                'This is a basic card with standard styling.',
                style: OscarTypography.bodyMedium,
              ),
            ],
          ),
        ),

        OscarSpacing.space4,

        // Card variants
        Text('Card Variants', style: OscarTypography.titleMedium),
        OscarSpacing.space3,

        OscarCard(
          variant: OscarCardVariant.elevated,
          child: Padding(
            padding: OscarSpacing.paddingMd,
            child: Text('Elevated Card'),
          ),
        ),

        OscarSpacing.space3,

        OscarCard(
          variant: OscarCardVariant.outlined,
          child: Padding(
            padding: OscarSpacing.paddingMd,
            child: Text('Outlined Card'),
          ),
        ),

        OscarSpacing.space4,

        // Content card example
        Text('Content Cards', style: OscarTypography.titleMedium),
        OscarSpacing.space3,

        OscarContentCard(
          title: 'The Shape of Water',
          subtitle: 'Best Picture Winner • 2017',
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: OscarDesignTokens.oscarGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: OscarDesignTokens.oscarBlack,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Directed by Guillermo del Toro',
                style: OscarTypography.bodyMedium,
              ),
              OscarSpacing.space2,
              Wrap(
                spacing: OscarDesignTokens.space2,
                children: [
                  OscarChip(
                    label: 'Drama',
                    variant: OscarChipVariant.assist,
                    size: OscarChipSize.small,
                  ),
                  OscarChip(
                    label: 'Romance',
                    variant: OscarChipVariant.assist,
                    size: OscarChipSize.small,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            OscarButton(
              text: 'View Details',
              onPressed: () => _showSnackBar('View details pressed'),
              variant: OscarButtonVariant.ghost,
              size: OscarButtonSize.small,
            ),
            OscarButton(
              text: 'Share',
              icon: const Icon(Icons.share, size: 16),
              onPressed: () => _showSnackBar('Share pressed'),
              variant: OscarButtonVariant.secondary,
              size: OscarButtonSize.small,
            ),
          ],
          onTap: () => _showSnackBar('Card tapped'),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colors', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,

        // Primary colors
        Text('Primary Colors', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Row(
          children: [
            _buildColorSwatch('Oscar Gold', OscarDesignTokens.oscarGold),
            OscarSpacing.spaceH3,
            _buildColorSwatch('Light', OscarDesignTokens.oscarGoldLight),
            OscarSpacing.spaceH3,
            _buildColorSwatch('Dark', OscarDesignTokens.oscarGoldDark),
          ],
        ),

        OscarSpacing.space4,

        // Status colors
        Text('Status Colors', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Row(
          children: [
            _buildColorSwatch('Winner', OscarDesignTokens.winner),
            OscarSpacing.spaceH3,
            _buildColorSwatch('Special', OscarDesignTokens.special),
            OscarSpacing.spaceH3,
            _buildColorSwatch('Error', OscarDesignTokens.error),
          ],
        ),

        OscarSpacing.space4,

        // Neutral colors
        Text('Neutral Colors', style: OscarTypography.titleMedium),
        OscarSpacing.space3,
        Wrap(
          spacing: OscarDesignTokens.space2,
          runSpacing: OscarDesignTokens.space2,
          children: [
            _buildColorSwatch('50', OscarDesignTokens.neutral50),
            _buildColorSwatch('100', OscarDesignTokens.neutral100),
            _buildColorSwatch('200', OscarDesignTokens.neutral200),
            _buildColorSwatch('300', OscarDesignTokens.neutral300),
            _buildColorSwatch('400', OscarDesignTokens.neutral400),
            _buildColorSwatch('500', OscarDesignTokens.neutral500),
            _buildColorSwatch('600', OscarDesignTokens.neutral600),
            _buildColorSwatch('700', OscarDesignTokens.neutral700),
            _buildColorSwatch('800', OscarDesignTokens.neutral800),
            _buildColorSwatch('900', OscarDesignTokens.neutral900),
          ],
        ),
      ],
    );
  }

  Widget _buildSpacingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spacing', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,

        Text('Vertical Spacing Examples', style: OscarTypography.titleMedium),
        OscarSpacing.space3,

        Container(
          padding: OscarSpacing.paddingMd,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpacingDemo('Item 1', null),
              OscarSpacing.space1,
              _buildSpacingDemo('Item 2', 'space1 (4px)'),
              OscarSpacing.space2,
              _buildSpacingDemo('Item 3', 'space2 (8px)'),
              OscarSpacing.space4,
              _buildSpacingDemo('Item 4', 'space4 (16px)'),
              OscarSpacing.space6,
              _buildSpacingDemo('Item 5', 'space6 (24px)'),
            ],
          ),
        ),

        OscarSpacing.space4,

        Text('Padding Examples', style: OscarTypography.titleMedium),
        OscarSpacing.space3,

        Row(
          children: [
            Expanded(
              child: Container(
                padding: OscarSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    OscarDesignTokens.radiusLg,
                  ),
                ),
                child: Text(
                  'Small Padding',
                  style: OscarTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            OscarSpacing.spaceH3,
            Expanded(
              child: Container(
                padding: OscarSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    OscarDesignTokens.radiusLg,
                  ),
                ),
                child: Text(
                  'Medium Padding',
                  style: OscarTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            OscarSpacing.spaceH3,
            Expanded(
              child: Container(
                padding: OscarSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    OscarDesignTokens.radiusLg,
                  ),
                ),
                child: Text(
                  'Large Padding',
                  style: OscarTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    final isLight = color.computeLuminance() > 0.5;
    final textColor = isLight ? Colors.black : Colors.white;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: OscarTypography.labelSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingDemo(String text, String? spacing) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        OscarSpacing.spaceH3,
        Text(text, style: OscarTypography.bodyMedium),
        if (spacing != null) ...[
          OscarSpacing.spaceH3,
          Text('($spacing)', style: OscarTypography.caption),
        ],
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });

    if (_isLoading) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }
}
