import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

class CustomRowWidget extends StatelessWidget {
  final IconData customIcon;
  final String text1;
  final String text2;

  CustomRowWidget({
    required this.customIcon,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * .26,
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(
              blurRadius: 4.0,
            ),
          ]),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
              ),
            ),
            height: MediaQuery.of(context).size.width * .26,
            width: MediaQuery.of(context).size.width * .24,
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(
                customIcon,
                color: primaryColor,
                size: 30.0,
              ),
            ),
          ),
          // SizedBox(
          //   width: MediaQuery.of(context).size.width * .03,
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text1,
                  style: TextStyle(
                    fontSize: 16.0,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  text2,
                  style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
