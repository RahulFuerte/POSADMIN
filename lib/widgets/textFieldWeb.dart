import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/text_styles.dart';
import 'package:pos_admin/webScreen.dart';

class CustomTextFormFieldWeb extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Widget prefixIcon;
  final List<String>? autoFillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  const CustomTextFormFieldWeb({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.autoFillHints,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final WebScreen w = WebScreen(context);
    final MyTextStyle ts = MyTextStyle();
    return Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8 * w.customWebWidth,
          vertical: 3 * w.customWebWidth,
        ),
        child: TextFormField(
          // cursorColor: theme,
          cursorColor: Colors.black,
          style: TextStyle(fontSize: 18.2 * w.customWebWidth, letterSpacing: 1),
          controller: controller,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          autofillHints: autoFillHints,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: [
            FilteringTextInputFormatter.deny(regExpEmojis),
            ...inputFormatters!,
          ],
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintStyle: ts.buttonText.copyWith(color: grey),
          ),
        ),
      ),
    );
  }
}

class PrefixIconWeb extends StatelessWidget {
  const PrefixIconWeb(
    this.w, {
    Key? key,
  }) : super(key: key);

  final WebScreen w;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      child: Text(
        "+91",
        style: TextStyle(
          // color: theme,
          color: black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
