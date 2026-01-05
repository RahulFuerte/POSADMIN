import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/sceens/adminDashboard.dart';
import 'package:pos_admin/backend/backend.dart';
import 'package:pos_admin/backend/provider/login_provider.dart';
import 'package:pos_admin/sceens/mainadmindashboard.dart';
import 'package:pos_admin/sceens/setUserName.dart';
import 'package:pos_admin/widgets/snack_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PhoneAuthentication {
  final BuildContext context;
  final bool mounted;
  LoginProvider lp;
  PhoneAuthentication({
    required this.context,
    required this.mounted,
    required this.lp,
  });

  final FirebaseAuth _fa = FirebaseAuth.instance;
  final Backend _backend = Backend();
  bool _isLoading = false;
  Future<String> sendPhoneOtp() async {
    String result = "";
    lp.startProcessing();
    await _fa.verifyPhoneNumber(
      timeout: const Duration(seconds: 120),
      phoneNumber: lp.phone,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        lp.startProcessing();
        lp.setSmsCode = phoneAuthCredential.smsCode!;
        Future.delayed(
          const Duration(milliseconds: 250),
          () async => result = await _afterSendingOtp(phoneAuthCredential),
        );
        lp.endProcessing();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.message!.contains("Network")) {
          result = "Please check your internet connection.";
        } else if (e.code.contains("too-many-requests")) {
          result =
              "You've made too many requests, please try again after some time.";
        } else if (e.code.contains("invalid-phone-number")) {
          result = "Invalid phone number.";
        } else {
          result = "Something went wrong, please try later.";
        }
      },
      codeSent: (verificationID, [int? forceResendingToken]) {
        lp.setVerificationID = verificationID;
        if (mounted) {
          CustomSnackBar(context).build("OTP sent successfully.");
        }
      },
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
    lp.endProcessing();
    return result;
  }

  Future<String> verifyPhoneOTP() async {
    String code = "";
    for (TextEditingController controller in lp.controllers) {
      code += controller.text;
    }
    lp.setSmsCodeManually = code;
    if (lp.smsCode.length == 6) {
      String result = await _afterSendingOtp(PhoneAuthProvider.credential(
        verificationId: lp.verificationID!,
        smsCode: lp.smsCode,
      ));

      if (result == "Login successful.") {
        // User successfully logged in, set the bool value to true
        await _setUserLoggedIn();
      }

      return result;
    } else {
      return "Incorrect OTP entered.";
    }
  }

  Future<String> _afterSendingOtp(
    PhoneAuthCredential phoneAuthCredential,
  ) async {
    lp.startProcessing();
    String result = "Login successful.";

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      if (userCredential.user != null) {
        try {
          bool isPhoneNumberRegistered =
              await _checkIfPhoneNumberExistsInFirestore(lp.phone);

          if (isPhoneNumberRegistered) {
            print(lp.phone);
            try {
              await FirebaseFirestore.instance
                  .collection('MainAdmin')
                  .doc(lp.phone)
                  .get()
                  .then((value) {
                if (value.exists) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainAdminDashboard(),
                    ),
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => AdminDashboard(
                        Uid: lp.phone,
                      ),
                    ),
                    (route) => false,
                  );
                }
              });
            } catch (e) {
              print(e);
            }
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => SetNameScreen(
                  phoneNumber: lp.phone,
                  verificationID: lp.verificationID!,
                ),
              ),
              (route) => false,
            );
          }
        } catch (e) {
          result = "Something went wrong!";
          debugPrint(e.toString());
        }
      }
    } catch (e) {
      // Check if the account already exists
      if (e is FirebaseAuthException &&
          e.code == 'account-exists-with-different-credential') {
        result = "Account already exists.";
      } else {
        result = "Something went wrong.";
      }
    }

    lp.endProcessing();
    return result;
  }

  Future<bool> _checkIfPhoneNumberExistsInFirestore(String phoneNumber) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('AllAdmins')
          .doc(phoneNumber) // Assuming document ID is the phone number
          .get();

      return docSnapshot.exists;
    } catch (e) {
      debugPrint("Error checking phone number in Firestore: $e");
      return false;
    }
  }

// Function to set the user's login status to true in SharedPreferences
  Future<void> _setUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('myPhone', lp.phone);
    await prefs.setBool('isLogged', true);
  }
}
