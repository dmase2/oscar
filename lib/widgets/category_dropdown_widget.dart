import 'package:flutter/material.dart';

/// A reusable dropdown widget for selecting Oscar categories
/// Provides consistent styling and priority category ordering across screens
class CategoryDropdownWidget extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categoryList;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final bool showAllOscars;
  final String actingCategoriesValue;
  final String actingCategoriesLabel;

  // Priority categories that should appear first and in bold
  static const Set<String> _priorityCategories = {
    'Best Picture',
    'Best Director',
    'Best Actor',
    'Best Actress',
    'Best Supporting Actor',
    'Best Supporting Actress',
    'Best Cinematography',
    'Best Original Screenplay',
    'Best Adapted Screenplay',
    'Best Film Editing',
    'Best Original Score',
    'Best Original Song',
    'Best Production Design',
    'Best Costume Design',
    'Best Makeup and Hairstyling',
    'Best Visual Effects',
    'Best Sound',
    'Best International Feature Film',
    'Best Animated Feature',
    'Best Documentary Feature',
    // Legacy category names for compatibility
    'ACTOR IN A LEADING ROLE',
    'ACTRESS IN A LEADING ROLE',
    'ACTOR IN A SUPPORTING ROLE',
    'ACTRESS IN A SUPPORTING ROLE',
    'BEST PICTURE',
    'CINEMATOGRAPHY',
    'DIRECTING',
    'WRITING (Original Screenplay)',
    'WRITING (Adapted Screenplay)',
  };

  const CategoryDropdownWidget({
    super.key,
    required this.selectedCategory,
    required this.categoryList,
    required this.onChanged,
    this.hintText = 'Filter by category',
    this.showAllOscars = true,
    this.actingCategoriesValue = 'ALL_ACTING',
    this.actingCategoriesLabel = 'All Acting Categories',
  });

  /// Check if a category should be styled as a priority category
  bool _isPriorityCategory(String category) {
    return _priorityCategories.contains(category);
  }

  /// Get sorted category list with priority categories first
  List<String> _getSortedCategories() {
    final sortedCategories = List<String>.from(categoryList);

    sortedCategories.sort((a, b) {
      final aPriority = _isPriorityCategory(a);
      final bPriority = _isPriorityCategory(b);

      if (aPriority && !bPriority) {
        return -1; // a comes before b
      } else if (!aPriority && bPriority) {
        return 1; // b comes before a
      } else {
        return a.compareTo(b); // alphabetical within same priority level
      }
    });

    return sortedCategories;
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = _getSortedCategories();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String?>(
        value: selectedCategory,
        hint: Text(
          hintText,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
        isExpanded: true,
        itemHeight: 48,
        isDense: false,
        dropdownColor: theme.colorScheme.surface,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'All Categories',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (showAllOscars)
            DropdownMenuItem<String?>(
              value: 'ALL_OSCARS',
              child: Text(
                'All Oscars',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          DropdownMenuItem<String?>(
            value: actingCategoriesValue,
            child: Text(
              actingCategoriesLabel,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ...sortedCategories.map(
            (cat) => DropdownMenuItem<String?>(
              value: cat,
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _isPriorityCategory(cat)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: _isPriorityCategory(cat)
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
