# Oscar Design System

A comprehensive design system for the Oscar mobile application, providing consistent visual design and user experience across the entire app.

## Overview

The Oscar Design System is built on top of Flutter's Material Design 3 system and provides:

- **Design Tokens**: Core design values (colors, typography, spacing, etc.)
- **Theme Configuration**: Light and dark theme definitions
- **Reusable Components**: Pre-built UI components following design standards
- **Utilities**: Helper classes for consistent styling

## Structure

```
lib/design_system/
├── design_system.dart          # Barrel file (main export)
├── tokens.dart                 # Design tokens (colors, spacing, etc.)
├── theme.dart                  # Theme configuration
├── components/
│   ├── oscar_button.dart       # Button components
│   ├── oscar_card.dart         # Card components
│   └── oscar_chip.dart         # Chip components
└── utilities/
    ├── spacing.dart            # Spacing utilities
    └── typography.dart         # Typography utilities
```

## Getting Started

### 1. Import the Design System

```dart
import 'package:oscars/design_system/design_system.dart';
```

### 2. Apply the Theme

In your `MaterialApp`:

```dart
MaterialApp(
  theme: OscarTheme.lightTheme,
  darkTheme: OscarTheme.darkTheme,
  themeMode: ThemeMode.system,
  home: MyHomePage(),
)
```

## Design Tokens

### Colors

The design system uses an Oscar-themed color palette:

```dart
// Primary Colors
OscarDesignTokens.oscarGold      // #D4AF37
OscarDesignTokens.oscarGoldLight // #E6C868
OscarDesignTokens.oscarGoldDark  // #A8861C

// Status Colors
OscarDesignTokens.winner         // #FFD700 (Bright gold)
OscarDesignTokens.nominee        // #6B7280 (Gray)
OscarDesignTokens.special        // #059669 (Green)

// Neutral Colors
OscarDesignTokens.neutral50      // #FAFAFA
OscarDesignTokens.neutral100     // #F5F5F5
// ... (see tokens.dart for complete list)
```

### Typography

```dart
// Font Sizes
OscarDesignTokens.fontSizeXs     // 12px
OscarDesignTokens.fontSizeSm     // 14px
OscarDesignTokens.fontSizeBase   // 16px
OscarDesignTokens.fontSizeLg     // 18px
// ... (see tokens.dart for complete list)

// Font Weights
OscarDesignTokens.fontWeightLight     // 300
OscarDesignTokens.fontWeightRegular   // 400
OscarDesignTokens.fontWeightMedium    // 500
OscarDesignTokens.fontWeightSemiBold  // 600
OscarDesignTokens.fontWeightBold      // 700
```

### Spacing

```dart
// Spacing Values
OscarDesignTokens.space1     // 4px
OscarDesignTokens.space2     // 8px
OscarDesignTokens.space3     // 12px
OscarDesignTokens.space4     // 16px
// ... (see tokens.dart for complete list)
```

## Components

### OscarButton

```dart
// Primary button
OscarButton(
  text: 'View Details',
  onPressed: () => {},
  variant: OscarButtonVariant.primary,
  size: OscarButtonSize.medium,
)

// Secondary button with icon
OscarButton(
  text: 'Share',
  icon: Icon(Icons.share),
  onPressed: () => {},
  variant: OscarButtonVariant.secondary,
)

// Loading state
OscarButton(
  text: 'Loading...',
  isLoading: true,
  onPressed: () => {},
)
```

### OscarCard

```dart
// Standard card
OscarCard(
  child: Text('Card content'),
  variant: OscarCardVariant.standard,
  onTap: () => {},
)

// Content card with header and actions
OscarContentCard(
  title: 'Best Picture',
  subtitle: '2024',
  leading: Icon(Icons.emoji_events),
  content: Text('Card content goes here'),
  actions: [
    OscarButton(
      text: 'View',
      onPressed: () => {},
      variant: OscarButtonVariant.ghost,
      size: OscarButtonSize.small,
    ),
  ],
)
```

### OscarChip

```dart
// Basic chip
OscarChip(
  label: 'Drama',
  onPressed: () => {},
  variant: OscarChipVariant.assist,
)

// Category chip for Oscar categories
OscarCategoryChip(
  category: 'Best Picture',
  isWinner: true,
  onTap: () => {},
)

// Filter chip
OscarChip(
  label: 'Winners Only',
  isSelected: true,
  onPressed: () => {},
  variant: OscarChipVariant.filter,
)
```

## Utilities

### Spacing

