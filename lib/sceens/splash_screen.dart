import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pos_admin/sceens/adminDashboard.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/inception.dart';
import 'package:pos_admin/sceens/mainadmindashboard.dart';
import 'package:pos_admin/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Navigate after delay
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool('isLogged') ?? false;
    String myPhone = prefs.getString('myPhone') ?? '';

    if (isLogged) {
      try {
        final doc = await FirebaseFirestore.instance.collection('MainAdmin').doc(myPhone).get();

        if (!mounted) return;

        if (doc.exists) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainAdminDashboard(),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AdminDashboard(Uid: myPhone),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Error: $e');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Inception(),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Inception(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: s.isMobile ? _buildMobileLayout(s) : _buildWebLayout(s),
    );
  }

  Widget _buildMobileLayout(Screen s) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                
                    // App Name with branding font
                    Text(
                      'POS Admin',
                      style: GoogleFonts.alfaSlabOne(
                        fontSize: s.scale(35),
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                
                    SizedBox(height: s.scale(8)),
                
                    // Tagline
                    Text(
                      'Management System',
                      style: TextStyle(
                        fontFamily: 'fontmain',
                        fontSize: s.scale(16),
                        color: grey,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2,
                      ),
                    ),
                
                    SizedBox(height: s.scale(40)),
                
                    // Lottie Animation
                    Lottie.asset(
                      "$lottiePath/splashScreenAnimation.json",
                      fit: BoxFit.contain,
                      width: s.width * 0.7,
                      frameRate: FrameRate(90),
                    ),
                
                    const Spacer(flex: 2),
                
                    // Bottom branding
                    Column(
                      children: [
                        Image.asset(
                          "$imagesPath/bbblogo.png",
                          height: s.scale(45),
                        ),
                        SizedBox(height: s.scale(12)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: s.scale(32)),
                          child: Text(
                            "Streamlining Success, One Bill at a Time.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'fontmain',
                              color: grey,
                              fontSize: s.scale(13),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                
                    SizedBox(height: s.scale(40)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          // Left side - Branding
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.point_of_sale_rounded,
                      size: 48,
                      color: white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    "POS Admin Panel",
                    style: GoogleFonts.alfaSlabOne(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    "Restaurant Management System",
                    style: TextStyle(
                      fontFamily: 'fontmain',
                      fontSize: 18,
                      color: white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description
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

                  const SizedBox(height: 48),

                  // Loading indicator
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          fontFamily: 'fontmain',
                          color: white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right side - Animation
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Lottie.asset(
                  "$lottiePath/splashScreenAnimation.json",
                  fit: BoxFit.contain,
                  width: 400,
                  frameRate: FrameRate(90),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
