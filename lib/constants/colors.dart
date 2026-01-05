import 'package:flutter/material.dart';

// =============================================================================
// DESIGN SYSTEM COLORS - Admin App UI (matching User-Side POS App)
// See: ADMIN_APP_UI_DESCRIPTION.md
// =============================================================================

// Primary Colors (Requirements 1.1, 1.5)
/// Main accent color for buttons, active states, and highlights
const primaryColor = Color.fromARGB(255, 12, 107, 15);

/// Alias for primaryColor - used interchangeably
const mainColor = Color.fromARGB(255, 12, 107, 15);

/// Secondary color for backgrounds and cards
const secondaryColor = Colors.white;

// Background Colors (Requirement 1.2)
/// Screen background color
const backgroundColor = Color.fromARGB(255, 240, 240, 240);

// Theme Accent Colors (Requirement 1.4)
/// Theme accent for login shapes and secondary buttons (with 0.6 opacity)
const themeAccent = Color.fromARGB(153, 5, 93, 8);

/// Solid version of theme accent (full opacity)
const themeAccentSolid = Color.fromARGB(255, 5, 93, 8);

// Status Colors (Requirement 1.3)
/// Success/online status - green
const successColor = Colors.green;

/// Warning/offline status - orange
const warningColor = Colors.orange;

/// Error/delete actions - red
const errorColor = Colors.red;

// Selected State Colors (Requirement 1.5, 6.4)
/// Background color for selected/active menu items (primaryColor with 0.1 opacity)
const selectedItemBackground = Color.fromARGB(26, 12, 107, 15);

/// Selected item highlight color for grid items
const selectedGridItemColor = Color.fromARGB(106, 133, 238, 187);

// =============================================================================
// STANDARD MATERIAL COLORS
// =============================================================================

const red = Colors.red;
const pink = Colors.pink;
const pinkAccent = Colors.pinkAccent;
const redAccent = Colors.redAccent;
const deepOrange = Colors.deepOrange;
const deepOrangeAccent = Colors.deepOrangeAccent;
const orange = Colors.orange;
const orangeAccent = Colors.orangeAccent;
const amber = Colors.amber;
const amberAccent = Colors.amberAccent;
const yellow = Colors.yellow;
const yellowAccent = Colors.yellowAccent;
const lime = Colors.lime;
const limeAccent = Colors.limeAccent;
const lightGreen = Colors.lightGreen;
const lightGreenAccent = Colors.lightGreenAccent;
const green = Colors.green;
const greenAccent = Colors.greenAccent;
const teal = Colors.teal;
const tealAccent = Colors.tealAccent;
const cyan = Colors.cyan;
const cyanAccent = Colors.cyanAccent;
const lightBlue = Colors.lightBlue;
const lightBlueAccent = Colors.lightBlueAccent;
const indigo = Colors.indigo;
const indigoAccent = Colors.indigoAccent;
const purple = Colors.purple;
const purpleAccent = Colors.purpleAccent;
const deepPurple = Colors.deepPurple;
const deepPurpleAccent = Colors.deepPurpleAccent;
const blueGrey = Colors.blueGrey;
const brown = Colors.brown;
const grey = Colors.grey;
const magenta = Color(0xff7a3c5b);
const gold = Color.fromRGBO(255, 215, 0, 1);
// const theme = MaterialColor(0xFF820274, {
//   50: Color.fromRGBO(130, 2, 116, .1),
//   100: Color.fromRGBO(130, 2, 116, .2),
//   200: Color.fromRGBO(130, 2, 116, .3),
//   300: Color.fromRGBO(130, 2, 116, .4),
//   400: Color.fromRGBO(130, 2, 116, .5),
//   500: Color.fromRGBO(130, 2, 116, .6),
//   600: Color.fromRGBO(130, 2, 116, .7),
//   700: Color.fromRGBO(130, 2, 116, .8),
//   800: Color.fromRGBO(130, 2, 116, .9),
//   900: Color.fromRGBO(130, 2, 116, 1),
// });

// =============================================================================
// THEME CONFIGURATION
// =============================================================================

/// Green theme MaterialColor matching user-side POS app
const theme = MaterialColor(0xFF0C6B0F, {
  50: Color.fromRGBO(12, 107, 15, .1),
  100: Color.fromRGBO(12, 107, 15, .2),
  200: Color.fromRGBO(12, 107, 15, .3),
  300: Color.fromRGBO(12, 107, 15, .4),
  400: Color.fromRGBO(12, 107, 15, .5),
  500: Color.fromRGBO(12, 107, 15, .6),
  600: Color.fromRGBO(12, 107, 15, .7),
  700: Color.fromRGBO(12, 107, 15, .8),
  800: Color.fromRGBO(12, 107, 15, .9),
  900: Color.fromRGBO(12, 107, 15, 1),
});

// =============================================================================
// UTILITY COLORS
// =============================================================================

const iosDefault = Color.fromARGB(255, 242, 242, 242);
const secondaryTheme = Color.fromRGBO(5, 93, 8, 1); // Matches themeAccentSolid
const white = Colors.white;
const trans = Colors.transparent;
const black = Colors.black;
const blue = Colors.blue;

const mainAppColor = Color.fromARGB(255, 114, 143, 158);

// =============================================================================
// ANIMATION CONSTANTS (Requirements 9.1, 9.2)
// =============================================================================

/// Standard animation duration - minimum (300ms)
const Duration animationDurationMin = Duration(milliseconds: 300);

/// Standard animation duration - default (400ms)
const Duration animationDurationDefault = Duration(milliseconds: 400);

/// Standard animation duration - maximum (600ms)
const Duration animationDurationMax = Duration(milliseconds: 600);

/// Standard animation curve for smooth transitions
const Curve animationCurveDefault = Curves.easeInOut;

/// Bounce animation curve for playful transitions
const Curve animationCurveBounce = Curves.bounceOut;

// =============================================================================
// DIMENSION CONSTANTS
// =============================================================================

const realmeWidth = 423;
const realmeHeight = 941;
const webWidth = 1040;

// =============================================================================
// ASSET PATHS
// =============================================================================

const iconsPath = "assets/icons";
const lottiePath = "assets/lottie";
const imagesPath = "assets/images";

// =============================================================================
// OTHER CONSTANTS
// =============================================================================

const infinity = double.infinity;

const String keyLogin = "Login";

RegExp regExpEmojis = RegExp(
  '(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
);
