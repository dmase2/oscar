import 'package:flutter/material.dart';

import '../tokens.dart';

/// Spacing utilities based on design tokens
class OscarSpacing {
  // Private constructor
  OscarSpacing._();

  /// Vertical spacing widgets
  static const Widget space0 = SizedBox(height: OscarDesignTokens.space0);
  static const Widget space1 = SizedBox(height: OscarDesignTokens.space1);
  static const Widget space2 = SizedBox(height: OscarDesignTokens.space2);
  static const Widget space3 = SizedBox(height: OscarDesignTokens.space3);
  static const Widget space4 = SizedBox(height: OscarDesignTokens.space4);
  static const Widget space5 = SizedBox(height: OscarDesignTokens.space5);
  static const Widget space6 = SizedBox(height: OscarDesignTokens.space6);
  static const Widget space8 = SizedBox(height: OscarDesignTokens.space8);
  static const Widget space10 = SizedBox(height: OscarDesignTokens.space10);
  static const Widget space12 = SizedBox(height: OscarDesignTokens.space12);
  static const Widget space16 = SizedBox(height: OscarDesignTokens.space16);
  static const Widget space20 = SizedBox(height: OscarDesignTokens.space20);
  static const Widget space24 = SizedBox(height: OscarDesignTokens.space24);

  /// Horizontal spacing widgets
  static const Widget spaceH0 = SizedBox(width: OscarDesignTokens.space0);
  static const Widget spaceH1 = SizedBox(width: OscarDesignTokens.space1);
  static const Widget spaceH2 = SizedBox(width: OscarDesignTokens.space2);
  static const Widget spaceH3 = SizedBox(width: OscarDesignTokens.space3);
  static const Widget spaceH4 = SizedBox(width: OscarDesignTokens.space4);
  static const Widget spaceH5 = SizedBox(width: OscarDesignTokens.space5);
  static const Widget spaceH6 = SizedBox(width: OscarDesignTokens.space6);
  static const Widget spaceH8 = SizedBox(width: OscarDesignTokens.space8);
  static const Widget spaceH10 = SizedBox(width: OscarDesignTokens.space10);
  static const Widget spaceH12 = SizedBox(width: OscarDesignTokens.space12);
  static const Widget spaceH16 = SizedBox(width: OscarDesignTokens.space16);
  static const Widget spaceH20 = SizedBox(width: OscarDesignTokens.space20);
  static const Widget spaceH24 = SizedBox(width: OscarDesignTokens.space24);

  /// Custom spacing
  static SizedBox vertical(double height) => SizedBox(height: height);
  static SizedBox horizontal(double width) => SizedBox(width: width);

  /// Padding utilities
  static const EdgeInsets paddingNone = EdgeInsets.zero;
  static const EdgeInsets paddingXs = EdgeInsets.all(OscarDesignTokens.space1);
  static const EdgeInsets paddingSm = EdgeInsets.all(OscarDesignTokens.space2);
  static const EdgeInsets paddingMd = EdgeInsets.all(OscarDesignTokens.space4);
  static const EdgeInsets paddingLg = EdgeInsets.all(OscarDesignTokens.space6);
  static const EdgeInsets paddingXl = EdgeInsets.all(OscarDesignTokens.space8);
  static const EdgeInsets padding2Xl = EdgeInsets.all(
    OscarDesignTokens.space12,
  );

  /// Horizontal padding
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(
    horizontal: OscarDesignTokens.space1,
  );
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: OscarDesignTokens.space2,
  );
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: OscarDesignTokens.space4,
  );
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: OscarDesignTokens.space6,
  );
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(
    horizontal: OscarDesignTokens.space8,
  );

  /// Vertical padding
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(
    vertical: OscarDesignTokens.space1,
  );
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(
    vertical: OscarDesignTokens.space2,
  );
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: OscarDesignTokens.space4,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: OscarDesignTokens.space6,
  );
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(
    vertical: OscarDesignTokens.space8,
  );

  /// Page-level padding (responsive)
  static EdgeInsets pagePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < OscarDesignTokens.breakpointSm) {
      return const EdgeInsets.all(OscarDesignTokens.space4);
    } else if (screenWidth < OscarDesignTokens.breakpointMd) {
      return const EdgeInsets.all(OscarDesignTokens.space6);
    } else {
      return const EdgeInsets.all(OscarDesignTokens.space8);
    }
  }

  /// Card padding (consistent across the app)
  static const EdgeInsets cardPadding = EdgeInsets.all(
    OscarDesignTokens.space4,
  );
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(
    OscarDesignTokens.space6,
  );

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: OscarDesignTokens.space4,
    vertical: OscarDesignTokens.space3,
  );
}
