import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

class MyTextStyle {
  TextStyle get heading => const TextStyle(
        color: black,
        letterSpacing: 2,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      );

  TextStyle get screenTitle => const TextStyle(
        fontFamily: 'tabfont',
        fontSize: 19,
        color: black,
      );

  TextStyle get description => const TextStyle(
        color: black,
        letterSpacing: 1,
        fontSize: 16,
      );
  TextStyle get buttonText => const TextStyle(
        color: white,
        letterSpacing: 1,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      );

  TextStyle get bodyText => const TextStyle(
        fontFamily: 'fontmain',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: black,
      );

  TextStyle get content => const TextStyle(
        color: black,
        letterSpacing: 0.5,
        fontSize: 16,
      );
  TextStyle get contentHeading => const TextStyle(
        color: black,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        fontSize: 16,
      );
  TextStyle get transparent => const TextStyle(
        color: trans,
      );
}
