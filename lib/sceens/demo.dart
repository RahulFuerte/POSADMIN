import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String cstmLable;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool enabled;
  final IconData? prefixIcon;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.cstmLable,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2, left: 2, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cstmLable,
            style: const TextStyle(
              letterSpacing: 1.3,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            enabled: enabled,
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(12)),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              hintText: hintText,
            ),
          ),
           const SizedBox(height: 10,)
        ],
      ),
    );
  }
}


class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.heading,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = "Select",
  });

  final String heading;
  final List<String> items;
  final String? value;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADING
        Text(
          heading,
          style: const TextStyle(
            letterSpacing: 1.2,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
         const SizedBox(height: 4,),


        /// DROPDOWN CONTAINER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && items.contains(value)) ? value : null,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 10,)
      ],
    );
  }
}
