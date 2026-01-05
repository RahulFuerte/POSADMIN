# Design Document: Admin UI Consistency

## Overview

This design standardizes the Admin App UI to match the design system in `ADMIN_APP_UI_DESCRIPTION.md`. The implementation focuses on creating reusable UI components and ensuring all screens use consistent colors, typography, and styling patterns.

## Architecture

The UI consistency will be achieved through:

1. **Centralized Constants** - All colors, dimensions, and styling values in `lib/constants/colors.dart`
2. **Reusable Widgets** - Common UI patterns extracted into reusable widget components
3. **Screen Utility** - Responsive sizing using the `Screen` class in `lib/screen.dart`

```
┌─────────────────────────────────────────────────────────────┐
│                      App Screens                            │
│  (splash_screen, adminDashboard, addDepartmentScreen, etc.) │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Reusable Widgets                          │
│  (CustomButton, CustomTextField, StatusIndicator, etc.)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Constants                              │
│  (colors.dart, text_styles.dart)                           │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Color Constants (colors.dart)

The existing `colors.dart` already defines most required colors. Key constants:

```dart
// Primary colors
const primaryColor = Color.fromARGB(255, 12, 107, 15);
const secondaryColor = Colors.white;
const backgroundColor = Color.fromARGB(255, 240, 240, 240);

// Theme accent
const themeAccent = Color.fromARGB(153, 5, 93, 8); // 0.6 opacity
const themeAccentSolid = Color.fromARGB(255, 5, 93, 8);

// Status colors
const successColor = Colors.green;
const warningColor = Colors.orange;
const errorColor = Colors.red;
```

### 2. Custom Button Widget

```dart
class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: backgroundColor ?? themeAccent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: buttonTextStyle),
              if (icon != null) ...[
                SizedBox(width: 20),
                Icon(icon, color: white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. Custom Text Form Field Widget

```dart
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: TextFormField(
          controller: controller,
          cursorColor: black,
          style: TextStyle(fontSize: 18.2, letterSpacing: 1),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            border: InputBorder.none,
            hintStyle: TextStyle(color: grey),
          ),
        ),
      ),
    );
  }
}
```

### 4. Connection Status Indicator Widget

```dart
class ConnectionStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final int pendingCount;
  
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isOnline ? successColor : warningColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? successColor : warningColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: isOnline ? successColor : warningColor,
          ),
          SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOnline ? successColor : warningColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5. Standard AppBar

```dart
AppBar buildStandardAppBar({
  required String title,
  List<Widget>? actions,
  bool showStatusIndicator = false,
}) {
  return AppBar(
    backgroundColor: white,
    elevation: 0,
    title: Row(
      children: [
        Text(title, style: screenTitleStyle),
        if (showStatusIndicator) ...[
          SizedBox(width: 8),
          ConnectionStatusIndicator(isOnline: true),
        ],
      ],
    ),
    actions: actions,
    iconTheme: IconThemeData(color: black),
  );
}
```

### 6. Zero AppBar (for Splash Screen)

```dart
const ZeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  Size get preferredSize => Size.zero;
}
```

## Data Models

No new data models required. This feature focuses on UI presentation layer only.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Active/Selected States Use Primary Color

*For any* widget displaying a selected or active state, the highlight color SHALL be `primaryColor` or `primaryColor.withOpacity(0.1)` for backgrounds.

**Validates: Requirements 1.1, 1.5, 2.4, 6.4**

### Property 2: Status Indicator Color Consistency

*For any* connection status indicator, WHEN `isOnline` is true THEN the indicator SHALL display `successColor` (green) with `cloud_done` icon, AND WHEN `isOnline` is false THEN the indicator SHALL display `warningColor` (orange) with `cloud_off` icon.

**Validates: Requirements 7.1, 7.2**

### Property 3: Card and Container Styling Consistency

*For any* Card widget used for content containers, the Card SHALL have elevation 5 and borderRadius 10. *For any* list item Container, it SHALL have white background, borderRadius 8, and consistent box shadow.

**Validates: Requirements 5.1, 5.2, 5.3**

### Property 4: Button Border Radius Consistency

*For any* button widget in the app, the button SHALL have a BorderRadius between 10 and 30 pixels.

**Validates: Requirements 3.4**

### Property 5: Animation Duration and Curve Consistency

*For any* AnimatedContainer in the app, the duration SHALL be between 300ms and 600ms, AND the curve SHALL be either `Curves.bounceOut` or `Curves.easeInOut`.

**Validates: Requirements 9.1, 9.2**

### Property 6: Responsive Layout Breakpoint

*For any* screen with responsive layout, WHEN screen width is less than 600px THEN the mobile layout SHALL be displayed, AND WHEN screen width is 600px or greater THEN the tablet/web layout SHALL be displayed.

**Validates: Requirements 10.2**

## Error Handling

- If custom fonts fail to load, fall back to system fonts
- If Lottie animations fail to load, display static placeholder or loading indicator
- If color constants are missing, use Flutter's default Material colors as fallback

## Testing Strategy

### Unit Tests
- Verify color constant values match design specification
- Verify widget properties (elevation, borderRadius, colors) match requirements
- Test Screen utility calculations for different screen sizes

### Property-Based Tests
- Test that all selected states across different widgets use primaryColor
- Test status indicator displays correct color/icon for all boolean states
- Test card styling properties are consistent across all card instances
- Test button borderRadius falls within valid range
- Test AnimatedContainer properties are within specified ranges
- Test layout breakpoint behavior at various screen widths

### Widget Tests
- Test CustomButton renders with correct styling
- Test CustomTextFormField renders with correct decoration
- Test ConnectionStatusIndicator shows correct state
- Test AppBar configurations match design spec
- Test Drawer menu styling and selected state highlighting

### Integration Tests
- Navigate through all screens and verify visual consistency
- Test responsive behavior by resizing window/changing orientation
