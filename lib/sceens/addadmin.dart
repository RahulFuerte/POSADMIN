import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/sceens/addCustomerScreen.dart';

import '../constants/colors.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  TextEditingController phonenumber = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController emailid = TextEditingController();
  void UploadeUserdata() async {
    try {
      final phoneNumber = phonenumber.text;
      final userName = name.text;
      final uId = "+91${phonenumber.text}";
      String email = emailid.text.toString();

      final userProfileCollection =
          FirebaseFirestore.instance.collection("AllAdmins");

      final userData = <String, dynamic>{
        'phone': "+91$phoneNumber",
        'name': userName,
        'uID': "+91$phoneNumber",
        'email': email,
        'createdAt': DateTime.now().toString(),
      };

      await userProfileCollection.doc(uId).set(userData).then((_) {
        log("Data Uploaded successfull!");
      }).catchError((error) {
        log('Error uploading data: $error');
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width -
              MediaQuery.of(context).size.width / 6,
          height: 55,
          decoration: const BoxDecoration(
            color: Colors.white,
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.grey.withOpacity(0.8),
            //       spreadRadius: 0.5,
            //       blurRadius: 0.5)
            // ],
          ),
          child: const Center(
            child: Text('Add Admin Details  ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 23)),
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 120,
              width: MediaQuery.of(context).size.width / 3.1,
              color: Colors.grey.withOpacity(0.2),
              child: ListView(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(height: 50,),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   info("admin name", "enter Admin name here", context, name),
                 ],),
                   const SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    info("Mobile number", "Enter mobile number", context,
                      phonenumber),
                ],),
                    const SizedBox(height: 50,),   
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   info("Email", "enter email here", context, emailid),
                 ],),
                   const SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 51,
                        width: MediaQuery.of(context).size.width / 3.5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: primaryColor),
                        child: MaterialButton(
                          onPressed: () {
                            UploadeUserdata();
                          },
                          height: 50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Add Admin',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
