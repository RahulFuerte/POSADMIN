import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_admin/constants/colors.dart';

/// A reusable text field widget following the design system.
/// 
/// Implements Requirements 4.1, 4.2, 4.3, 4.4:
/// - Wrapped in Card with elevation 5 and border radius 10
/// - Black cursor color and fontSize 18.2 with letterSpacing 1
/// - Hint text in grey color
/// - No default borders (InputBorder.none)
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final int maxLines;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.prefixText,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              letterSpacing: 1.3,
              fontSize: 14,
              fontFamily: 'fontmain',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Card(
          elevation: 5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              maxLength: maxLength,
              maxLines: maxLines,
              enabled: enabled,
              inputFormatters: inputFormatters,
              validator: validator,
              onChanged: onChanged,
              cursorColor: black,
              style: const TextStyle(
                fontSize: 18.2,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
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
                prefixText: prefixText,
                prefixStyle: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.2,
                ),
                suffixIcon: suffixIcon != null
                    ? IconButton(
                        icon: Icon(suffixIcon, color: grey),
                        onPressed: onSuffixTap,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A search text field with expandable animation.
class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDurationDefault,
      curve: animationCurveDefault,
      width: isExpanded ? MediaQuery.of(context).size.width * 0.75 : 50,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: white,
        boxShadow: [
          BoxShadow(
            color: grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.search, color: primaryColor),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
          if (isExpanded)
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                cursorColor: black,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: grey),
                ),
              ),
            ),
          if (isExpanded && widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20, color: grey),
              onPressed: () {
                widget.controller.clear();
                widget.onClear?.call();
              },
            ),
        ],
      ),
    );
  }
}
