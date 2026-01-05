import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/loading.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/webScreen.dart';

class Shape extends StatelessWidget {
  const Shape(
    this.s, {
    Key? key,
  }) : super(key: key);

  final Screen s;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: InceptionClipper(s.topPadding),
      child: Container(
        // color: theme,
        // color: mainAppColor,
        // color: Colors.black,
        color: themeAccent,
        width: s.width,
        height: s.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20 * s.customWidth),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Sign In',
                    textStyle: TextStyle(
                      fontSize: 43 * s.customWidth,
                      color: black,
                      fontWeight: FontWeight.w600,
                    ),
                    speed: const Duration(milliseconds: 400),
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
                pause: const Duration(seconds: 10),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20 * s.customWidth).copyWith(
                bottom: kBottomNavigationBarHeight * s.customWidth,
              ),
              child: Text(
                "Or Sign Up!",
                style: TextStyle(
                  fontSize: 26 * s.customWidth,
                  color: black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width, h = size.height;
    final path = Path();
    path.lineTo(w, 0);
    // path.conicTo(-w * 2, h / 2, w, h, 10);
    path.conicTo(-w * 10, h / 2, w, h, 0.1);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class InceptionClipper extends CustomClipper<Path> {
  final double topPadding;
  InceptionClipper(this.topPadding);
  @override
  Path getClip(Size size) {
    double w = size.width, h = size.height;
    final path = Path();
    path.lineTo(w, 0);
    path.lineTo(0, h * 0.175);
    path.lineTo(0, h * 0.825);
    path.lineTo(w, h - topPadding / 1.5);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class SocialIcon extends StatelessWidget {
  final String path;
  final VoidCallback onTap;
  const SocialIcon(
    this.path, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen s = Screen(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        shape: const CircleBorder(),
        elevation: 5,
        color: white,
        margin: EdgeInsets.only(
          top: 40 * s.customWidth,
          bottom: 125 * s.customWidth,
        ),
        child: Padding(
          padding: EdgeInsets.all(17.5 * s.customWidth),
          child: Image.asset(
            path,
            height: 40 * s.customWidth,
            width: 40 * s.customWidth,
          ),
        ),
      ),
    );
  }
}

/// Custom button widget matching design spec.
/// 
/// Implements Requirements 3.1, 3.2, 3.4:
/// - Card with elevation 5, borderRadius 10
/// - Text styling: white, w600, fontSize 17, letterSpacing 1
/// - Rounded corners (BorderRadius.circular(10-30))
class CustomButton extends StatelessWidget {
  final double? borderRadius;
  final VoidCallback onTap;
  final String label;
  final IconData? icon;
  final Color? backgroundColor, foregroundColor;
  final bool isLoading;
  
  /// Default border radius matching design spec (Requirement 3.4)
  static const double defaultBorderRadius = 10.0;
  
  const CustomButton({
    Key? key,
    required this.onTap,
    required this.isLoading,
    this.borderRadius,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen s = Screen(context);
    // Requirement 3.4: borderRadius between 10-30, default to 10
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSwitcher(
        // Requirement 9.1: Duration between 300-600ms
        reverseDuration: animationDurationMin,
        duration: animationDurationMin,
        // Requirement 9.2: Use Curves.easeInOut for smooth transitions
        switchInCurve: animationCurveDefault,
        switchOutCurve: animationCurveDefault,
        child: isLoading
            ? CPI(30 * s.customWidth)
            : Card(
                // Requirement 3.1: elevation 5
                elevation: 5,
                shape: RoundedRectangleBorder(
                  // Requirement 3.4: borderRadius 10 (default)
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                ),
                margin: EdgeInsets.zero,
                // Requirement 3.1: themeAccent background
                color: backgroundColor ?? themeAccent,
                child: Container(
                  width: s.infinity,
                  padding: EdgeInsets.all(15 * s.customWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Requirement 3.2: white color, w600, fontSize 17, letterSpacing 1
                      Text(
                        label,
                        style: TextStyle(
                          color: foregroundColor ?? white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17 * s.customWidth,
                          letterSpacing: 1,
                        ),
                      ),
                      if (icon != null) ...[
                        SizedBox(width: 20 * s.customWidth),
                        Icon(
                          icon,
                          color: foregroundColor ?? white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Custom web button widget matching design spec.
/// 
/// Implements Requirements 3.1, 3.2, 3.4:
/// - Card with elevation 5, borderRadius 10
/// - Text styling: white, w600, fontSize 17, letterSpacing 1
/// - Rounded corners (BorderRadius.circular(10-30))
class CustomWebButton extends StatelessWidget {
  final double? borderRadius;
  final VoidCallback onTap;
  final String label;
  final IconData? icon;
  final Color? backgroundColor, foregroundColor;
  final bool isLoading;
  
  /// Default border radius matching design spec (Requirement 3.4)
  static const double defaultBorderRadius = 10.0;
  
  const CustomWebButton({
    Key? key,
    required this.onTap,
    required this.isLoading,
    this.borderRadius,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     WebScreen s = WebScreen(context);
    // Requirement 3.4: borderRadius between 10-30, default to 10
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSwitcher(
        // Requirement 9.1: Duration between 300-600ms
        reverseDuration: animationDurationMin,
        duration: animationDurationMin,
        // Requirement 9.2: Use Curves.easeInOut for smooth transitions
        switchInCurve: animationCurveDefault,
        switchOutCurve: animationCurveDefault,
        child: isLoading
            ? CPI(30 * s.customWebWidth)
            : Card(
                // Requirement 3.1: elevation 5
                elevation: 5,
                shape: RoundedRectangleBorder(
                  // Requirement 3.4: borderRadius 10 (default)
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                ),
                margin: EdgeInsets.zero,
                // Requirement 3.1: themeAccent background
                color: backgroundColor ?? themeAccent,
                child: Container(
                  width: s.infinity,
                  padding: EdgeInsets.all(15 * s.customWebWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Requirement 3.2: white color, w600, fontSize 17, letterSpacing 1
                      Text(
                        label,
                        style: TextStyle(
                          color: foregroundColor ?? white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17 * s.customWebWidth,
                          letterSpacing: 1,
                        ),
                      ),
                      if (icon != null) ...[
                        SizedBox(width: 20 * s.customWebWidth),
                        Icon(
                          icon,
                          color: foregroundColor ?? white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
class BeOnTimeAnimatedText extends StatelessWidget {
  const BeOnTimeAnimatedText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen s = Screen(context);
    return LayoutBuilder(builder: (context, constraints) {
      double fontSize = constraints.maxWidth < 600 ? 30 * s.customWidth : 40;

      return AnimatedTextKit(
        animatedTexts: [
          WavyAnimatedText(
            "INVOICE PRO",
            textStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
            speed: const Duration(milliseconds: 400),
          ),
        ],
        isRepeatingAnimation: true,
        repeatForever: true,
        stopPauseOnTap: true,
      );
    });
  }
}
