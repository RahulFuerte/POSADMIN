# Requirements Document

## Introduction

This feature ensures the Admin App UI matches the design system described in `ADMIN_APP_UI_DESCRIPTION.md`, creating visual consistency with the user-side POS app. The goal is to standardize colors, typography, components, and UI patterns across all screens.

## Glossary

- **Admin_App**: The Flutter-based administrative application for managing POS operations
- **Design_System**: The standardized set of colors, typography, and UI components defined in `ADMIN_APP_UI_DESCRIPTION.md`
- **Primary_Color**: The main green accent color `Color.fromARGB(255, 12, 107, 15)`
- **Theme_Accent**: The button/shape accent color `Color.fromARGB(153, 5, 93, 8)` (with 0.6 opacity)
- **Screen_Utility**: A responsive design helper class for consistent sizing across devices

## Requirements

### Requirement 1: Color System Consistency

**User Story:** As a developer, I want all screens to use the standardized color palette, so that the app has a consistent visual identity.

#### Acceptance Criteria

1. THE Admin_App SHALL use `primaryColor` (`Color.fromARGB(255, 12, 107, 15)`) for main accents, buttons, and active states
2. THE Admin_App SHALL use `backgroundColor` (`Color.fromARGB(255, 240, 240, 240)`) for screen backgrounds
3. THE Admin_App SHALL use `successColor` (green), `warningColor` (orange), and `errorColor` (red) for status indicators
4. THE Admin_App SHALL use `themeAccent` for login shapes and secondary buttons
5. WHEN displaying selected/active states THEN the Admin_App SHALL use `primaryColor` consistently

### Requirement 2: AppBar Consistency

**User Story:** As a user, I want consistent app bars across all screens, so that navigation feels familiar.

#### Acceptance Criteria

1. THE Admin_App SHALL display AppBars with white background and zero elevation
2. WHEN on the splash screen THEN the Admin_App SHALL use a Zero AppBar (toolbarHeight: 0) with white status bar
3. THE Admin_App SHALL display an offline/online status indicator in the AppBar when applicable
4. THE Admin_App SHALL use consistent icon styling (primaryColor for active, black for inactive)

### Requirement 3: Button Styling Consistency

**User Story:** As a user, I want buttons to look and feel consistent, so that I can easily identify interactive elements.

#### Acceptance Criteria

1. THE Admin_App SHALL style primary buttons with Card elevation 5, border radius 10, and themeAccent background
2. THE Admin_App SHALL display button text with white color, fontWeight w600, fontSize 17, and letterSpacing 1
3. WHEN a button is pressed THEN the Admin_App SHALL provide visual feedback consistent with the design system
4. THE Admin_App SHALL use rounded corners (BorderRadius.circular(10-30)) for all buttons

### Requirement 4: Form Field Styling

**User Story:** As a user, I want form fields to be visually consistent, so that data entry is intuitive.

#### Acceptance Criteria

1. THE Admin_App SHALL wrap TextFormFields in Cards with elevation 5 and border radius 10
2. THE Admin_App SHALL use black cursor color and fontSize 18.2 with letterSpacing 1 for input text
3. THE Admin_App SHALL display hint text in grey color
4. THE Admin_App SHALL remove default borders (InputBorder.none) from form fields

### Requirement 5: Card and List Item Styling

**User Story:** As a user, I want cards and list items to have consistent styling, so that content is easy to scan.

#### Acceptance Criteria

1. THE Admin_App SHALL style cards with elevation 5, border radius 10, and margin 8
2. THE Admin_App SHALL style list items with white background, border radius 8, and subtle box shadow
3. THE Admin_App SHALL use consistent padding (16px for cards, 12px for list items)

### Requirement 6: Drawer Menu Consistency

**User Story:** As a user, I want the drawer menu to match the design system, so that navigation is visually cohesive.

#### Acceptance Criteria

1. THE Admin_App SHALL display a DrawerHeader with primaryColor background
2. THE Admin_App SHALL show shop name and phone number in the drawer header
3. THE Admin_App SHALL style menu items with consistent icons and typography
4. THE Admin_App SHALL highlight selected menu items using primaryColor with 0.1 opacity background

### Requirement 7: Status Indicators

**User Story:** As a user, I want clear visual indicators for connection status, so that I know when I'm online or offline.

#### Acceptance Criteria

1. WHEN online THEN the Admin_App SHALL display a green indicator with cloud_done icon
2. WHEN offline THEN the Admin_App SHALL display an orange indicator with cloud_off icon
3. THE Admin_App SHALL style status indicators with rounded borders and semi-transparent backgrounds

### Requirement 8: Typography Consistency

**User Story:** As a developer, I want consistent typography across the app, so that text is readable and branded.

#### Acceptance Criteria

1. THE Admin_App SHALL use 'tabfont' family for screen titles (fontSize 19)
2. THE Admin_App SHALL use 'fontmain' family for body text (fontSize 14, fontWeight w400)
3. THE Admin_App SHALL use consistent heading styles (fontSize 24, fontWeight w800, letterSpacing 2)
4. THE Admin_App SHALL use GoogleFonts.alfaSlabOne for app branding text

### Requirement 9: Animation Consistency

**User Story:** As a user, I want smooth, consistent animations, so that the app feels polished.

#### Acceptance Criteria

1. THE Admin_App SHALL use AnimatedContainer with duration 300-600ms for transitions
2. THE Admin_App SHALL use Curves.bounceOut or Curves.easeInOut for animation curves
3. THE Admin_App SHALL use Lottie animations with frameRate 90 for loading states

### Requirement 10: Responsive Design

**User Story:** As a user, I want the app to look good on different screen sizes, so that I can use it on any device.

#### Acceptance Criteria

1. THE Admin_App SHALL use the Screen utility class for responsive sizing
2. THE Admin_App SHALL adapt layouts for screens narrower than 600px (mobile) vs wider (tablet/web)
3. THE Admin_App SHALL scale text and padding using customWidth multiplier
