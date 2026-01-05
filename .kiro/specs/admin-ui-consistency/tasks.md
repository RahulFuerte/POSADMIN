# Implementation Plan: Admin UI Consistency

## Overview

This plan implements UI consistency across the Admin App by updating color usage, creating reusable widgets, and standardizing styling patterns to match `ADMIN_APP_UI_DESCRIPTION.md`.

## Tasks

- [x] 1. Update Color Constants
  - [x] 1.1 Verify and update `lib/constants/colors.dart` with any missing design system colors
    - Ensure all colors from design spec are defined
    - Add any missing status colors or theme variants
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Create Reusable UI Widgets
  - [x] 2.1 Create `ConnectionStatusIndicator` widget in `lib/widgets/`
    - Implement online/offline states with correct colors and icons
    - Support optional pending count badge
    - _Requirements: 7.1, 7.2, 7.3_
  - [ ]* 2.2 Write property test for ConnectionStatusIndicator
    - **Property 2: Status Indicator Color Consistency**
    - **Validates: Requirements 7.1, 7.2**
  - [x] 2.3 Create or update `CustomButton` widget matching design spec
    - Card with elevation 5, borderRadius 10
    - Correct text styling (white, w600, fontSize 17, letterSpacing 1)
    - _Requirements: 3.1, 3.2, 3.4_
  - [ ]* 2.4 Write property test for button border radius
    - **Property 4: Button Border Radius Consistency**
    - **Validates: Requirements 3.4**

- [x] 3. Checkpoint - Verify widgets compile and basic tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Update AdminDashboard Screen
  - [x] 4.1 Fix drawer item selected state colors in `adminDashboard.dart`
    - Replace `Color(0xFFFF5757)` with `primaryColor` for selected states
    - Ensure consistent use of primaryColor.withOpacity(0.1) for backgrounds
    - _Requirements: 1.5, 6.4_
  - [x] 4.2 Update AppBar styling to match design spec
    - White background, zero elevation
    - Consistent icon theming
    - _Requirements: 2.1, 2.4_
  - [x] 4.3 Update drawer header styling
    - primaryColor background
    - Correct typography for shop name and phone
    - _Requirements: 6.1, 6.2, 6.3_
  - [ ]* 4.4 Write property test for selected state colors
    - **Property 1: Active/Selected States Use Primary Color**
    - **Validates: Requirements 1.1, 1.5, 2.4, 6.4**

- [x] 5. Update AddDepartmentScreen
  - [x] 5.1 Update button styling in `addDepartmentScreen.dart`
    - Use consistent borderRadius and colors
    - Apply themeAccent for primary actions
    - _Requirements: 3.1, 3.4_
  - [x] 5.2 Update form field styling
    - Ensure Cards wrap TextFormFields with elevation 5
    - Correct text and hint styling
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  - [x] 5.3 Update card styling for image container and form sections
    - Consistent elevation, borderRadius, padding
    - _Requirements: 5.1, 5.3_
  - [ ]* 5.4 Write property test for card styling
    - **Property 3: Card and Container Styling Consistency**
    - **Validates: Requirements 5.1, 5.2, 5.3**

- [x] 6. Update Splash Screen
  - [x] 6.1 Verify ZeroAppBar implementation in `splash_screen.dart`
    - toolbarHeight 0, white status bar
    - _Requirements: 2.2_
  - [x] 6.2 Update typography to use correct fonts
    - GoogleFonts.alfaSlabOne for branding
    - Correct font families for other text
    - _Requirements: 8.1, 8.2, 8.4_
  - [x] 6.3 Verify Lottie animation configuration
    - frameRate 90, correct sizing
    - _Requirements: 9.3_

- [x] 7. Checkpoint - Verify screen updates
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Update Animation Consistency
  - [x] 8.1 Audit and update AnimatedContainer usages across screens
    - Duration between 300-600ms
    - Use Curves.bounceOut or Curves.easeInOut
    - _Requirements: 9.1, 9.2_
  - [ ]* 8.2 Write property test for animation parameters
    - **Property 5: Animation Duration and Curve Consistency**
    - **Validates: Requirements 9.1, 9.2**

- [x] 9. Update Responsive Design
  - [x] 9.1 Verify Screen utility class usage in responsive layouts
    - Ensure 600px breakpoint is used consistently
    - Apply customWidth multiplier for scaling
    - _Requirements: 10.2, 10.3_
  - [ ]* 9.2 Write property test for responsive breakpoint
    - **Property 6: Responsive Layout Breakpoint**
    - **Validates: Requirements 10.2**

- [x] 10. Final Checkpoint - Complete verification
  - Ensure all tests pass, ask the user if questions arise.
  - Verify visual consistency across all updated screens

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Focus on fixing existing code rather than creating new screens
