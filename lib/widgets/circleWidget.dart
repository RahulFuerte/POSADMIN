import 'package:flutter/material.dart';

class CircleContainer extends StatelessWidget {
  final LinearGradient? gradient;
  final Icon icon;
  final String text;

  const CircleContainer({
    Key? key,
    this.gradient,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(colors: [
                    Colors.transparent,
                    Colors.transparent
                  ]), // Use a default gradient or handle null
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            letterSpacing: .8,
            fontFamily: "fontmain",
          ),
        ),
      ],
    );
  }
}
