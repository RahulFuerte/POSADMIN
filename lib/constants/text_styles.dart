import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_admin/constants/colors.dart';

// =============================================================================
// TYPOGRAPHY CONSTANTS - Admin App UI (matching User-Side POS App)
// See: ADMIN_APP_UI_DESCRIPTION.md
// Implements Requirement 8
// =============================================================================

/// App branding text style using GoogleFonts.alfaSlabOne (Requirement 8.4)
TextStyle get appBrandingStyle => GoogleFonts.alfaSlabOne(
      fontSize: 35,
      fontWeight: FontWeight.w500,
      color: black,
    );

/// App branding text style for dark backgrounds
TextStyle get appBrandingStyleLight => GoogleFonts.alfaSlabOne(
      fontSize: 35,
      fontWeight: FontWeight.w500,
      color: white,
    );

/// Heading style (Requirement 8.3)
/// fontSize 24, fontWeight w800, letterSpacing 2
const TextStyle headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w800,
  letterSpacing: 2,
  color: black,
);

/// Screen title style using 'tabfont' family (Requirement 8.1)
/// fontSize 19
const TextStyle screenTitleStyle = TextStyle(
  fontFamily: 'tabfont',
  fontSize: 19,
  color: black,
);

/// Body text style using 'fontmain' family (Requirement 8.2)
/// fontSize 14, fontWeight w400
const TextStyle bodyTextStyle = TextStyle(
  fontFamily: 'fontmain',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: black,
);

/// Button text style (Requirement 3.2)
/// fontSize 17, fontWeight w600, letterSpacing 1, white color
const TextStyle buttonTextStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  letterSpacing: 1,
  color: white,
);

/// Description text style
/// fontSize 16, letterSpacing 1
const TextStyle descriptionStyle = TextStyle(
  fontSize: 16,
  letterSpacing: 1,
  color: black,
);

/// Label text style for form fields
const TextStyle labelStyle = TextStyle(
  letterSpacing: 1.3,
  fontSize: 14,
  fontFamily: 'fontmain',
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

/// Hint text style for form fields
const TextStyle hintStyle = TextStyle(
  fontWeight: FontWeight.w300,
  color: grey,
);

/// Input text style for form fields (Requirement 4.2)
/// fontSize 18.2, letterSpacing 1
const TextStyle inputTextStyle = TextStyle(
  fontSize: 18.2,
  letterSpacing: 1,
  fontWeight: FontWeight.w500,
);

/// Card title style
const TextStyle cardTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: black,
);

/// Card subtitle style
const TextStyle cardSubtitleStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: grey,
);

/// Stat value style for dashboard cards
const TextStyle statValueStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: black,
);

/// Stat label style for dashboard cards
TextStyle get statLabelStyle => TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: grey.withOpacity(0.8),
    );
