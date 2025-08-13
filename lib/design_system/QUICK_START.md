# Oscar Design System - Quick Start Guide

This guide will help you quickly integrate the Oscar Design System into your existing app and start using it effectively.

## 1. Basic Setup

### Update main.dart

Replace your existing theme with the Oscar theme:

```dart
import 'package:flutter/material.dart';
import 'design_system/design_system.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oscar App',
      // Replace your existing theme with Oscar theme
      theme: OscarTheme.lightTheme,
      darkTheme: OscarTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: MyHomePage(),
    );
  }
}
```

## 2. Import the Design System

In any file where you want to use design system components:

```dart
import 'package:your_app/design_system/design_system.dart';
```

## 3. Common Replacements

### Replace Manual Colors

```dart
// ❌ Before
Container(
  color: Color(0xFFD4AF37),
  child: Text('Winner'),
)

// ✅ After
Container(
  color: OscarDesignTokens.oscarGold,
  child: Text('Winner'),
)
```

### Replace Manual Spacing

```dart
// ❌ Before
Column(
  children: [
    Text('First'),
    SizedBox(height: 16),
    Text('Second'),
  ],
)

// ✅ After
Column(
  children: [
    Text('First'),
    OscarSpacing.space4,
    Text('Second'),
  ],
)
```

### Replace Manual Button Styling

```dart
// ❌ Before
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  child: Text('Click Me'),
)

// ✅ After
OscarButton(
  text: 'Click Me',
  onPressed: () {},
  variant: OscarButtonVariant.primary,
)
```

### Replace Manual Cards

```dart
// ❌ Before
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Content'),
      ],
    ),
  ),
)

// ✅ After
OscarContentCard(
  title: 'Title',
  content: Text('Content'),
)
```

### Replace Manual Text Styles

```dart
// ❌ Before
Text(
  'Movie Title',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  ),
)

// ✅ After
Text(
  'Movie Title',
  style: OscarTypography.movieTitle,
)
```

## 4. Quick Migration Checklist

### Step 1: Theme Integration (5 minutes)
- [ ] Update `main.dart` to use `OscarTheme.lightTheme` and `OscarTheme.darkTheme`
- [ ] Test app launch and basic navigation

### Step 2: Replace Hardcoded Colors (10-15 minutes)
- [ ] Search for `Color(0x` in your codebase
- [ ] Replace with appropriate `OscarDesignTokens` colors
- [ ] Search for `Colors.` and replace common colors

### Step 3: Replace Spacing (10-15 minutes)
- [ ] Search for `SizedBox(height:` and `SizedBox(width:`
- [ ] Replace with `OscarSpacing` utilities
- [ ] Search for `EdgeInsets.` and replace with `OscarSpacing` padding utilities

### Step 4: Replace Text Styles (15-20 minutes)
- [ ] Search for `TextStyle(` definitions
- [ ] Replace with `OscarTypography` styles
- [ ] Update specialized text (movie titles, nominees, etc.)

### Step 5: Replace Components (20-30 minutes)
- [ ] Replace `ElevatedButton`, `OutlinedButton`, etc. with `OscarButton`
- [ ] Replace complex `Card` widgets with `OscarCard` or `OscarContentCard`
- [ ] Replace `Chip` widgets with `OscarChip`

## 5. Common Patterns

### Oscar Movie Card

```dart
OscarContentCard(
  title: movie.title,
  subtitle: '${movie.year} • ${movie.category}',
  leading: movie.isWinner 
    ? Icon(Icons.emoji_events, color: OscarDesignTokens.winner)
    : null,
  content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Directed by ${movie.director}', style: OscarTypography.nomineeName),
      OscarSpacing.space2,
      Wrap(
        spacing: OscarDesignTokens.space2,
        children: movie.genres.map((genre) => 
          OscarChip(
            label: genre,
            variant: OscarChipVariant.assist,
            size: OscarChipSize.small,
          ),
        ).toList(),
      ),
    ],
  ),
  actions: [
    OscarButton(
      text: 'Details',
      onPressed: () => showDetails(movie),
      variant: OscarButtonVariant.ghost,
      size: OscarButtonSize.small,
    ),
  ],
  onTap: () => navigateToMovie(movie),
)
```

### Filter Bar

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: OscarSpacing.paddingHorizontalMd,
  child: Row(
    children: categories.map((category) => 
      Padding(
        padding: EdgeInsets.only(right: OscarDesignTokens.space2),
        child: OscarCategoryChip(
          category: category.name,
          isWinner: category.hasWinner,
          isSelected: selectedCategories.contains(category.id),
          onTap: () => toggleCategory(category.id),
        ),
      ),
    ).toList(),
  ),
)
```

### Page Layout

```dart
Scaffold(
  appBar: AppBar(
    title: Text('Page Title'),
  ),
  body: SingleChildScrollView(
    padding: OscarSpacing.pagePadding(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Section Title', style: OscarTypography.headlineMedium),
        OscarSpacing.space4,
        // Your content here
      ],
    ),
  ),
)
```

## 6. Testing Your Migration

1. **Visual Testing**: Run your app and check that:
   - Colors match the Oscar theme (gold, silver, bronze accents)
   - Spacing looks consistent
   - Typography hierarchy is clear
   - Components have proper styling

2. **Dark Mode Testing**: Switch to dark mode and verify:
   - All colors adapt properly
   - Text remains readable
   - Components maintain their appearance

3. **Responsive Testing**: Test on different screen sizes:
   - Text scales appropriately
   - Spacing adjusts for smaller screens
   - Components remain usable

## 7. Next Steps

Once basic migration is complete:

1. **Create Custom Components**: Build app-specific components using design system primitives
2. **Implement Consistent Patterns**: Use the same patterns across similar screens
3. **Add Animations**: Enhance components with consistent animations using design token durations
4. **Accessibility**: Leverage the design system's accessibility features

## 8. Getting Help

- Check the full documentation in `lib/design_system/README.md`
- Look at examples in `lib/design_system/examples/design_system_example.dart`
- Reference the design tokens in `lib/design_system/tokens.dart`

## 9. Common Issues & Solutions

### Issue: Colors not updating
**Solution**: Make sure you're importing the design system and using `OscarDesignTokens` instead of hardcoded colors.

### Issue: Text styles not applying
**Solution**: Ensure you're using `OscarTypography` styles and they're not being overridden by theme or parent widgets.

### Issue: Spacing looks inconsistent
**Solution**: Use `OscarSpacing` utilities consistently instead of mixing hardcoded spacing values.

### Issue: Components not following theme
**Solution**: Make sure your `MaterialApp` is using `OscarTheme.lightTheme` and `OscarTheme.darkTheme`.

---

**Estimated Total Migration Time**: 1-2 hours for a typical screen, depending on complexity.

The key is to migrate incrementally - start with theme integration, then work through each screen systematically. The design system is designed to be backward compatible, so you can migrate gradually without breaking existing functionality.
