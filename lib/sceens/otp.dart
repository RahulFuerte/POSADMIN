import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_admin/backend/auth/phone_authentication.dart';
import 'package:pos_admin/backend/provider/login_provider.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/inception.dart';
import 'package:pos_admin/navigation.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

class OTP extends StatefulWidget {
  const OTP({super.key});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  late Navigation nav;

  @override
  void initState() {
    nav = Navigation(context);
    super.initState();
  }

  void _goBack() {
    if (mounted) {
      nav.pushAndRemoveUntil(const Inception());
      Provider.of<LoginProvider>(context, listen: false).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);
    
    return Scaffold(
      backgroundColor: white,
      appBar: s.isMobile
          ? AppBar(
              backgroundColor: white,
              elevation: 0,
              leading: IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded, color: black),
              ),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: white,
                statusBarIconBrightness: Brightness.dark,
              ),
            )
          : null,
      body: s.isMobile ? _buildMobileLayout(s) : _buildWebLayout(s),
    );
  }

  Widget _buildMobileLayout(Screen s) {
    return Consumer<LoginProvider>(
      builder: (context, lp, _) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(s.scale(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: s.scale(28),
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
              
              SizedBox(height: s.scale(12)),
              
              // Subtitle
              Text(
                "We have sent the verification code to your mobile number",
                style: TextStyle(
                  fontSize: s.scale(15),
                  color: grey,
                  height: 1.4,
                ),
              ),
              
              SizedBox(height: s.scale(8)),
              
              // Phone number with edit
              Row(
                children: [
                  Text(
                    lp.phone,
                    style: TextStyle(
                      fontSize: s.scale(16),
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(width: s.scale(8)),
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      padding: EdgeInsets.all(s.scale(4)),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: s.scale(16),
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: s.scale(40)),
              
              // OTP Input boxes
              _buildOtpInputRow(lp, s),
              
              SizedBox(height: s.scale(16)),
              
              // Clear button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    for (var controller in lp.controllers) {
                      controller.clear();
                    }
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(lp.firstFocusNode);
                  },
                  child: Text(
                    "Clear",
                    style: TextStyle(
                      color: grey,
                      fontSize: s.scale(14),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: () async {
                    String result = await PhoneAuthentication(
                      context: context,
                      mounted: mounted,
                      lp: lp,
                    ).sendPhoneOtp();
                    if (mounted) {
                      CustomSnackBar(context).build(result);
                    }
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: s.scale(14),
                        fontFamily: 'fontmain',
                      ),
                      children: const [
                        TextSpan(
                          text: "Didn't receive code? ",
                          style: TextStyle(color: grey),
                        ),
                        TextSpan(
                          text: "Resend OTP",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: s.scale(16)),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: s.scale(56),
                child: ElevatedButton(
                  onPressed: lp.isProcessing
                      ? null
                      : () async {
                          String result = await PhoneAuthentication(
                            context: context,
                            mounted: mounted,
                            lp: lp,
                          ).verifyPhoneOTP();
                          if (mounted) {
                            CustomSnackBar(context).build(result);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: lp.isProcessing
                      ? SizedBox(
                          width: s.scale(24),
                          height: s.scale(24),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(white),
                          ),
                        )
                      : Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: s.scale(17),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: s.scale(24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputRow(LoginProvider lp, Screen s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return _buildOtpBox(
          lp.controllers[index],
          s,
          focusNode: index == 0
              ? lp.firstFocusNode
              : (index == 5 ? lp.lastFocusNode : null),
          isLast: index == 5,
        );
      }),
    );
  }

  Widget _buildOtpBox(
    TextEditingController controller,
    Screen s, {
    FocusNode? focusNode,
    bool isLast = false,
  }) {
    return SizedBox(
      width: s.scale(50),
      height: s.scale(60),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: focusNode != null,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: s.scale(24),
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofillHints: const [AutofillHints.oneTimeCode],
        onChanged: (value) {
          if (value.isNotEmpty) {
            controller.text = value[value.length - 1];
            if (!isLast) {
              FocusScope.of(context).nextFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          }
        },
        onTap: () => controller.clear(),
        decoration: InputDecoration(
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildWebLayout(Screen s) {
    return Consumer<LoginProvider>(
      builder: (context, lp, _) => Container(
        height: s.height,
        width: s.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 46, 139, 49),
              primaryColor,
              themeAccentSolid,
              Color.fromARGB(255, 3, 60, 5),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Row(
          children: [
            // Left side - Branding
            if (s.width >= 900)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "POS Admin Panel",
                        style: GoogleFonts.alfaSlabOne(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Enter the verification code sent to your mobile number to continue.",
                        style: TextStyle(
                          fontFamily: 'fontmain',
                          color: white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Right side - OTP form
            Expanded(
              flex: s.width >= 900 ? 1 : 2,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _goBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: grey,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Title
                        const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          "Enter the 6-digit code sent to",
                          style: TextStyle(
                            fontSize: 14,
                            color: grey,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          lp.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // OTP boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: SizedBox(
                                width: 50,
                                height: 60,
                                child: TextField(
                                  controller: lp.controllers[index],
                                  focusNode: index == 0
                                      ? lp.firstFocusNode
                                      : (index == 5 ? lp.lastFocusNode : null),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      lp.controllers[index].text =
                                          value[value.length - 1];
                                      if (index < 5) {
                                        FocusScope.of(context).nextFocus();
                                      } else {
                                        FocusScope.of(context).unfocus();
                                      }
                                    }
                                  },
                                  onTap: () => lp.controllers[index].clear(),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: backgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: lp.isProcessing
                                ? null
                                : () async {
                                    String result = await PhoneAuthentication(
                                      context: context,
                                      mounted: mounted,
                                      lp: lp,
                                    ).verifyPhoneOTP();
                                    if (mounted) {
                                      CustomSnackBar(context).build(result);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: lp.isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(white),
                                    ),
                                  )
                                : const Text(
                                    "Verify OTP",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Resend
                        TextButton(
                          onPressed: () async {
                            String result = await PhoneAuthentication(
                              context: context,
                              mounted: mounted,
                              lp: lp,
                            ).sendPhoneOtp();
                            if (mounted) {
                              CustomSnackBar(context).build(result);
                            }
                          },
                          child: Text(
                            "Didn't receive code? Resend",
                            style: TextStyle(
                              color: grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
