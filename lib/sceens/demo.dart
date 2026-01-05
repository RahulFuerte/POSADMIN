import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

/// A reusable text field widget following the design system.
/// 
/// Implements Requirements 4.1, 4.2, 4.3, 4.4:
/// - Wrapped in Card with elevation 5 and border radius 10
/// - Black cursor color and fontSize 18.2 with letterSpacing 1
/// - Hint text in grey color
/// - No default borders (InputBorder.none)
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String cstmLable;
  final TextInputType keyboardType;
  final int? maxLength;
  final IconData? prefixIcon;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.cstmLable,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 8, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cstmLable,
            style: const TextStyle(
              letterSpacing: 1.3,
              fontSize: 14,
              fontFamily: 'fontmain',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 180,
          ),
          Card(
            elevation: 5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: TextField(
                keyboardType: keyboardType,
                maxLength: maxLength,
                style: const TextStyle(
                  fontSize: 18.2,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
                controller: controller,
                cursorColor: black,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: grey,
                  ),
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: primaryColor)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
