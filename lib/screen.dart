import 'package:flutter/material.dart';

import 'package:pos_admin/constants/colors.dart';

// =============================================================================
// RESPONSIVE DESIGN CONSTANTS (Requirements 10.2, 10.3)
// =============================================================================

/// Mobile/tablet breakpoint - screens narrower than this use mobile layout
const double responsiveBreakpoint = 600;

// =============================================================================
// SCREEN UTILITY CLASS
// =============================================================================

/// Utility class for responsive sizing and layout calculations.
/// 
/// Usage:
/// ```dart
/// Screen s = Screen(context);
/// 
/// // Check if mobile layout should be used
/// if (s.isMobile) { ... }
/// 
/// // Scale values using customWidth multiplier
/// Padding(padding: EdgeInsets.all(20 * s.customWidth))
/// Text('Hello', style: TextStyle(fontSize: 17 * s.customWidth))
/// ```
class Screen {
  late BuildContext context;
  Screen(this.context);

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  Size get size => mediaQuery.size;

  double get infinity => double.infinity;
  double get width => size.width;
  double get height => size.height;
  
  /// Scaling multiplier based on reference device width (realmeWidth = 423).
  /// Use this to scale text, padding, and other dimensions for responsive design.
  /// 
  /// Example: `fontSize: 17 * s.customWidth`
  double get customWidth => width / realmeWidth;
  
  /// Scaling multiplier based on reference device height (realmeHeight = 941).
  double get customHeight => height / realmeHeight;
  
  double get topPadding => mediaQuery.viewPadding.top;
  double get bottomPadding => mediaQuery.viewPadding.bottom;
  
  /// Returns true if the screen width is less than the responsive breakpoint (600px).
  /// Use this to determine whether to show mobile or tablet/web layout.
  /// 
  /// Requirement 10.2: Adapt layouts for screens narrower than 600px (mobile)
  /// vs wider (tablet/web).
  bool get isMobile => width < responsiveBreakpoint;
  
  /// Returns true if the screen width is 600px or greater.
  /// Use this to determine whether to show tablet/web layout.
  bool get isTabletOrWeb => width >= responsiveBreakpoint;
  
  /// Scale a value using the customWidth multiplier.
  /// Convenience method for scaling dimensions.
  /// 
  /// Example: `s.scale(20)` instead of `20 * s.customWidth`
  double scale(double value) => value * customWidth;
  
  /// Scale a value using the customHeight multiplier.
  double scaleHeight(double value) => value * customHeight;
}

