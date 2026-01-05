import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_admin/appbar.dart';
import 'package:pos_admin/backend/auth/phone_authentication.dart';
import 'package:pos_admin/backend/permission.dart';
import 'package:pos_admin/backend/provider/login_provider.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/constants/strings.dart';
import 'package:pos_admin/inception_component.dart';
import 'package:pos_admin/sceens/otp.dart';
import 'package:pos_admin/navigation.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Inception extends StatefulWidget {
  const Inception({super.key});

  @override
  State<Inception> createState() => _InceptionState();
}

class _InceptionState extends State<Inception> {
  final TextEditingController phone = TextEditingController();
  late Navigation nav;
  final Permissions permissions = Permissions();

  @override
  void initState() {
    nav = Navigation(context);
    super.initState();
  }

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: white,
        appBar: const ZeroAppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: themeAccent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: s.isMobile ? _buildMobileLayout(s) : _buildWebLayout(s),
      ),
    );
  }

  Widget _buildMobileLayout(Screen s) {
    return Stack(
      children: [
        // Background shape
        Shape(s),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: s.scale(20)),

                // Animated title
                const BeOnTimeAnimatedText(),

                SizedBox(height: s.scale(40)),

                // Phone input card
                _buildPhoneInputCard(s),

                SizedBox(height: s.scale(24)),

                // Send OTP button
                _buildSendOtpButton(s),

                SizedBox(height: s.scale(32)),

                // Terms and conditions
                _buildTermsAndConditions(s),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputCard(Screen s) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: s.scale(16),
          vertical: s.scale(8),
        ),
        child: Row(
          children: [
            // Country code
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: s.scale(12),
                vertical: s.scale(8),
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇮🇳',
                    style: TextStyle(fontSize: s.scale(20)),
                  ),
                  SizedBox(width: s.scale(4)),
                  Text(
                    '+91',
                    style: TextStyle(
                      fontSize: s.scale(16),
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: s.scale(12)),

            // Phone input
            Expanded(
              child: TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontSize: s.scale(18),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter mobile number',
                  hintStyle: TextStyle(
                    color: grey,
                    fontSize: s.scale(16),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                autofillHints: const [AutofillHints.telephoneNumberNational],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOtpButton(Screen s) {
    return Consumer<LoginProvider>(
      builder: (context, value, _) => SizedBox(
        width: double.infinity,
        height: s.scale(56),
        child: ElevatedButton(
          onPressed: value.isProcessing ? null : () => _handleSendOtp(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: themeAccent,
            foregroundColor: white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: value.isProcessing
              ? SizedBox(
                  width: s.scale(24),
                  height: s.scale(24),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: s.scale(17),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: s.scale(12)),
                    Icon(Icons.arrow_forward_rounded, size: s.scale(20)),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleSendOtp(LoginProvider value) async {
    if (phone.text.length == 10) {
      if (!(await permissions.checkSms())) {
        await permissions.requestSms();
      }
      value.setPhone = "+91${phone.text}";
      if (mounted) {
        String result = await PhoneAuthentication(
          context: context,
          mounted: mounted,
          lp: value,
        ).sendPhoneOtp();
        if (mounted) {
          CustomSnackBar(context).build(result);
        }
      }
      Future.delayed(
        const Duration(milliseconds: 1000),
        () => nav.push(const OTP()),
      );
    } else {
      CustomSnackBar(context).build("Please enter a valid 10-digit number");
    }
  }

  Widget _buildTermsAndConditions(Screen s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s.scale(16)),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            height: 1.6,
            fontFamily: 'fontmain',
          ),
          children: [
            TextSpan(
              text: "By continuing, you agree to the ",
              style: TextStyle(
                color: grey,
                fontSize: s.scale(13),
              ),
            ),
            TextSpan(
              text: "Terms & Conditions",
              style: TextStyle(
                color: primaryColor,
                fontSize: s.scale(13),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(AppStrings.themePrivacyPolicy),
            ),
            TextSpan(
              text: " and ",
              style: TextStyle(
                color: grey,
                fontSize: s.scale(13),
              ),
            ),
            TextSpan(
              text: "Privacy Policy",
              recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(AppStrings.themePrivacyPolicy),
              style: TextStyle(
                color: primaryColor,
                fontSize: s.scale(13),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(Screen s) {
    return Container(
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
          // Left side - Branding (hide on smaller screens)
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
                      "Designed for restaurant management - empowering managers, owners, and employees with better tools for an exceptional customer experience.",
                      style: TextStyle(
                        fontFamily: 'fontmain',
                        color: white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: white,
                        side: const BorderSide(color: white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Read More",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right side - Login form
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
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.point_of_sale_rounded,
                            size: 48,
                            color: white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Welcome text
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Sign in to continue",
                        style: TextStyle(
                          fontSize: 14,
                          color: grey,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Phone input
                      _buildWebPhoneInput(),

                      const SizedBox(height: 24),

                      // OTP input
                      _buildWebOtpInput(),

                      const SizedBox(height: 32),

                      // Verify button
                      _buildWebVerifyButton(),

                      const SizedBox(height: 16),

                      // Resend link
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Didn't receive OTP? Resend",
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
    );
  }

  Widget _buildWebPhoneInput() {
    return Consumer<LoginProvider>(
      builder: (context, value, _) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Phone Number",
                    hintStyle: TextStyle(color: grey),
                    prefixText: '+91 ',
                    prefixStyle: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: value.isProcessing ? null : () => _handleSendOtp(value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: value.isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(white),
                        ),
                      )
                    : const Text(
                        "Get OTP",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebOtpInput() {
    return Consumer<LoginProvider>(
      builder: (context, lp, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 50,
              height: 60,
              child: TextField(
                controller: lp.controllers[index],
                focusNode: index == 0 ? lp.firstFocusNode : (index == 5 ? lp.lastFocusNode : null),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.headlineSmall,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    lp.controllers[index].text = value[value.length - 1];
                    if (index < 5) {
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  }
                },
                onTap: () => lp.controllers[index].clear(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWebVerifyButton() {
    return Consumer<LoginProvider>(
      builder: (context, lp, _) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
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
          child: const Text(
            "Verify OTP",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
