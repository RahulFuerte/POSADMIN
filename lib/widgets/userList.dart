import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

class UserList extends StatelessWidget {
  
  final String name;
  final String phone;
  final String email;
    final String code;

  UserList({
    required this.name,
    required this.phone,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * .26,
      decoration: BoxDecoration(color: white, boxShadow: [
        BoxShadow(
          blurRadius: 4.0,
        ),
      ]),
      child: Row(
        children: [
          Container(
            height: MediaQuery.of(context).size.width * .26,
            width: MediaQuery.of(context).size.width * .24,
            color: primaryColor,
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              backgroundImage: AssetImage('$imagesPath/user.gif'),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                 Text(
                  code,
                  style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  phone,
                  style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
                ),
                 Text(
                  email,
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
