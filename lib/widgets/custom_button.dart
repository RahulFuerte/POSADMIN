import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

/// A reusable button widget following the design system.
/// 
/// Implements Requirements 3.1, 3.2, 3.3, 3.4:
/// - Card elevation 5, border radius 10, themeAccent background
/// - White text, fontWeight w600, fontSize 17, letterSpacing 1
/// - Visual feedback on press
/// - Rounded corners (BorderRadius.circular(10-30))
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double elevation;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 10,
    this.elevation = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: backgroundColor ?? themeAccent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor ?? white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          letterSpacing: 1,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 12),
                        Icon(icon, color: textColor ?? white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// A primary action button with gradient background.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [primaryColor, themeAccentSolid],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: white, size: 22),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
