import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        style:
            TextStyle(fontSize: 17, color: black, fontWeight: FontWeight.w500),
        controller: controller,
        cursorColor: primaryColor, // You can customize the color here
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontWeight: FontWeight.w400),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.black38),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide:
                const BorderSide(color: primaryColor), // Customize the color
          ),
        ),
      ),
    );
  }
}