```dart
Column(
  children: [
    Text('First item'),
    OscarSpacing.space4,  // 16px vertical spacing
    Text('Second item'),
    OscarSpacing.space6,  // 24px vertical spacing
    Text('Third item'),
  ],
)

// Horizontal spacing
Row(
  children: [
    Text('Left'),
    OscarSpacing.spaceH3,  // 12px horizontal spacing
    Text('Right'),
  ],
)

// Padding utilities
Container(
  padding: OscarSpacing.paddingMd,  // 16px all around
  child: Text('Padded content'),
)
```

### Typography

```dart
// Using predefined styles
Text(
  'Oscar Winner',
  style: OscarTypography.titleLarge,
)

// Using specialized Oscar styles
Text(
  '2024',
  style: OscarTypography.oscarYear,
)

Text(
  'The Shape of Water',
  style: OscarTypography.movieTitle,
)

Text(
  'Guillermo del Toro',
  style: OscarTypography.nomineeName,
)

// Applying theme colors
Text(
  'Primary text',
  style: OscarTypography.withThemeColor(
    OscarTypography.bodyLarge,
    context,
    ColorType.primary,
  ),
)

// Style modifiers
Text(
  'Bold text',
  style: OscarTypography.bold(OscarTypography.bodyMedium),
)
```

## Theme Integration

The design system automatically integrates with Flutter's theme system:

```dart
// In your widgets, use theme colors
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Themed text',
    style: Theme.of(context).textTheme.titleMedium,
  ),
)
```

## Responsive Design

The design system includes responsive utilities:

```dart
// Responsive padding
Padding(
  padding: OscarSpacing.pagePadding(context),
  child: YourContent(),
)

// Responsive typography
Text(
  'Responsive text',
  style: TextStyle(
    fontSize: OscarTypography.responsiveFontSize(
      context, 
      OscarDesignTokens.fontSizeBase,
    ),
  ),
)
```

## Best Practices

### 1. Use Design Tokens

Instead of hardcoding values, use design tokens:

```dart
// ❌ Don't do this
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFD4AF37),
    borderRadius: BorderRadius.circular(8),
  ),
)

// ✅ Do this
Container(
  padding: OscarSpacing.paddingMd,
  decoration: BoxDecoration(
    color: OscarDesignTokens.oscarGold,
    borderRadius: BorderRadius.circular(OscarDesignTokens.radiusLg),
  ),
)
```

### 2. Use Components Over Manual Styling

```dart
// ❌ Don't manually style buttons
ElevatedButton(
  onPressed: () => {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    // ... lots of manual styling
  ),
  child: Text('Button'),
)

// ✅ Use the design system component
OscarButton(
  text: 'Button',
  onPressed: () => {},
  variant: OscarButtonVariant.primary,
)
```

### 3. Follow Typography Hierarchy

```dart
// Use appropriate typography styles
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Movie Title', style: OscarTypography.movieTitle),
    OscarSpacing.space2,
    Text('Director Name', style: OscarTypography.nomineeName),
    OscarSpacing.space1,
    Text('Category', style: OscarTypography.categoryName),
  ],
)
```

### 4. Leverage Theme Integration

```dart
// Components automatically adapt to theme
Card(
  // Uses theme colors automatically
  child: ListTile(
    title: Text('Theme-aware text'),  // Uses theme text color
    // ...
  ),
)
```

## Customization

### Adding New Components

1. Create a new file in `lib/design_system/components/`
2. Follow the existing component patterns
3. Export it in `design_system.dart`

### Extending Design Tokens

1. Add new tokens to `tokens.dart`
2. Update the theme in `theme.dart` if needed
3. Document the new tokens in this README

### Theme Customization

Modify `theme.dart` to adjust colors, typography, or component themes:

```dart
// Example: Custom color scheme
static const ColorScheme _lightColorScheme = ColorScheme.light(
  primary: YourCustomColor.primary,
  // ... other colors
);
```

## Dark Mode Support

The design system fully supports dark mode:

- Colors automatically switch between light/dark variants
- Components adapt their appearance
- Typography remains consistent across themes
- Use `Theme.of(context).colorScheme` for theme-aware colors

## Accessibility

The design system follows accessibility best practices:

- Sufficient color contrast ratios
- Touch target sizes meet minimum requirements (44px)
- Semantic color usage (error colors for errors, etc.)
- Screen reader friendly component structure

## Migration Guide

### From Manual Styling

1. Replace hardcoded colors with design tokens
2. Replace manual spacing with spacing utilities
3. Replace custom text styles with typography utilities
4. Replace manual components with design system components

### Example Migration

```dart
// Before
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    children: [
      Text(
        'Title',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 12),
      Text('Content'),
    ],
  ),
)

// After
OscarContentCard(
  title: 'Title',
  content: Text('Content'),
)
```

## Contributing

When contributing to the design system:

1. Follow the existing patterns and conventions
2. Add proper documentation for new components
3. Test in both light and dark themes
4. Ensure accessibility compliance
5. Update this README with new features
