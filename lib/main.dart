import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_admin/backend/provider/login_provider.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for consistent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCnPCE-N8H4J_Bw-NTtPeb3n2rXxxua8SA",
        authDomain: "mypos-management.firebaseapp.com",
        projectId: "mypos-management",
        storageBucket: "mypos-management.appspot.com",
        messagingSenderId: "772150199713",
        appId: "1:772150199713:web:517bd7f39ca12dc39af7e0",
        measurementId: "G-PT3E3EEQSH",
      ),
    );
    setPathUrlStrategy();
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      child: MaterialApp(
        title: 'POS Admin',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }

  /// Build the app theme matching the design system
  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: themeAccentSolid,
        surface: white,
        background: backgroundColor,
        error: errorColor,
      ),
      
      // AppBar Theme (Requirement 2.1)
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: black),
        titleTextStyle: TextStyle(
          fontFamily: 'tabfont',
          fontSize: 19,
          color: black,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Card Theme (Requirement 5.1)
      cardTheme: CardTheme(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        color: white,
      ),
      
      // Elevated Button Theme (Requirement 3)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeAccent,
          foregroundColor: white,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      // Input Decoration Theme (Requirement 4)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: grey,
          fontWeight: FontWeight.w300,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 5,
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(color: white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // Drawer Theme (Requirement 6)
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: grey.withOpacity(0.2),
        thickness: 1,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return grey;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return grey.withOpacity(0.3);
        }),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: black,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'tabfont',
          fontSize: 19,
          color: black,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'fontmain',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: black,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'fontmain',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: black,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: white,
        ),
      ),
      
      // Font Family
      fontFamily: 'fontmain',
    );
  }

  /// List of providers for state management
  static final List<SingleChildWidget> _providers = [
    ChangeNotifierProvider(create: (context) {
      LoginProvider lp = LoginProvider();
      lp.init();
      return lp;
    }),
  ];
}
