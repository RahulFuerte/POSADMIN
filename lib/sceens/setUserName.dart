import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_admin/sceens/adminDashboard.dart';
import 'package:pos_admin/constants/colors.dart';

class SetNameScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationID;
  const SetNameScreen(
      {required this.phoneNumber, required this.verificationID, super.key});

  @override
  State<SetNameScreen> createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  void checkTextFieldLength(String value) {
    setState(() {
      isButtonEnabled =
          nameController.text.length > 2 && validateEmail(emailController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text(
            "ACCOUNT DETAILS",
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 11.0),
              child: Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            )
          ],
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                SizedBox(
                  height: h * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: const Text(
                    "We need some more details before we can get you started",
                    style: TextStyle(
                        color: black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: h * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: TextField(
                    controller: nameController,
                    onTap: () => _requestFocus(nameFocusNode),
                    focusNode: nameFocusNode,
                    cursorColor: black,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(
                          color:
                              nameFocusNode.hasFocus ? black : Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: nameFocusNode.hasFocus
                                ? black
                                : Colors.black54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: black),
                      ),
                    ),
                    onChanged: (value) {
                      checkTextFieldLength(value);
                    },
                  ),
                ),
                SizedBox(
                  height: h * 0.01,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: TextField(
                    controller: emailController,
                    onTap: () => _requestFocus(emailFocusNode),
                    focusNode: emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    cursorColor: black,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                          color:
                              emailFocusNode.hasFocus ? black : Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: emailFocusNode.hasFocus
                                ? black
                                : Colors.black54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: black),
                      ),
                    ),
                    onChanged: (value) =>
                        checkTextFieldLength(emailController.text),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.02),
              child: GestureDetector(
                onTap: () => isButtonEnabled ? uploadUserData() : null,
                child: Container(
                  height: h * 0.06,
                  decoration: BoxDecoration(
                      color: isButtonEnabled
                          ? black
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                      child: Text(
                    "SAVE ACCOUNT DETAILS",
                    style: TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  )),
                ),
              ),
            ),
          ],
        ));
  }

  void _requestFocus(FocusNode myFocus) {
    setState(() {
      FocusScope.of(context).requestFocus(myFocus);
    });
  }

  bool validateEmail(String email) {
    // Regular expression pattern for a simple email validation
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Future<void> saveName(String phoneNumber, String name) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(phoneNumber, name);
  // }

  void uploadUserData() async {
    try {
      final phoneNumber = widget.phoneNumber;
      final userName = nameController.text;
      final uId = widget.phoneNumber;
      final String email = emailController.text;

      final userProfileCollection =
          FirebaseFirestore.instance.collection("AllAdmins");

      final userData = <String, dynamic>{
        'phone': phoneNumber,
        'name': userName,
        'uID': uId,
        'email': email,
        'createdAt': DateTime.now().toString(),
      };

      await userProfileCollection.doc(uId).set(userData).then((_) {
        log("Data Uploaded successfull!");
      }).catchError((error) {
        log('Error uploading data: $error');
      });
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AdminDashboard(Uid: phoneNumber),
            ),
            (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
      } else if (e.code == 'email-already-in-use') {}
    } catch (e) {
      log('Error: $e');
    }
  }
}